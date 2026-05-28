---
description: Create an implementation plan for the current problem
argument-hint: "[problem or requested changes]"
---

Create an implementation plan for the current problem. Do not implement.

User context / requested adjustments: $ARGUMENTS

Rules:

- Solve only the problem at hand. Every plan item must be strictly required. No extras.
- Inspect relevant files as needed; prefer concrete file paths and existing APIs over speculation.
- Give every plan one name: `short-kebab-case-name-<iteration>`. New plans start at `-0`; revisions keep the base name and increment the suffix.
- Include small snippets/pseudocode for important code intent.
- Return the full plan inline unless the user explicitly asks for a written plan, or the plan is phased due to complexity.
- Write phased plans to `docs/plans/` and include `depends_on:<phase>` plus parallelization notes.
- Avoid phasing unless it substantially de-risks complex work that builds on itself.
- Do not include a briefing unless explicitly asked; use `/briefing` for that.

Output format:

0. Plan metadata: `name: <short-kebab-case-name>-<iteration>`
1. Problem summary
2. Constraints / invariants to preserve
3. Implementation plan: step-by-step with file paths and required snippets
4. Tests / verification
5. Rollout / risk notes, if relevant
6. If phased: phase list with `depends_on` metadata and parallelization notes
