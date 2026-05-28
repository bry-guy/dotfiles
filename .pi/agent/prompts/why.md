---
description: Generate design-critique questions for the current branch
argument-hint: "[extra focus]"
---

Generate only questions about the current branch. Do not edit files.

Extra focus: $ARGUMENTS

Inspect the branch diff against `origin/main` if available, otherwise `main`. Identify meaningful design decisions: abstractions, API shapes, nullability, constructor signatures, data flow, tests, error handling, naming, and boundary behavior.

Output rules:

- Output only a numbered list of pointed design questions.
- Each item must be a question ending in `?`.
- Ask about simpler alternatives, invalid states, pushed-down complexity/optionality, test-driven API compromises, and unchecked DB/API/domain assumptions where relevant.
- Do not include findings, explanations, recommendations, compliments, conclusions, or answers.
