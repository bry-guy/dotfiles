---
name: code-comments
description: Govern source-code comments and docstrings. Use whenever adding, editing, generating, or reviewing a code comment or docstring, including during implementation and code review, even when the user simply asks to explain code with comments. Do not use for PR review comments, prose documentation, or changelogs.
---

# Code Comments

Treat a source-code comment as an exception. Prefer code whose names and structure communicate what it does. Keep comments only when they preserve important reasoning that the code cannot express clearly.

## Mandatory gate

Before adding or retaining any new or changed comment or docstring, ask these questions in order.

### 1. Can better naming remove the need?

First consider renaming the variable, function, type, parameter, intermediate value, or helper so the code explains itself. If a small naming improvement makes the comment unnecessary, make or recommend that change and omit the comment.

Do not casually rename a public or compatibility-sensitive API merely to avoid documentation; account for its contract first.

### 2. Is it redundant?

Check the code, types, tests, nearby comments, and enclosing docstring. Omit a comment that repeats:

- what the next line does;
- information already expressed by a name or type;
- another nearby comment or docstring;
- an implementation detail that is obvious from the control flow.

Consolidate duplicated reasoning into the narrowest useful location rather than restating it.

### 3. Does it follow nearby comment conventions?

Inspect the same file and nearby related files. Match the established form and density of commentary. For example, if the surrounding code documents functions only with docstrings, do not introduce scattered line comments for equivalent explanations. If nearby code intentionally has almost no comments, require a strong reason to add one.

Do not invent a new comment style or documentation layer for one change.

### 4. Can multiline prose become a short example?

If the comment is longer than one line, consider whether a concise example communicates the non-obvious behavior more clearly. Prefer a small input → output, timeline, boundary, or domain example over a paragraph when it preserves the essential reasoning.

Do not add an example when better naming or deletion already solves the problem.

### 5. Does it explain why rather than how?

A useful comment explains a constraint, tradeoff, domain rule, counterintuitive choice, external contract, or reason a simpler-looking approach is wrong. It should explain **why this implementation is necessary**, not narrate how the code executes.

Avoid comments that preserve development chronology, defend needless complexity, restate syntax, label obvious sections, or compensate for unclear code that should be simplified.

## Exceptions

Required license headers, generated-code markers, tool directives, and contractual public-API documentation may be necessary. Keep them in their required form, but do not use the exception to justify unrelated prose.

## Reviewing comments

For each new or changed comment, recommend one of:

- **Omit:** naming, structure, types, or nearby documentation already explains it.
- **Rename/refactor:** make the code self-explanatory and remove the comment.
- **Keep:** it captures important why-level reasoning that code cannot express.
- **Rewrite:** preserve the reason with less prose or a short example.

When edits are authorized, apply the smallest resulting change. Otherwise return the exact recommendation and, for **keep** or **rewrite**, the concise proposed wording.
