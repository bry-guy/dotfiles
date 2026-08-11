# Stack Review

Use this mode for stacked PRs, branch ownership, diff-size reduction, churn, or merge readiness across several dependent changes.

## Map the stack

For every PR or branch, establish:

- base and head;
- adjacent diff, not only tip-to-main diff;
- conceptual goal and explicit non-goals;
- dependency on lower and higher layers;
- changed-line size and repository/user size target when one exists;
- checks, review state, conflicts, and mergeability.

## Review each adjacent layer

Check that each PR introduces one understandable concept and contains everything required for that concept—without unrelated work from later layers. Identify:

- APIs, names, tests, configuration, or docs introduced and immediately revised later;
- code added in one layer and removed or replaced in another;
- tests or documentation placed before or after the behavior they describe;
- duplicated scaffolding, configuration, and validation across layers;
- hidden dependencies that make a supposedly independent PR unsafe;
- reasonable seams for compression or splitting.

Do not recommend moving lines merely to improve a statistic. Recommend a move only when ownership, independent deployability, or human reviewability improves.

## Mechanical lifts

For a copy/lift PR, establish exact provenance and characterize intentional deviations. If parity evidence credibly validates unchanged behavior, focus human review on the deviations, boundary changes, and parity mechanism rather than demanding line-by-line re-review of copied code.

## PR bodies

Treat each body as a short guide for parsing that adjacent diff. It should accurately state the goal, important concepts, simple algorithm, validation, and stack dependency. It should not narrate implementation line by line or include behavior owned by another PR.

## Output

Provide:

1. a compact stack map;
2. per-PR verdict, scope, size, dependency, and findings;
3. cross-stack churn or ownership findings;
4. recommended compression/split options with tradeoffs;
5. merge order and remaining blockers.
