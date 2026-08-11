# Reviewer-Comment Triage

Use this mode for existing PR review comments, threads, or user-authored comments that need an address/reject/clarify plan.

## Gather current evidence

Read every requested comment and inspect the current diff and surrounding code. Account for later commits: a comment may already be addressed, partially addressed, or obsolete. Review comments are evidence, not authority.

## Classify each comment

- **Address:** identifies a concrete correctness, scope, clarity, consistency, or maintainability issue worth fixing now.
- **Reject:** incorrect, already covered, theoretical without a credible path, contrary to approved scope, or costs more complexity than it removes.
- **Clarify:** depends on a product, architecture, contract, or intent decision that is not established.

For each classification provide:

- exact comment and code reference;
- current-code evidence;
- concise rationale;
- smallest proposed change for **address**;
- concise reason and tradeoff for **reject**;
- exact question or decision needed for **clarify**.

Check whether several comments share one root cause and can be handled by one fix. Distinguish code changes from explanation-only feedback.

## Authority

Return a plan first. Do not post replies, submit reviews, approve, resolve threads, or otherwise mutate external state unless the user explicitly authorizes that specific action and applicable external-writing policy permits it.

## Output

Use a compact per-comment table or list followed by an ordered implementation and validation plan. Avoid drafting external responses.
