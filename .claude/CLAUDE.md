@AGENTS.md

Never add Claude attribution to git commits or PRs.
Do not include "Co-Authored-By: Claude", "Generated with Claude Code", or similar footers.

## Cost-aware Claude Code delegation

Claude owns planning, architecture, tradeoffs, implementation, integration, final review, and any explicitly approved write or operational action. Subagents are read-only context-isolation tools: use them when investigation or command output would add substantial noise to Claude's main context, not for tiny tasks.

Hard rules:
- Never ask subagents to run `--prod`, `--production`, or `--staging`. Claude may do so only with explicit user instruction in the current turn.
- `kubectl` is forbidden for Claude and all subagents; use a documented `just` recipe or ask the user for output.
- Never print secrets, tokens, credentials, private keys, auth headers, or full environment dumps.
- Subagents must not consult the advisor; they return uncertainty to Claude.
- Delegate command-output collection when output would exceed about 500 lines / 50 KB or requires loops, retries, or multi-step pipelines. Claude may run bounded commands directly.
- Treat subagent output as evidence, not final judgment.

### Routing

| Task | Agent |
|---|---|
| Multi-file repository exploration, dependency tracing, or public docs research | `fetcher` |
| GitHub/GHE PR metadata, comments, review threads, diffs, or checks | `gh-fetcher` |
| Local tests, lint, builds, logs, ports, Docker/Postgres/Flyway state, or command-output summaries | `basher` |
| Read-only AWS logs and describe/list/get diagnostics through `aws-vault` readonly profiles | `remoter` |
| Planning, implementation, fixes, architecture, final review, commits, pushes, or external writes | Claude directly |
| Small bounded read or command whose output Claude needs for reasoning | Claude directly |

These agents intentionally share a compact `Result / Evidence / Caveats` contract but do not share privileges: `fetcher` reads files and public docs, `gh-fetcher` runs authenticated read-only `gh`, `basher` runs constrained local commands, and `remoter` runs constrained read-only AWS commands. Do not merge their responsibilities during delegation.

### Delegation discipline

Give each subagent a specific question, exact scope, stop condition, relevant paths or identifiers, expected brevity, and an exact command when command output is required. Use an `@agent` mention when the agent must run; ordinary prose leaves delegation to Claude. Prefer direct work when preparing and reintegrating the delegation would cost more context than the task itself.

@RTK.md
