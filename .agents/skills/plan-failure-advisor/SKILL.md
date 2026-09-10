---
name: plan-failure-advisor
description: Consult the configured advisor whenever an unexpected failure occurs while executing an active plan. Use when a planned command, tool call, test, dependency, assumption, merge, or implementation step fails unexpectedly—before retrying, improvising a workaround, bypassing safeguards, changing scope or approach, cleaning up destructively, or abandoning the plan.
---

# Advisor on Plan Failures

An unexpected failure is a decision point, not permission to improvise. Stop before the plan drifts.

## Trigger

When a step in an active plan unexpectedly fails:

1. Gather only the minimal read-only evidence needed for a useful review:
   - the step that failed and its expected result;
   - the exact error or observed result;
   - any partial side effects;
   - the relevant state and user constraints.
2. Call `advisor()` with no parameters immediately.
3. Do not retry, work around, bypass, broaden or narrow scope, switch approaches, perform destructive cleanup, or abandon the plan before consultation.
4. Put the advisor's key guidance in the next visible reply.
5. Reconcile the advice with direct evidence and user constraints, then update the plan or todos before continuing.

If evidence is insufficient, perform only read-only diagnostics before consulting. Do not turn diagnosis into an attempted fix.

## Exceptions

Do not trigger this skill for outcomes identified as expected in advance, such as:

- a deliberately red test;
- a diagnostic probe expected to fail; or
- a command whose documented successful behavior uses a nonzero exit status.

An unexpected form of failure during one of these steps still triggers consultation.

## Guardrails

- Never repeat an unchanged failed action unless the advisor explicitly recommends it.
- Re-consult when a materially different failure appears; do not reuse stale advice.
- Treat advisor guidance as expert review, not authority. Prefer primary evidence and explicit user constraints when they conflict.
- Ask the user when ambiguity remains unsafe to resolve, especially for semantic merge conflicts, credentials, security decisions, data loss, or destructive actions.
- If the advisor is unavailable, state that clearly and proceed only with reversible read-only diagnosis; otherwise stop and ask the user.
