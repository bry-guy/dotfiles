@AGENTS.md

Never add Claude attribution to git commits or PRs.
Do not include "Co-Authored-By: Claude", "Generated with Claude Code", or similar footers.

## Cost-aware Claude Code delegation

**Claude owns serialized work.** The top-level Claude agent is responsible for planning, architecture, tradeoff analysis, serialized implementation, integration, final review, and any explicitly approved staging/prod action. Subagents are an optimization for work that can be handed off without tight, step-by-step Claude judgment — especially independent work that can run in parallel.

**Use `coder` for delegatable, parallelizable implementation packages.** A `coder` task should have a concrete objective, bounded scope, disjoint file ownership, acceptance criteria, and enough supplied context that the coder can execute without rediscovering the whole repository. If the implementation is inherently serialized — one coherent edit/review loop, shared core types, migrations, generated files, broad formatting sweeps, or a sequence where each step depends on Claude inspecting the previous result — Claude should do the work itself instead of delegating to `coder` serially.

**Cost model.** Delegation is not free: each subagent spends its own context and returns a compressed summary. It pays off when it enables parallel progress or keeps noisy implementation churn out of Claude's main context. It loses when the packet plus reintegration is larger than simply doing the serialized work directly.

Hard rules — these are not guidelines:
- NEVER ask subagents to run `--prod`, `--production`, or `--staging`. Claude does so only with explicit user instruction in the current turn. `kubectl` is forbidden for everyone — wrap in `just` or ask the user to paste output.
- NEVER print secrets, tokens, credentials, or auth headers. Redact in all summaries.
- Delegate command-output collection when output would exceed ~500 lines / ~50 KB, or when the work is a multi-step shell pipeline (loops, retries, chained commands). Direct Bash is allowed for single bounded-output commands.
- Subagent output is evidence, not truth. After `coder` completes, Claude MUST inspect the diff before declaring work complete.

### Default routing

Claude should choose the smallest workflow that preserves correctness and context:

| Task pattern | Required first move |
|---|---|
| Serialized implementation, tightly coupled edit/review loop, single coherent change | Claude works it directly |
| Independent implementation packages with disjoint file ownership | `coder`; parallelize when there are multiple packages |
| Mechanical refactor across separable files/modules | split by ownership, then dispatch one or more `coder` tasks |
| Follow-up fix after a `coder` task that stays inside the same delegated package | send back to that `coder` package if still parallel/isolated; otherwise Claude fixes directly after reviewing the diff |
| "review PR", "PR comments", "what did reviewer mean" | `gh-fetcher` gathers PR/comment/diff/check evidence; Claude decides response |
| CI/check failure triage (failed job, log fetch, suspect line lookup) | `gh-fetcher` or `basher` gathers compact evidence; Claude decides fix strategy |
| "where is this defined", "how does this flow", "which files use X" across multiple files | `fetcher` gathers repository/docs evidence |
| Small single-file investigation where Claude needs the content for reasoning | Claude reads it directly |
| "run tests", "lint", "build", "what failed", local Docker/Postgres/Flyway state | `basher` runs narrow command diagnostics when output/noise is the main concern; Claude may run single bounded commands directly |
| Git rescue (stash recovery, reflog spelunking, conflict-state diagnosis, unfamiliar branch state) | `basher` runs read-only inspection first if noisy; Claude decides recovery |
| "logs from staging", "AWS describe/list/get", multi-step AWS pipelines | `remoter` runs read-only AWS via aws-vault `-readonly` profiles |
| merge-conflict resolution | Claude decides and usually applies serialized resolution directly; use `coder` only for disjoint conflict hunks/packages |
| "commit and push" | Claude reviews status/diff directly, then commits/pushes itself |

Do not use `coder` for:
- Ambiguous design/product decisions, final architectural judgment, final review.
- Serialized implementation where Claude needs to inspect and decide after each step.
- Tiny edits where writing the delegation packet costs more than doing the edit.
- Work touching shared core types, migrations, generated files, or broad formatting unless it can be split into non-overlapping packages with a clear integration plan.
- Anything where file ownership overlaps another active `coder` task.

### Delegation packets

Every delegated task MUST include: objective, exact scope, exclusions, stop condition, relevant file paths/symbols, prior findings, acceptance criteria, expected brevity, and the exact command when command output is needed. Ask every agent for `Result / Evidence / Caveats` framing; for `coder`, swap `Evidence` for `Changed files`.

When dispatching `coder`, pass enough context to avoid fetcher-like work: concrete plan, known files/symbols, key constraints, and snippet/line references. If context is missing, run `fetcher` first or ask one concise clarification — do NOT let `coder` rediscover what Claude already knows.

### Parallel delegation

Prefer parallel `coder` only when Claude can assign independent work packages:
- each package has disjoint file/directory ownership
- no shared core types, migrations, generated files, or formatting sweeps
- each package has its own acceptance criteria and optional validation command
- each coder returns changed files, validation readiness, and review notes

Before dispatching parallel coders, Claude should write a brief integration plan: work packages, file ownership, expected merge/review order, and conflicts to avoid. After parallel coders return, Claude must inspect the combined diff, resolve integration issues, and run or request final validation.

**Single-writer invariant**: never run parallel `coder` on overlapping files or shared core types. One file = one writer per turn.

**Structured-output discipline**: when dispatching parallel subagents, require structured returns — bullets, file:line refs, diffs — not narrative prose. Lossy summaries from parallel agents are the failure mode that turns a token win into a correctness loss.

@RTK.md
