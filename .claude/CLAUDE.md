Never add Claude attribution to git commits or PRs.
Do not include "Co-Authored-By: Claude", "Generated with Claude Code", or similar footers.

## Cost-aware Claude Code delegation

The top-level Claude agent is responsible for planning, architecture, tradeoff analysis, final review, and any explicitly approved staging/prod action.

Use `fetcher` for compact context capsules:
- multi-file repository search/read
- docs or web lookup
- dependency tracing
- diagnostic `just` commands
- summarizing noisy output before planning/review

Use `coder` for implementation only after Claude has a concrete plan:
- scoped code changes
- mechanical refactors
- tests/validation when expected behavior is specified

Do not ask subagents to run `--prod`, `--production`, or `--staging`; Claude may do so only with explicit user instruction.

When delegating, provide:
- objective
- scope
- exclusions
- relevant facts, file paths, symbols, and prior findings Claude has already gathered
- exact command or command family if command output is needed
- stop condition
- expected brevity

Prefer these delegation packets:

Fetcher packet:
- Question to answer, with success criteria
- Starting paths/symbols/search terms
- Allowed command, if command output is needed
- Exclusions and stop condition
- Output limit: compact `Result / Evidence / Caveats`; no full code maps unless requested

Coder packet:
- Objective and exact edit scope
- Allowed files/directories and files/directories to avoid
- Known context: relevant symbols, snippets, prior fetcher findings, and constraints
- Acceptance criteria
- Validation instruction: either exact narrow command(s), or "do not run validation"
- Stop condition: finish assigned edits only, then return `Changed / Validation readiness / Review notes`

When dispatching `coder`, pass enough relevant context to minimize fetcher-like work by the coder: concrete plan, known files/symbols, key constraints, prior fetcher findings, and any important snippets or line references already discovered. Do not ask coder to read whole plans/docs or rediscover the repository unless the task is explicitly a targeted read of a named section. Coder should generally make the assigned edits and return promptly; Claude decides integration, linting, testing, and review strategy unless validation was explicitly delegated.

Split implementation before delegating when the work spans multiple concepts, broad refactors, generated/schema/API changes, or more than a few files. Each coder task should be small enough to complete without hitting its turn limit and should have clear file ownership. Lower-level packages are better than one broad "implement feature" prompt.

Bundle related low-judgment fact-gathering into one `fetcher` task instead of many tiny subagent calls. Do not delegate tiny one-file checks, ambiguous design/product decisions, final architectural judgment, or final review.

Good/bad examples:
- Bad coder task: "Implement the availability summary backend; read the plan and run tests."
- Good coder task: "Edit only `DefaultDataReader.java` and `GeneratorAvailabilitySummaryRow.java`. Add fields X/Y/Z following the existing load-summary mapping pattern. Use these known symbols: ... Do not run validation; return changed files and compile-risk notes."
- Bad fetcher task: "Explore availability fixtures."
- Good fetcher task: "Find one existing integration-test fixture that inserts generator availability data. Return path, helper method names, and setup command only; stop after the first usable fixture."

Treat subagent output as evidence, not truth. After `coder` completes, Claude must inspect/review before declaring work complete.

### Parallel delegation

Prefer parallel subagents when work is independent and context-bounded.

Parallelize freely for `fetcher` tasks when investigations are independent, such as separate modules, APIs, frontend consumers, docs, tests, or logs.

Parallelize `coder` only when Claude can assign disjoint ownership:
- each coder gets a concrete work package
- each package lists allowed files/directories
- no two coders edit the same file or tightly coupled code path
- each package has its own acceptance criteria and validation command, if validation should be run by that coder
- each coder returns changed files, validation readiness, and review notes

Do not parallelize coders when the work shares core types, migrations, broad refactors, generated files, formatting-only sweeps, or unclear ownership. In those cases, use one coder serially or have fetchers map the work first.

Before dispatching parallel coders, Claude should write a brief integration plan: work packages, file ownership, expected merge/review order, and conflicts to avoid. After parallel coders return, Claude must inspect the combined diff, resolve integration issues, and run or request final validation.
