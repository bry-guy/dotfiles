---
name: advisor-discipline
description: When to call the advisor (a costly stronger-model review that resends the whole conversation). Use when drafting a plan for multi-step work, facing a consequential ambiguous decision, or when a planned step fails unexpectedly.
---

# Advisor Discipline

Each advisor call resends the entire conversation to a stronger model. Treat it as expensive: a few calls per day, not per task.

## Call it

- **Plans:** once, after drafting the plan for non-trivial multi-step work and before executing it.
- **Decisions:** once, before answering, when a choice is both consequential (architecture, data, security, money, hard to reverse) and genuinely ambiguous.
- **Failures:** only when the fix would change scope or approach, bypass a safeguard, or be destructive; or after two distinct fix attempts failed.
- **Irreversible steps:** before a destructive or irreversible action not already covered by a reviewed plan.

## Don't call it

- For routine, mechanical, or clearly specified work.
- To confirm a task is done, or to re-review a settled plan.
- For preference questions you can answer with stated tradeoffs, factual lookups, or choices forced by user constraints or tool output.
- For obvious failures (typo, wrong path, missing flag): fix them and continue.
- From subagents: they return uncertainty to the parent instead.

## Failure rules (always, advisor or not)

- An unexpected failure is a decision point, not permission to improvise. Diagnose read-only first.
- Never repeat an unchanged failed action.
- Don't silently change scope, bypass safeguards, or clean up destructively.
- Ask the user about credentials, security, data loss, or semantic merge conflicts.

## Using the result

Put the advisor's key guidance in your next visible reply. It is review, not authority: prefer primary evidence when they conflict. If the advisor is unavailable, say so and proceed only with safe, reversible steps.
