# YADM Migration Plan

Status: draft
Branch: `yadm-migration`
Author: pi
Date: 2026-03-27

## Goal

Migrate `bry-guy/dotfiles` from a `chezmoi`-source-layout repository to a `yadm`-managed home-layout repository, starting on this personal machine first, then rolling out to other devices after validation.

The migration should preserve the current operating model where:

- tracked/shared dotfiles live in git
- machine-local identity and secret material stay untracked
- `script/setup` remains the bootstrap entrypoint for package installation and machine prep
- work-only identity is available only on machines that provide local identity files

## Why switch

`yadm` better matches the current day-to-day usage of this repo:

- edit the real files in `$HOME`
- commit/push/pull with git semantics
- no separate source/apply layer
- no `dot_` / `private_dot_` naming indirection
- no `.git` directory in `$HOME`, avoiding the common "home is a git repo" tooling problem

## Non-goals

This migration does **not** aim to:

- finalize work identity defaults
- redesign Brew profile/manifests
- replace `script/setup` with yadm alternates or encryption features
- introduce host-specific alternate-file logic unless clearly needed later

## Guiding principles

1. Prefer simple Unix-y mechanisms over tool-specific magic.
2. Keep local identity files untracked.
3. Let `yadm` manage tracked home files.
4. Let `script/setup` manage machine bootstrap, packages, and local scaffolding.
5. Migrate on a branch first; do not break existing chezmoi-driven machines mid-rollout.

---

## Target end state

### Repository layout

The repo should move from a chezmoi source tree like:

- `dot_gitconfig`
- `private_dot_ssh/private_config`
- `private_dot_config/nvim/...`
- `private_dot_pi/private_agent/settings.json`

…to a home-layout tree like:

- `.gitconfig`
- `.ssh/config`
- `.config/nvim/...`
- `.pi/agent/settings.json`

This will make the repo naturally compatible with `yadm`, which tracks real home-relative paths directly.

### Ownership model after migration

#### `yadm` owns

- tracked dotfiles and config files
- repo sync (`status`, `diff`, `commit`, `push`, `pull`)

#### `script/setup` owns

- installing Homebrew and baseline packages
- applying Brew manifests/profiles
- machine bootstrap and OS-specific prep
- creating or prompting for local-only identity/secrets files
- post-clone bootstrap work

#### Local untracked files own

- machine-specific identities
- secret material
- private overrides that should not sync across machines

---

## Proposed rollout

### Phase 0: plan only

- create branch `yadm-migration`
- document migration plan
- do **not** change actual management tooling yet

### Phase 1: restructure repository on branch

- reshape repo from chezmoi naming/layout to home-layout
- preserve executable bits where needed
- add/update `.gitignore` for local-only files
- update docs and bootstrap instructions

### Phase 2: rewrite `script/setup`

- remove chezmoi-specific apply/init behavior
- keep bootstrap/package responsibilities
- add any local-file scaffolding needed for first-run success

### Phase 3: local trial on this personal machine

- install/init `yadm`
- adopt the branch layout
- verify common workflows
- verify no `$HOME/.git`-style tooling regressions
- verify git/github behavior remains correct

### Phase 4: merge and roll out to other machines

- once local validation is good, merge branch
- migrate work machine next
- keep machine-local identity files local

---

## Repository reshape plan

### Core layout rule

For every tracked chezmoi source path, migrate it to the path that today exists in `$HOME` after `chezmoi apply`.

### Important consequence

`script/` becomes a real top-level directory in the repo and remains **not** a managed home dotfile. This is fine in yadm. The repo is the home tree; top-level `script/` simply means `~/script/` becomes part of the tracked home layout.

That is different from today’s README language about a separate repo/source layer.

### Docs implication

README should be updated from:

- “The `script/` directory is part of the repo/source layer”

…to something closer to:

- “This repo is managed directly in `$HOME` via `yadm`; `script/` is a tracked home directory used for bootstrap/ops tasks.”

---

## `script/setup` migration plan

### Current behavior

Today `script/setup`:

- installs OS/bootstrap dependencies
- applies dotfiles via `chezmoi init --apply bry-guy`
- persists optional Brew profile selection
- applies Brew profile/manifests
- adds SSH known_hosts entries

### New behavior under yadm

Under `yadm`, tracked files are already placed in `$HOME`, so `script/setup` should no longer deploy dotfiles.

### Required changes

#### Remove

- `chezmoi init --apply bry-guy`
- any language implying dotfiles are applied from a separate source checkout

#### Keep

