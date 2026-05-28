---
description: Review the current branch as a PR against main
argument-hint: "[extra focus]"
---

Review the current branch as if it were a PR against `main`. Do not edit files.

Extra focus: $ARGUMENTS

Process:

1. Determine the merge base against `origin/main` if available, otherwise `main`.
2. Inspect the branch diff, changed files, and relevant surrounding code.
3. Review for correctness, simplicity, tests, repo invariants, and pattern docs relevant to changed code.
4. Include design-pressure from `/why`: question meaningful decisions and alternatives.

Output concise findings only:

- Blockers: must fix before merge.
- Should fix: important but not necessarily blocking.
- Consider: simplification or design questions.
- Looks good: briefly mention important checks that passed.

For each finding, include file path, reason, and concrete recommended change.
