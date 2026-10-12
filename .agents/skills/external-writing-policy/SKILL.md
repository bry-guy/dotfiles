---
name: external-writing-policy
description: Apply before any write action in GitHub, Linear, Slack, Notion, or another external service (e.g. `gh pr create --body`, `gh pr edit --body`). Never author or publish external prose for the user.
---

# No External Prose

This is a standing user preference.

Never compose, edit, populate, or publish user-facing prose in an external
service. This includes comments, replies, reviews, messages, and
issue or PR description/body fields. Do not create drafts inside the service, use
templates or `--fill`, or derive prose from commits.

**Once a body or comment field is non-empty — whether the user wrote it,
someone else wrote it, or it was left over from an earlier mistake — it is
never touched again.** No editing, no clearing, no overwriting, no
"fixing" it to be empty in order to comply with this policy after the
fact. Discovering unauthorized prose already sitting in a field (including
prose this agent previously wrote there) is not license to modify that
field — surface it to the user and let them act on it. The only exception
is the empty-body case below, and only while the field is still empty.

**Drafts in the conversation are allowed.** When the user asks, write the
message/comment/description text in the chat (or a local file) for them to
copy and post themselves. What stays forbidden is writing that prose into the
external service — sending, posting, filling a body field, or creating a
draft inside Slack/GitHub/Linear/Notion.

Allowed: read and summarize existing external content; write a PR title; and
create a draft PR with no authored description/body. If a client requires a
body solely to suppress an editor or template, use an explicitly empty value
only, and only at creation time before any content exists. Otherwise stop
and ask the user to do that step.

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

## Screenshots are not prose

Adding image-only content to a PR body is allowed and is not covered by the
"never touched again" rule above — it applies whether the body is currently
empty or already holds a description. Embed each screenshot as bare
markdown image syntax (`![](url)`), nothing else: no caption, no alt text,
no heading, no surrounding sentence, no commentary on what the image shows.
The moment any authored word goes into that body alongside or instead of an
image, the ordinary no-prose rule applies in full.

## Resolving threads is not prose

Resolving a review thread (e.g. `resolveReviewThread`) is a state change, not
authored text — this policy's "never author prose" rule doesn't block it on
its own. It's still a mutation with its own authorization rule, defined in
`pr-review`: resolve a non-Bryan thread only by explicit, current-turn
instruction from Bryan (or a standing durable preference), never by inferring
from code state alone. Resolving still must never come with a reply.