- OS and package bootstrap
- Brew profile validation
- Brew profile persistence to `~/.config/dotfiles/brew-profile`
- optional Brew profile application
- `known_hosts` bootstrap
- final post-setup checklist

#### Add or clarify

- assert repo is present and being run from a git/yadm checkout
- create local config directories only when needed
- optionally create **stub** local identity files if missing, or print precise instructions
- document that tracked files already exist once the repo is cloned via yadm

### Recommended new contract for `script/setup`

> Given this repo is already installed into `$HOME` via `yadm`, bootstrap the machine so the tracked config is usable.

### Suggested v1 implementation rule

Keep `script/setup` explicit and manual. Do **not** initially rely on yadm bootstrap hooks, alternates, or encryption.

That keeps the migration simple and observable.

---

## Local-only file policy under yadm

### Keep tracked

- `.gitconfig`
- `.ssh/config`
- `.zshrc`
- `.tmux.conf`
- `.config/**`
- `.pi/agent/settings.json`
- `script/**`
- other non-secret shared files

### Keep untracked

- `.gitconfig.identity.local`
- `.gitconfig.identity.work`
- `.ssh/config.identity`
- any generated pubkey selectors if machine-specific
- any future secret env files

### Why this still works

This mirrors the current include-based identity model:

- tracked `.gitconfig` includes `~/.gitconfig.identity.local`
- tracked `.gitconfig` conditionally includes `~/.gitconfig.identity.work`
- tracked `.ssh/config` includes `~/.ssh/config.identity`

Machines that do not provide those files simply do not activate those identities.

---

## `.gitignore` changes needed

At minimum, ensure the yadm repo ignores local-only identity files:

```gitignore
.gitconfig.identity.local
.gitconfig.identity.work
.ssh/config.identity
```

Potentially also ignore other local-only/generated files after review.

---

## Install / bootstrap flow after migration

### New machine

```sh
brew install yadm
cd ~
yadm clone git@github.com:bry-guy/dotfiles.git
~/script/setup personal-macos
```

Or for work:

```sh
~/script/setup work-macos
```

### Existing migrated machine

```sh
yadm pull
~/script/setup
```

### Identity remains separate

Personal:

```sh
~/script/identity-apply personal
```

Work remains machine-local and only on machines that should have it.

---

## Test plan for personal machine

### Functional checks

1. `yadm status` works normally
2. `yadm diff` shows expected tracked changes only
3. `git` / GitHub operations still work
4. `~` is not treated as a normal git repo by tooling
5. `nvim` opens and LSP behavior is unchanged or improved
6. `.ssh/config` works with 1Password agent
7. `script/setup` runs without chezmoi installed or required
8. Brew profile persistence still works
9. `script/identity-apply personal` still writes local untracked files correctly

### Specific git checks

- personal machine should continue to resolve to local/default identity
- Lumora conditional include may exist in `.gitconfig`, but no work identity file should mean no work identity activates here

### Specific shell checks

- fresh shell reads `.zshrc` correctly
- tmux config still loads
- `~/.config/tmux/window-name.sh` remains executable

---

## Rollback plan

If the branch trial fails:

1. keep `master` / default branch on chezmoi layout
2. abandon `yadm-migration` branch or continue iterating
3. continue using chezmoi on all machines

Because the migration is branch-isolated, rollback is just “do not merge”.

---

## File-by-file migration map

This is the current authoritative chezmoi source → target mapping and should be used as the mechanical migration inventory.

