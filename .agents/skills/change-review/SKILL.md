---
name: change-review
description: Review code or documentation changes, working-tree diffs, local branches, stacked branch diffs, tests, and designs. Use when asked to review, audit, critique, simplify, minimize a diff, assess implementation against a design, evaluate test value, or judge readiness. For any GitHub pull-request target, use pr-review first; pr-review may load this skill as its code-review rubric.
---

# Change Review

Review changes for the way a human coworker will understand, validate, and safely merge them. Prioritize correctness and narrow scope, then remove complexity that does not earn its place.

This is not the entry point for a direct GitHub PR or PR-stack review. Use `pr-review` first so unresolved review threads cannot be skipped. Continue here when `pr-review` loads this skill for its general code-review rubric or when the target is not a GitHub PR.

## Establish the target

Identify the intended behavior, invariants, non-goals, and exact comparison boundary before judging implementation.

- **Working tree or branch:** inspect committed and relevant uncommitted changes against the intended base or merge base.
- **Branch stack:** map each branch's base and head, then inspect adjacent diffs.
- **Design:** read both the design and implementation when one exists.

If ambiguity could materially change the verdict, ask. Otherwise state the assumption and proceed.

## Load the matching review mode

Read only the references needed for the request:

| Review shape | Reference |
|---|---|
| Stacked PRs, branch ownership, churn, or stack compression | `references/stack-review.md` |
| Test quality, over-testing, missing coverage, or line reduction | `references/test-value-audit.md` |
| Design critique or implementation-versus-design review | `references/design-conformance.md` |

Several references may apply. Do not load all of them by default. For unresolved GitHub review threads or plans to address/reject PR comments, use the dedicated `pr-review` skill instead.

## Posture

- Inspect the actual diff and surrounding code. Do not trust the author, worker, PR body, or design summary alone.
- Review is read-only by default. Do not edit files, post or draft comments, approve, resolve threads, change PR metadata, or mutate external state unless explicitly authorized and applicable policy allows it.
- Follow repository instructions and documented workflow commands. In Lumora repositories, use `just` recipes.
- Use access that is already connected. If more authorization is needed, stop and ask; never search for credentials or auth material.
- Report realistic, evidence-backed problems triggered by the change. Do not invent theoretical problems merely because defensive handling is possible.
- Prefer the smallest fix that preserves intended behavior and public contracts. State the accepted tradeoff when proposing removal.
- Ask before resolving an unapproved product, architecture, scope, operational, security, or compatibility decision.

## Review workflow

1. Restate the goal, invariants, non-goals, and base in a few concise bullets.
2. Inspect the changed path end to end, including relevant callers, consumers, tests, configuration, and documentation.
3. For broad or risky changes, use independent read-only review lanes when subagents are available: correctness/scope, simplicity/repository fit, and validation/delivery. Give each lane a distinct question and require exact evidence. The parent synthesizes findings.
4. Apply the core rubric and any matching reference.
5. Verify every finding against the current target and disposition it. Do not concatenate speculative or duplicate reviewer output.

## Core rubric

### Scope and intent

- Does every changed line serve the stated goal?
- Are unrelated fixes, speculative flexibility, future-facing options, or new patterns mixed in?
- Does behavior match the design, user decisions, and non-goals?
- Is each change in the correct module, PR, or stack layer?

### Correctness and contracts

- Trace normal, boundary, and failure paths.
- Check relevant API/data contracts, schema and ordering, units, timestamps/time zones, vintage or effective-date selection, null/default behavior, deduplication/idempotency, retries, and compatibility.
- Look for regressions, double counting, stale selection, partial writes, and recovery hazards.
- Verify that fail-fast behavior and fallbacks match actual domain expectations.
- For a mechanical copy or lift, verify provenance and equivalence, then focus detailed review on intentional deltas. Credible parity evidence can carry unchanged copied code.

### Simplicity and diff size

Challenge unnecessary abstraction, duplicate wrappers, one-use helpers, speculative configuration or modes, defensive branches for impossible states, duplicated validation, dead compatibility paths, and deeply nested control flow. Do not remove a useful domain boundary solely to save lines. Name the retained behavior and tradeoff for each material simplification.

### Repository fit and human reviewability

Prefer existing repository patterns. Check names, module ownership, call shape, logging, errors, and tests for human clarity. Flag unfamiliar or esoteric techniques without clear value. When new or changed source-code comments/docstrings are involved, apply the available `code-comments` skill.

### Validation and delivery

Check focused lint/build/test evidence, docs and configuration drift, dependencies, merge conflicts, and mergeability. Distinguish checks actually run from assumptions. For shadow, migration, or cutover work, verify that changed behavior ran in the intended environment and that cutover/rollback boundaries are clear.

## Findings threshold

Prioritize issues worth fixing now or decisions that need explicit disposition. Avoid formatter-enforced nits, generic advice, and hypothetical edge cases with no credible path. For a final pass, report only significant correctness, scope, validation, documentation, dependency, or mergeability issues.

## Output

Start with:

- **Verdict:** ready, ready after fixes, or not ready.
- **Review basis:** target/base, governing design or contract, and validation observed.

For each finding include:

- severity: blocker, important, or optional;
- exact file/line, symbol, PR, or comment reference;
- concrete failure, confusion, or unnecessary complexity;
- why it matters;
- smallest recommended fix or explicit accepted tradeoff.

Finish with:

- **Disposition plan:** fix now, reject, clarify, or defer;
- **Validation:** checks run, results, and checks still needed;
- **Checked with no concern:** only meaningful areas, especially for broad or final audits.

Keep the response concise. Omit generic praise, exhaustive inventories, repeated summaries, and findings that are neither actionable nor decision-relevant.
