# Design Conformance

Use this mode to critique a design, validate it against current code and operational reality, or review implementation against an approved design.

## Establish the contract

Extract the design's goals, invariants, non-goals, user-owned decisions, public contracts, rollout assumptions, and claimed current-state facts. Resolve chronology: an earlier design step may intentionally establish behavior relied on later.

## Check design against reality

Inspect the load-bearing code, configuration, data flow, and repository conventions. Verify factual claims about current behavior, dependencies, schemas, job/task flow, deployment, retry behavior, and consumer contracts. Mark claims as supported, incorrect, ambiguous, or unverified.

Challenge:

- flexibility, metadata, abstractions, or defensive behavior for states made impossible by existing invariants;
- hidden coupling and missing inputs/consumers;
- unresolved selection, identity, retry, migration, backfill, or cutover semantics;
- scope that solves adjacent problems rather than the stated problem;
- branch slices that require a junior implementer to invent interfaces or behavior;
- documentation that promises validation or safety the implementation cannot provide.

## Check implementation against design

Review both directions:

1. design requirements missing or incorrectly implemented;
2. implementation behavior, options, or complexity not justified by the design.

Prefer minimal corrections. Do not expand scope to solve every discovered adjacent footgun. Record important out-of-scope risks explicitly.

## Output

Provide a concise verdict, prioritized correctness/footgun concerns, unnecessary complexity, unresolved decisions, and the smallest design or implementation corrections. When asked for document edits, preserve the user's structure and make minimal diffs unless a structural flaw requires more.