```text
AGENTS.md -> AGENTS.md

dot_aliases -> .aliases
dot_aliases_work -> .aliases_work
dot_amethyst.yml -> .amethyst.yml
dot_default-go-packages -> .default-go-packages
dot_default-npm-packages -> .default-npm-packages
dot_detect_arch -> .detect_arch
dot_detect_cloud -> .detect_cloud
dot_detect_os -> .detect_os
dot_fns -> .fns
dot_gitconfig -> .gitconfig
dot_osx -> .osx
dot_tmate.conf -> .tmate.conf
dot_tmux.conf -> .tmux.conf
dot_zprofile -> .zprofile
dot_zsh_plugins.txt -> .zsh_plugins.txt
dot_zsh_work -> .zsh_work
dot_zshenv -> .zshenv
dot_zshrc -> .zshrc

dot_zsh/_git -> .zsh/_git

private_dot_ssh/private_config -> .ssh/config

private_dot_pi/private_agent/settings.json -> .pi/agent/settings.json

private_dot_local/bin/executable_docker -> .local/bin/docker

private_dot_config/alacritty/private_alacritty.toml -> .config/alacritty/alacritty.toml
private_dot_config/alacritty/themes/themes/moonfly.toml -> .config/alacritty/themes/themes/moonfly.toml

private_dot_config/code/extensions.json -> .config/code/extensions.json
private_dot_config/code/keybindings.json -> .config/code/keybindings.json
private_dot_config/code/settings.json -> .config/code/settings.json

private_dot_config/linearmouse/linearmouse.json -> .config/linearmouse/linearmouse.json

private_dot_config/mise/config.toml -> .config/mise/config.toml

private_dot_config/nvim/README.md -> .config/nvim/README.md
private_dot_config/nvim/TODO.md -> .config/nvim/TODO.md
private_dot_config/nvim/init.lua -> .config/nvim/init.lua
private_dot_config/nvim/lazy-lock.json -> .config/nvim/lazy-lock.json
private_dot_config/nvim/ftplugin/c.lua -> .config/nvim/ftplugin/c.lua
private_dot_config/nvim/ftplugin/cpp.lua -> .config/nvim/ftplugin/cpp.lua
private_dot_config/nvim/ftplugin/css.lua -> .config/nvim/ftplugin/css.lua
private_dot_config/nvim/ftplugin/go.lua -> .config/nvim/ftplugin/go.lua
private_dot_config/nvim/ftplugin/html.lua -> .config/nvim/ftplugin/html.lua
private_dot_config/nvim/ftplugin/java.lua -> .config/nvim/ftplugin/java.lua
private_dot_config/nvim/ftplugin/javascript.lua -> .config/nvim/ftplugin/javascript.lua
private_dot_config/nvim/ftplugin/json.lua -> .config/nvim/ftplugin/json.lua
private_dot_config/nvim/ftplugin/kotlin.lua -> .config/nvim/ftplugin/kotlin.lua
private_dot_config/nvim/ftplugin/lua.lua -> .config/nvim/ftplugin/lua.lua
private_dot_config/nvim/ftplugin/markdown.lua -> .config/nvim/ftplugin/markdown.lua
private_dot_config/nvim/ftplugin/php.lua -> .config/nvim/ftplugin/php.lua
private_dot_config/nvim/ftplugin/python.lua -> .config/nvim/ftplugin/python.lua
private_dot_config/nvim/ftplugin/ruby.lua -> .config/nvim/ftplugin/ruby.lua
private_dot_config/nvim/ftplugin/rust.lua -> .config/nvim/ftplugin/rust.lua
private_dot_config/nvim/ftplugin/sh.lua -> .config/nvim/ftplugin/sh.lua
private_dot_config/nvim/ftplugin/swift.lua -> .config/nvim/ftplugin/swift.lua
private_dot_config/nvim/ftplugin/typescript.lua -> .config/nvim/ftplugin/typescript.lua
private_dot_config/nvim/ftplugin/xml.lua -> .config/nvim/ftplugin/xml.lua
private_dot_config/nvim/ftplugin/yaml.lua -> .config/nvim/ftplugin/yaml.lua
private_dot_config/nvim/lua/config/autocmds.lua -> .config/nvim/lua/config/autocmds.lua
private_dot_config/nvim/lua/config/keymaps.lua -> .config/nvim/lua/config/keymaps.lua
private_dot_config/nvim/lua/config/lazy.lua -> .config/nvim/lua/config/lazy.lua
private_dot_config/nvim/lua/config/options.lua -> .config/nvim/lua/config/options.lua
private_dot_config/nvim/lua/plugins/codecompanion.lua -> .config/nvim/lua/plugins/codecompanion.lua
private_dot_config/nvim/lua/plugins/copilot.lua -> .config/nvim/lua/plugins/copilot.lua
private_dot_config/nvim/lua/plugins/dap.lua -> .config/nvim/lua/plugins/dap.lua
private_dot_config/nvim/lua/plugins/folding.lua -> .config/nvim/lua/plugins/folding.lua
private_dot_config/nvim/lua/plugins/goyo.lua -> .config/nvim/lua/plugins/goyo.lua
private_dot_config/nvim/lua/plugins/lint.lua -> .config/nvim/lua/plugins/lint.lua
private_dot_config/nvim/lua/plugins/lsp.lua -> .config/nvim/lua/plugins/lsp.lua
private_dot_config/nvim/lua/plugins/lualine.lua -> .config/nvim/lua/plugins/lualine.lua
private_dot_config/nvim/lua/plugins/moonfly.lua -> .config/nvim/lua/plugins/moonfly.lua
private_dot_config/nvim/lua/plugins/multicursors.lua -> .config/nvim/lua/plugins/multicursors.lua
private_dot_config/nvim/lua/plugins/neogit.lua -> .config/nvim/lua/plugins/neogit.lua
private_dot_config/nvim/lua/plugins/nvim-cmp.lua -> .config/nvim/lua/plugins/nvim-cmp.lua
private_dot_config/nvim/lua/plugins/nvim-treesitter.lua -> .config/nvim/lua/plugins/nvim-treesitter.lua
private_dot_config/nvim/lua/plugins/obsidian.lua -> .config/nvim/lua/plugins/obsidian.lua
private_dot_config/nvim/lua/plugins/oil.lua -> .config/nvim/lua/plugins/oil.lua
private_dot_config/nvim/lua/plugins/remote-nvim.lua -> .config/nvim/lua/plugins/remote-nvim.lua
private_dot_config/nvim/lua/plugins/render-markdown.lua -> .config/nvim/lua/plugins/render-markdown.lua
private_dot_config/nvim/lua/plugins/snippets.lua -> .config/nvim/lua/plugins/snippets.lua
private_dot_config/nvim/lua/plugins/telescope.lua -> .config/nvim/lua/plugins/telescope.lua
private_dot_config/nvim/lua/plugins/tpope.lua -> .config/nvim/lua/plugins/tpope.lua
private_dot_config/nvim/lua/plugins/vim-fugitive.lua -> .config/nvim/lua/plugins/vim-fugitive.lua
private_dot_config/nvim/lua/plugins/wrapping.lua -> .config/nvim/lua/plugins/wrapping.lua

private_dot_config/opencode/AGENTS.md -> .config/opencode/AGENTS.md
private_dot_config/opencode/agent/atlassian.md -> .config/opencode/agent/atlassian.md
private_dot_config/opencode/agent/build-committer.md -> .config/opencode/agent/build-committer.md
private_dot_config/opencode/agent/build-orchestrator.md -> .config/opencode/agent/build-orchestrator.md
private_dot_config/opencode/agent/build-reviewer.md -> .config/opencode/agent/build-reviewer.md
private_dot_config/opencode/agent/build-worker.md -> .config/opencode/agent/build-worker.md
private_dot_config/opencode/agent/github.md -> .config/opencode/agent/github.md
private_dot_config/opencode/agent/plan-orchestrator.md -> .config/opencode/agent/plan-orchestrator.md
private_dot_config/opencode/agent/plan-researcher.md -> .config/opencode/agent/plan-researcher.md
private_dot_config/opencode/agent/plan-writer.md -> .config/opencode/agent/plan-writer.md
private_dot_config/opencode/command/build.md -> .config/opencode/command/build.md
private_dot_config/opencode/command/plan.md -> .config/opencode/command/plan.md
private_dot_config/opencode/config.json -> .config/opencode/config.json

private_dot_config/private_karabiner/assets/private_complex_modifications/1589989027.json -> .config/karabiner/assets/complex_modifications/1589989027.json
private_dot_config/private_karabiner/private_karabiner.json -> .config/karabiner/karabiner.json

private_dot_config/tmux/executable_window-name.sh -> .config/tmux/window-name.sh
```

