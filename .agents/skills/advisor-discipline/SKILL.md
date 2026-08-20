---
name: advisor-discipline
description: Consult the configured advisor whenever the user asks for a recommendation, judgment, options, tradeoffs, prioritization, or a choice the agent must make on the user's behalf. Use for "should I", "which", "give me options", "recommend", and similar decision-support requests.
---

# Advisor for Decisions

Treat decision-support requests as advisor triggers, not ordinary execution requests.

Call `advisor()` with no parameters before:

- answering “should I…?”, “which…?”, “what would you choose?”, “give me options”, or “recommend…”;
- selecting among multiple reasonable implementations, priorities, tools, designs, or next steps for the user; or
- making a judgment the user delegated instead of following explicit instructions.

First gather enough context for a useful review, but call the advisor before committing to the recommendation or implementation. For longer work, consult again if the decision changes, evidence conflicts, or the result is ready for review.

Do not call it for purely mechanical instructions, settled factual lookups, or choices forced by explicit user constraints or tool output. Treat its result as review rather than authority: reconcile conflicts with evidence, and include its key guidance in the next visible reply. If the advisor is inactive or unavailable, say so and proceed only when it is safe to do so without the review.
