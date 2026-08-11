# Test-Value Audit

Use this mode when the user questions test value, readability, over-testing, missing coverage, brittleness, or test-driven diff size.

## Governing question

For every test or coherent test group, ask: **what regression, contract, or invariant does this protect?** If that answer is unclear, investigate whether the test earns its setup and maintenance cost.

## Keep

Prefer tests that protect:

- behavior introduced by the change;
- public API, schema, ordering, serialization, or publication contracts;
- important domain invariants and realistic edge cases;
- failure behavior that must remain fail-fast or recoverable;
- risky integration boundaries;
- credible parity between a mechanical lift/refactor and established output.

## Challenge

Look for:

- duplicate tests or parameterizations;
- many assertions where only one or two express the test's purpose;
- setup that exists solely for low-value assertions;
- implementation-detail, call-shape, YAML-shape, or mock-heavy tests that do not protect observable behavior;
- tests for unchanged behavior already covered in a lower branch or existing suite;
- brittle coupling to helper structure, ordering that is not contractual, or incidental error text;
- several validation mechanisms that buy the same confidence;
- missing high-value coverage hidden by a large quantity of low-value tests.

Prefer the simplest credible validation. When output parity or a realistic integration check proves the goal, do not also deeply test every internal input unless it protects a distinct risk.

## Classification

Classify recommendations as:

- **Keep:** clear, distinct value.
- **Cut:** safely removable with rationale and risk.
- **Consolidate:** preserve behavior with less duplication/setup.
- **Move:** belongs in a different stack layer because that layer owns the behavior.
- **Add:** missing, high-value coverage only.

## Output

Report PR by PR when reviewing a stack. Name exact files and tests, explain value or lack of value, call out readability/naming and brittleness, and estimate safe line reduction where practical. Do not propose additional tests merely because coverage could be broader.