---

## `script/setup` rewrite checklist

### README / docs

- [ ] rewrite README to describe yadm-managed home layout
- [ ] remove chezmoi-specific wording and commands
- [ ] document new install flow using `yadm clone`

### `script/setup`

- [ ] remove `chezmoi init --apply bry-guy`
- [ ] add/clarify repo checkout expectation
- [ ] keep OS/bootstrap logic intact
- [ ] keep Brew profile handling intact
- [ ] keep known_hosts setup intact
- [ ] clarify that tracked files are already present after `yadm clone`
- [ ] optionally scaffold local identity stubs or print clear next steps

### Repo structure

- [ ] rename all chezmoi-managed files into home-layout paths
- [ ] preserve executable bits for scripts like `.config/tmux/window-name.sh`
- [ ] add/update `.gitignore` for local-only files

### Local identity model

- [ ] verify `.gitconfig` still includes local/work identity files correctly
- [ ] verify `.ssh/config` still includes `.ssh/config.identity`
- [ ] verify personal machine has no work identity file

### Validation

- [ ] `yadm status` / `yadm diff` behave as expected
- [ ] shell config loads
- [ ] nvim config loads
- [ ] tmux config loads
- [ ] GitHub git usage works
- [ ] Lumora include remains inert on personal machine without work identity file

---

## Recommendation

Proceed with the migration on `yadm-migration` by making the structural repo changes next, but do not merge until the personal-machine trial has passed.
