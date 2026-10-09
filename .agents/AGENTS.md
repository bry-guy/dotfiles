# Global Agent Instructions

Shared by pi (`~/.pi/agent/AGENTS.md` symlinks here) and Claude Code (`~/.claude/CLAUDE.md` imports this). Edit only this file.

## General

- Prefer project-local `AGENTS.md` / `CLAUDE.md` instructions closer to the working directory when they are more specific.
- Use the repository's documented workflow commands instead of lower-level build/test tools. Work machines (`~/.config/dotfiles/identity-profile` = `work`, which sets `WORK=1` in `~/.zshrc`) use `just` recipes (`just --list`); personal machines use `mise` tasks (`mise tasks`). A repo's own docs win over this default.
- Confirm with the user before changing a project's `AGENTS.md` / `CLAUDE.md`.
- Never add AI attribution to commits or PRs: no "Co-Authored-By: Claude", "Generated with …", or similar footers.
- Machine-local tool activation may wrap project workflow commands, but project workflow commands must not invoke machine-local tool activation.
  - Local environment/tool managers may run `just`.
  - `justfile` / `justfile.local` recipes call underlying tools directly and assume required tools are on `PATH`.
  - AWS credential wrappers belong outside `just` unless the project documents otherwise.
- Ask before installing tools or changing machine-global configuration. Keep machine-local tool config local-only unless asked to commit it.

On work machines, load the `work-policies` skill before touching remote environments, clusters, or credentials.

## Token economy and delegation

Every main-thread tool call resends the full conversation, so main-thread tool calls are the most expensive thing you do. You own decisions, planning, integration, final edits, commits, pushes, and external or privileged actions; delegate evidence gathering.

- Delegate costly-but-simple work to cheap subagents: exploration needing 3+ searches/reads, dependency tracing, logs/tests/builds/lint output, GitHub/AWS reads, docs lookups, mechanical multi-file edits. Run independent ones in parallel; use a matching agent proactively.
- Brief subagents completely (paths, goal, what's known) and demand a short return, e.g. "reply in under 150 words: file:line refs and the answer only." Don't pass the whole conversation to a subagent unless the task truly needs it.
- Work directly only when the answer is already in context or needs one trivial, precisely known read or an obvious edit.
- Treat subagent output as evidence, not judgment; don't repeat an investigation unless it was incomplete or contradictory. Subagents stay read-only outside scratch space, never consult the advisor, and return uncertainty to the parent.
- When you must do it yourself, batch several reads/greps/commands into one call and return only filtered results (pi: `codemode`). Don't dump large outputs into context; filter them (`rg -l`, `head`, ranged reads).

Agent routing (same agent names in both; spawn via the subagent tool: `subagent` in pi, `Agent` in Claude Code):

| Work | Agent |
|---|---|
| Evidence gathering: repo exploration, dependency tracing, tests/builds/logs, GitHub PR data, read-only AWS, public docs | `Explore` |
| Multi-step research or command work needing judgment between steps | `general-purpose` |
| Plan-mode research (built-in, main model); plan review is the advisor's job | `Plan` |

On work machines, Claude Code subagents' Bash is enforced by `~/.claude/hooks/lumora-subagent-bash-guard.sh` (Claude only; pi has no guard).

For any GitHub PR or PR-stack review, load `pr-review` first so unresolved threads are gathered before applying the `change-review` rubric.

## Advisor

Follow the `advisor-discipline` skill for when to consult the advisor; load it when drafting a plan for multi-step work. Default: one review of the plan before execution, none to confirm completion.
