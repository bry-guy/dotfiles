@AGENTS.md

Never add Claude attribution to git commits or PRs.
Do not include "Co-Authored-By: Claude", "Generated with Claude Code", or similar footers.

## Subagent-first workflow

Claude owns decisions, planning, edits, integration, final review, commits, pushes, and external or privileged actions. Use repository-read-only subagents by default to gather and verify evidence.

- Before planning or editing a non-trivial task, delegate any missing repository, command, GitHub, documentation, or AWS evidence.
- When an agent's scope matches, use it proactively without waiting for the user to request delegation.
- For any GitHub PR or PR-stack review, load `pr-review` first so unresolved threads are gathered before applying the `change-review` rubric.
- Run independent investigations in parallel.
- Ask narrow questions and request compact evidence.
- Use returned evidence without repeating the same investigation unless it is incomplete or contradictory.
- Work directly only when the answer is already in context or requires one trivial, precisely known read.
- Delegate bounded evidence gathering when it is multi-file, parallel, or independently verifiable; keep obvious one-step work local.

### Routing

| Evidence needed | Agent |
|---|---|
| Repository exploration, dependency tracing, or public documentation | `fetcher` |
| Local tests, builds, diagnostics, logs, or command output | `basher` |
| GitHub/GHE PRs, comments, diffs, reviews, or checks | `gh-fetcher` |
| Read-only AWS diagnostics | `remoter` |

Keep agents least-privileged and read-only outside throwaway scratchpads. Claude makes all judgments and performs all repository or external writes. Treat subagent output as evidence, not final judgment.

### Review cadence

Use the configured Opus advisor at phase boundaries, not continuously:

- For non-trivial work, get one review of the investigation or implementation plan before execution. A design review can satisfy this review when the design is the unsettled part.
- Get one review after substantive code changes and validation. Trivial or purely mechanical edits are exempt.
- Reconsult only after a material plan change or repeated failed approaches. Skip trivial, reversible, already-settled work.
- Keep advisor reviews focused on judgment and tradeoffs; the advisor does not run tools, edit files, or replace tests.

Delegate evidence gathering to Haiku agents for repository exploration, dependency tracing, logs, tests, builds, lint, GitHub/AWS reads, and public documentation. Do not delegate a one-step read, an obvious edit, or work already in context.

### Hard rules

- Never ask subagents to run `--prod`, `--production`, or `--staging`. Claude may do so only with explicit user instruction in the current turn.
- `kubectl` is forbidden for Claude and all subagents; use a documented `just` recipe or ask the user for output.
- Never expose secrets, tokens, credentials, private keys, auth headers, or full environment dumps.
- Subagents must not consult the advisor; they return uncertainty to Claude.

@RTK.md
