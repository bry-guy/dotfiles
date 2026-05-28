---
description: Crunch an implementation plan by applying requested simplifications
argument-hint: "<simplification instructions and optional plan path>"
---

Crunch a target implementation plan by applying the user's simplification instructions, then re-emit the full revised plan. Do not edit files unless explicitly asked to update a written plan.

User simplification instructions / plan reference: $ARGUMENTS

Rules:

- Use the specified plan path, or the previous inline/written plan from the conversation.
- If no target plan is identifiable, ask for the plan/path.
- If simplification instructions are missing or ambiguous, ask a clarifying question.
- Apply the requested simplification directly; do not merely recommend options.
- Keep the original base plan name and increment the trailing iteration number by 1.
- Every revised plan item must be strictly required. No extras.
- Preserve necessary complexity; simplification means less accidental complexity, not always less work.
- Do not include a briefing unless explicitly asked; use `/briefing` for that.

Output format:

0. Plan metadata: `name: <same-base-name>-<incremented-iteration>`
1. Problem summary
2. Constraints / invariants to preserve
3. Implementation plan: step-by-step with file paths and useful snippets
4. Tests / verification
5. Rollout / risk notes, if relevant
6. If phased: phase list with `depends_on` metadata and parallelization notes
