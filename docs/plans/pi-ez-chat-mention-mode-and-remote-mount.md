# Plan: pi-ez-* commands work in mention-only mode + remote repo mounts + reload UX

Tracks three related improvements across `pi-ez-chat-mount`, `pi-ez-chat-threads`,
`pi-ez-chat-git`, and the `pi-ez-chat-image` baseline.

## Problem statement

1. Mention-only triggering breaks remote `/chat-*` commands.
   - `pi-chat` triggers extension input hooks only when `mentionedBot` is true, but
     it does **not** strip the bot mention from the text. Extensions match on
     `text.startsWith("/chat-thread")`, which never matches `@bot /chat-thread`.
   - Result: in a mention-only channel, `/chat-thread`, `/chat-mount`, `/chat-git`,
     etc. silently no-op when invoked via mention.
2. Not all `pi-ez-*` commands have remote input hooks.
   - `pi-ez-chat-threads` has one. `pi-ez-chat-mount` and `pi-ez-chat-git` do not,
     so they only work from local pi sessions, not from chat.
3. `/chat-mount` only handles `cwd`. Users with workflows like "let me mount
   `https://github.com/bry-guy/foo`" must clone manually first.
4. Mount/thread/git config changes require manual sandbox restart. The user
   pattern is "make config change, then restart by typing `/chat-new` or
   reconnecting." That is friction we should automate or expose as
   `/chat-reload`.

## Goals

- Every `pi-ez-chat-*` command available in pi-chat works in mention-only mode
  with `@bot /chat-...` syntax.
- `/chat-mount` accepts a remote repo URL (or shorthand) and clones it to a
  configurable source directory, idempotently, before mounting.
- After any config change that requires a new Gondolin VM, the affected command
  reconnects/reloads the sandbox automatically. If a per-command auto-reload is
  not feasible, expose `/chat-reload` as a manual fallback.
- Behavior is consistent across `pi-ez-chat-mount`, `pi-ez-chat-threads`,
  `pi-ez-chat-git`, and any future `pi-ez-chat-*`.

## Non-goals (v1)

- Generalizing remote command machinery into a shared helper package. Likely
  worthwhile later; keep this change set focused.
- Authentication for clone of private repos. We rely on host-side `git` +
  `ssh-agent` (the same posture `pi-ez-chat-git` uses for push) and document
  the requirement.
- Mounting arbitrary non-git URLs.
- Hot-reloading mounts without re-creating the VM. Gondolin binds mounts at
  `VM.create`; we accept restart-on-change.

## Design

### 1. Mention-tolerant remote input matching

Reusable helper inside each `pi-ez-chat-*` package:

```ts
export function stripLeadingMention(text: string): string {
  // <@!?123>, <@&123>, @botname, leading whitespace + repeated mentions
  return text
    .replace(/^\s+/, "")
    .replace(/^(?:<@!?\d+>|<@&\d+>|@[\w.-]+)\s*/, "")
    .replace(/^\s+/, "");
}

export function matchSlashCommand(text: string, aliases: readonly string[]): { name: string; args: string } | undefined {
  const stripped = stripLeadingMention(text);
  for (const alias of aliases) {
    if (stripped === `/${alias}` || stripped.startsWith(`/${alias} `) || stripped.startsWith(`/${alias}\n`)) {
      return { name: alias, args: stripped.slice(alias.length + 1).trim() };
    }
  }
  return undefined;
}
```

Each extension's `input` hook:

```ts
pi.on("input", async (event, ctx) => {
  const match = matchSlashCommand(event.text, ["chat-thread", "chat-ez-thread"]);
  if (!match) return { action: "continue" };
  ...
});
```

Duplicate the helper in each package now; revisit a shared package later.

### 2. Add remote input hooks to every pi-ez-chat-* package

- `pi-ez-chat-mount`: add hooks for `/chat-mount`, `/chat-unmount`, `/chat-mounts`.
- `pi-ez-chat-git`: add hooks for `/chat-git enable|disable|identity|status`.
- `pi-ez-chat-threads`: replace existing `text.startsWith` matching with
  `matchSlashCommand` (still supports `/chat-thread` and `/chat-ez-thread`).

Remote-mode behavior mirrors the existing `pi-ez-chat-threads` pattern:

- On success: return `{ action: "transform", text: "<instruction with result>" }`
  so the agent replies in chat with the literal output.
- On error: same shape with the error and usage.

### 3. Remote repo mount in `/chat-mount`

Update `/chat-mount` argument parsing to accept either zero args (current cwd)
or a single URL/shorthand.

Accepted forms:

