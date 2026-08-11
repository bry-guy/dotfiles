@AGENTS.md

Never add Claude attribution to git commits or PRs.
Do not include "Co-Authored-By: Claude", "Generated with Claude Code", or similar footers.

## Subagent-first workflow

Claude owns decisions, planning, edits, integration, final review, commits, pushes, and external or privileged actions. Use repository-read-only subagents by default to gather and verify evidence.

- Before planning or editing a non-trivial task, delegate any missing repository, command, GitHub, documentation, or AWS evidence.
- When an agent's scope matches, use it proactively without waiting for the user to request delegation.
- Run independent investigations in parallel.
- Ask narrow questions and request compact evidence.
- Use returned evidence without repeating the same investigation unless it is incomplete or contradictory.
- Work directly only when the answer is already in context or requires one trivial, precisely known read.
- When uncertain whether delegation is worthwhile, delegate.

### Routing

| Evidence needed | Agent |
|---|---|
| Repository exploration, dependency tracing, or public documentation | `fetcher` |
| Local tests, builds, diagnostics, logs, or command output | `basher` |
| GitHub/GHE PRs, comments, diffs, reviews, or checks | `gh-fetcher` |
| Read-only AWS diagnostics | `remoter` |

Keep agents least-privileged and read-only outside throwaway scratchpads. Claude makes all judgments and performs all repository or external writes. Treat subagent output as evidence, not final judgment.

### Hard rules

- Never ask subagents to run `--prod`, `--production`, or `--staging`. Claude may do so only with explicit user instruction in the current turn.
- `kubectl` is forbidden for Claude and all subagents; use a documented `just` recipe or ask the user for output.
- Never expose secrets, tokens, credentials, private keys, auth headers, or full environment dumps.
- Subagents must not consult the advisor; they return uncertainty to Claude.

@RTK.md
