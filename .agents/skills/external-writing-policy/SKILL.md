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

## PR titles

Use a conventional-commit-style action and a short title of five to ten words:

```text
$action: $ticket | $short_title
```

Use a lowercase action such as `fix`, `feat`, `refactor`, `test`, `docs`, or
`chore`; a more precise domain action such as `schema` is also valid. Use the
Linear ticket clearly associated with the work, preserving its canonical key.
Do not guess or invent a ticket.

If no Linear ticket is obviously associated, explicitly complain to the user
that the work lacks one, then omit both the ticket and separator:

```text
$action: $short_title
```

This applies to external-service prose, not source-code comments.