- `https://github.com/<owner>/<repo>[.git][#ref]`
- `git@github.com:<owner>/<repo>[.git][#ref]`
- `<owner>/<repo>` (GitHub shorthand)
- omit → current cwd (today's behavior, preserved as default)

Flow when a remote spec is provided:

1. Parse to canonical SSH URL when possible. Prefer SSH so cloning works through
   host SSH agent. Fall back to HTTPS if SSH is unavailable.
2. Resolve clone destination:
   - `${SOURCE_DIR}/<repo>` where `SOURCE_DIR` comes from config (default `~/dev`).
   - If destination exists and is a git repo with the same `origin`, treat as
     already cloned. Optionally fetch on `--update`.
   - If destination exists and is something else, refuse unless `--force`.
3. If missing: shallow-clone or full-clone (configurable, default full). Use
   host `git`; do not run inside Gondolin.
4. Once host path is known, fall into the existing mount logic with
   `hostPath = resolved destination`.

CLI shape:

```text
/chat-mount                               # current cwd (today)
/chat-mount <repo-spec>                   # remote repo
/chat-mount <repo-spec> --read-only       # rw default; ro on demand
/chat-mount <repo-spec> --force           # clobber existing mount config
/chat-mount <repo-spec> --update          # git fetch before mounting
/chat-mount --source-dir /alt/path        # one-off source dir override
```

Config:

```text
~/.pi/agent/chat-mount/config.json
{
  "sourceDir": "~/dev",
  "cloneMode": "full" | "shallow"
}
```

Validation:

- Reject relative repo specs that don't unambiguously map to a clone path.
- Reject specs with traversal characters.
- Refuse to clone into a path with existing non-git content unless `--force`.

Failure modes:

- `git` missing: surface a clear error; suggest installing `git` on host.
- SSH clone failure: optionally retry HTTPS once; otherwise surface error.

Notes:

- The repo is cloned on the **host**, so all of `git config` / `ssh-agent` /
  user identity already work on the host. Inside the VM, `pi-ez-chat-git`
  handles identity + SSH egress separately.
- Mount is host-bind (RealFSProvider) like today.

### 4. Auto-reload after config changes

Best path: piggyback on `pi-chat`'s existing remote `new` command.

Reading `pi-chat`'s runtime, the supported remote control commands are:
`stop`, `new`, `compact`, `status`. `new` starts a new pi session in the same
conversation, which on the next message triggers a fresh `VM.create` (and
therefore re-applies all `VM.create` wrappers: mount, git, threads, etc.).

Two approaches in pi-ez packages, in priority order:

1. **Auto-reload via the remote `new` channel.**
   When a `pi-ez-chat-*` command mutates config and remote-mode is the calling
   context, emit a follow-up "post-action" that is delivered to pi-chat's
   control parser as `new`. This is the cleanest because it uses pi-chat's
   own remote control surface.
2. **Provide `/chat-reload` as a manual fallback.**
   New extension `pi-ez-chat-reload` (or hosted inside `pi-ez-chat-mount` if we
   want to avoid the extra package) that maps `/chat-reload` to the same
   `new` flow. Useful for users who applied changes locally and want to
   trigger a sandbox restart from chat.

Decision: implement both. Auto-reload by default; `/chat-reload` as escape hatch.

`/chat-reload` lives in a new tiny package `pi-ez-chat-reload`, because:

- It is orthogonal to any one feature.
- It is the simplest possible bridge to pi-chat's remote `new`.
- Other pi-ez packages can recommend `/chat-reload` in error/warning messages
  without depending on it at code level.

If pi-chat exposes a public "request sandbox restart" extension API later, both
auto-reload and `/chat-reload` collapse onto that. Document this as a future
simplification in `docs/known-issues.md`.

### 5. pi-ez-chat-image baseline must include `git`

The custom image already does (verified in earlier build), so no change needed.
Add a doc note in each pi-ez package README that the assumed guest image has
`git` and `openssh-client`.

## Per-package work items

### pi-ez-chat-mount

- [ ] Add `src/match.ts` with `stripLeadingMention` + `matchSlashCommand`.
- [ ] Add `src/repo-spec.ts` to parse `<owner>/<repo>`, HTTPS, SSH URLs into
      canonical `{ url, ref?, repoName }`.
- [ ] Add `src/clone.ts` that:
  - resolves clone destination under configured `sourceDir`
  - returns existing checkout if `origin` matches
  - clones via host `git` otherwise
  - supports `--update` (git fetch) and `--force` (delete or refuse)
- [ ] Add `src/config.ts` for `~/.pi/agent/chat-mount/config.json` (sourceDir,
      cloneMode), with defaults.
- [ ] Extend `/chat-mount` arg parser to accept repo spec.
- [ ] Add `input` event hook for `/chat-mount`, `/chat-unmount`, `/chat-mounts`.
- [ ] After mount/unmount changes through chat or local pi, trigger sandbox
      restart via remote `new` (see §4).
- [ ] Update README, plan-init, and known-issues.
- [ ] Tests:
  - `matchSlashCommand` strips mentions
  - repo-spec parser for GitHub forms (HTTPS/SSH/shorthand)
  - clone destination resolution (existing match, conflict, fresh)
  - mount integration with remote spec uses resolved hostPath
  - input hook returns transform results for success and failure

### pi-ez-chat-git

- [ ] Duplicate match helpers (`src/match.ts`).
- [ ] Add `input` event hook for `/chat-git enable|disable|identity|status`.
- [ ] After enable/disable/identity, trigger sandbox restart via remote `new`.
- [ ] Update README + docs/known-issues.

### pi-ez-chat-threads

- [ ] Replace `text.startsWith("/chat-thread")` with `matchSlashCommand` and
      keep `chat-ez-thread` alias.
- [ ] Optional: after thread creation, surface a reminder that the new thread
      already has its own VM; no reload needed for the parent channel.
- [ ] Update tests (mention-tolerant match).
- [ ] README footnote about mention-mode behavior.

### pi-ez-chat-reload (new)

- [ ] Scaffold package (mirrors `pi-ez-chat-mount`/`pi-ez-chat-git` layout).
- [ ] `/chat-reload` command:
  - Local pi mode: emit notice "Use pi-chat's `/new` from this conversation,
    or rerun your command which will auto-reload."
  - Remote (input hook) mode: produce a transform with the literal text `new`,
    which is exactly what `pi-chat`'s control parser already handles.
- [ ] Document that `/chat-reload` is a thin wrapper over pi-chat's existing
      remote `new` semantics; if pi-chat changes that contract, this package
      must follow.
- [ ] Tests: input hook returns expected `new` transform on mention or DM.

### Cross-cutting

- [ ] Each package's `input` hook also accepts the legacy `text.startsWith`
      path for non-mention triggers, to preserve current behavior.
- [ ] Each package documents the requirement in `docs/known-issues.md`:
      "pi-chat does not strip leading mentions; pi-ez packages do."
- [ ] If we duplicate the match helper across packages, add a TODO note in
      each pointing to a future `pi-ez-chat-extension-runtime` shared
      package.

## Sequenced TODO list (suggested implementation order)

1. [ ] pi-ez-chat-mount: implement `src/match.ts` + `src/repo-spec.ts` and
       wire remote input hook for `/chat-mount` (no clone yet).
2. [ ] pi-ez-chat-mount: implement `src/clone.ts` + `src/config.ts`; add
       remote-repo support to `/chat-mount`.
3. [ ] pi-ez-chat-mount: add auto-reload + tests.
4. [ ] pi-ez-chat-git: copy match helpers, add remote input hook, add
       auto-reload, tests.
5. [ ] pi-ez-chat-threads: switch to mention-tolerant matching; tests.
6. [ ] pi-ez-chat-reload: scaffold + `/chat-reload` mapped to pi-chat's
       remote `new`; tests.
7. [ ] Update READMEs / docs/plan-init / docs/known-issues across all four
       packages.
8. [ ] Commit and push per repo, mirroring the existing `pi-ez-*` PR/commit
       conventions.

## Open questions

1. Should `pi-ez-chat-mount`'s remote-repo support also accept `gitlab.com`,
   `bitbucket.org`, etc.? Easy if we just preserve any HTTPS/SSH URL verbatim;
   only the shorthand path is GitHub-specific. Yes — preserve any explicit URL.
2. Should `chat-mount` config live at
   `~/.pi/agent/chat-mount/config.json` (separate from mounts.json) or be
   embedded in `mounts.json` under a `__config__` key? Prefer a separate file;
   it keeps schemas focused.
3. Is `~/dev` the right default `sourceDir`? Yes for the current user; the
   default should be `~/dev` if it exists, otherwise the directory containing
   the current pi cwd, otherwise `$HOME`.
4. Should the parent channel be auto-reloaded on `/chat-thread`? No: thread
   creation does not change the parent VM. Only the new thread's VM matters,
   and its first user message triggers its first `VM.create` naturally.
5. Should auto-reload be opt-out? Yes via env var
   `PI_EZ_AUTO_RELOAD=0` for users who prefer manual.
