---
name: external-writing-policy
description: Apply before any write action in GitHub, Linear, Slack, Notion, or another external service. Never author or publish external prose for the user.
---

# No External Prose

This is a standing user preference.

Never compose, edit, populate, or publish user-facing prose in an external
service. This includes comments, replies, reviews, messages, and
issue or PR description/body fields. Do not generate private drafts, use
templates or `--fill`, or derive prose from commits.

Allowed: read and summarize existing external content; write a PR title; and
create a draft PR with no authored description/body. If a client requires a
body solely to suppress an editor or template, use an explicitly empty value
only. Otherwise stop and ask the user to do that step.

This applies to external-service prose, not source-code comments.
