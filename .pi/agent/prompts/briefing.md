---
description: Brief the previous inline or written implementation plan
argument-hint: "[plan path or briefing focus]"
---

Create a concise briefing for a target implementation plan. Do not edit files.

User focus / plan reference: $ARGUMENTS

Use the specified plan path, or the previous inline/written plan from the conversation. If no plan is identifiable, ask for the plan/path. Honor ad-lib focus such as `/briefing focus on rollout risk`.

Output format:

- Objective: one sentence.
- Core approach: 2-4 bullets.
- First step: immediate next implementation action.
- Key risks / watchouts: concise bullets.
- Dependencies / sequencing: phases or `depends_on` relationships if present.
- Verification: most important tests/checks.
- Decision points: unresolved choices, if any.

Keep it concise. Do not restate the full plan.
