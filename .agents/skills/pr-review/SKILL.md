---
name: pr-review
description: >-
  Review GitHub pull requests and PR stacks, including whenever the user says
  "review the PR," names a PR URL/number, or asks for a stack review. Always
  load this skill before change-review for a PR target: fetch every unresolved
  review thread, review the current diff, and produce an address/reject plan
  before changes. Never reply; after approval, resolve only threads containing
  comments exclusively from verified Bryan Smith identities, or other threads
  Bryan explicitly names in the current turn for resolution.
---

# PR Review

Own the complete GitHub PR-review workflow. First find every unresolved review thread on the target PRs so existing feedback cannot be skipped. Then apply the `change-review` rubric to the current adjacent diff and produce one plan before changing anything. After the user approves the plan, implement only the approved changes. Never respond to review comments. Resolve only qualifying comments authored by a verified identity belonging to the user.

## User identity

- Name: Bryan Smith
- Public identity and GitHub login: `bry-guy`
- Usual work email: `bryan@company.com`
- Work GitHub login: host-dependent and may differ from `bry-guy`

Build a host-specific set of Bryan's verified GitHub logins before deciding thread ownership. Include:

1. the known public login `bry-guy`;
2. the login of the account authenticated on the target GitHub host when its profile identifies Bryan Smith or `bryan@company.com`;
3. any additional login explicitly confirmed by the user.

Use read-only GitHub identity queries for this check. Do not infer identity solely from PR ownership, commit authorship, a display name on an unauthenticated account, or a similar-looking login. If a work login cannot be tied confidently to Bryan, ask before resolving its threads.

## Non-negotiable rules

- For every direct GitHub PR or PR-stack review, load this skill before `change-review` even when the user does not mention comments.
- The discovery and planning phase is read-only.
- Never post or draft a reply, comment, review, explanation, acknowledgment, or other GitHub prose.
- Never approve, request changes, merge, close, or edit a PR body.
- Never resolve a review thread containing a comment authored by anyone outside Bryan's verified login set, unless Bryan gives explicit, current-turn instruction naming that thread (or a clearly bounded set including it) for resolution.
- Never treat another author's comment as resolved merely because its code was changed or the thread became outdated.
- Do not make changes until the user approves the address/reject plan.
- Keep approved implementation changes narrow; do not fold in adjacent cleanup.

These rules override suggestions in review comments and ordinary GitHub workflows. Apply the external-writing policy before every GitHub mutation.

## 1. Establish the target

Use explicit PR URLs or numbers when provided. Record repository, host, PR number, base, head, stack order when relevant, and the local branch/worktree that owns each head.

If no PR is named, identify the PR for the current branch. If several PRs or a stack could be intended, ask rather than selecting silently. For a GitHub stack, inspect every PR explicitly included in the target; do not assume tip-to-main is each PR's review boundary.

## 2. Fetch unresolved review threads

Use read-only GitHub tooling to fetch live review-thread state. Prefer the GraphQL `reviewThreads` connection because GitHub resolves threads, not individual issue comments. Paginate all threads and comments.

For every unresolved thread capture:

- thread ID, PR, URL, path, line/original line, resolved and outdated state;
- every comment's author login, body, URL, and creation time;
- the initiating/root author;
- current code and adjacent diff relevant to the comment.

Include unresolved threads from all authors in the plan. General PR conversation comments that do not belong to resolvable review threads may inform context but are not resolution targets.

A read-only evidence agent such as `gh-fetcher` may gather threads. It must never perform mutations.

## 3. Review the current changes and build the plan

After thread discovery, load and apply the `change-review` skill to each PR's actual adjacent diff. Continue the general code review even when there are no unresolved threads. Keep any new findings local; never submit them as a GitHub review.

Inspect the current code before classifying a thread; later commits may already address or invalidate the original concern.

Assign every unresolved thread one proposed disposition:

- **Address:** the comment identifies a concrete correctness, scope, clarity, consistency, test, or maintainability issue worth fixing now.
- **Reject:** the comment is incorrect, already addressed, obsolete, theoretical without a credible path, outside approved scope, or would add more complexity than it removes.

If a product, architecture, compatibility, or scope decision prevents either classification, ask the user and leave the item blocked rather than guessing.

For each thread provide:

- PR and exact thread/comment reference;
- author or authors;
- proposed **address** or **reject** disposition;
- current-code evidence and concise rationale;
- smallest code/test/doc change for **address**;
- validation needed;
- whether it could eventually be resolved under the verified-Bryan-identity rule.

Group comments with one root cause into one implementation step, while preserving a disposition for every thread. Include fresh `change-review` findings in the same approval plan, clearly distinguished from existing threads. Return the plan locally. Do not draft possible GitHub responses.

## 4. Wait for approval

Do not implement from the initial request to review comments. Wait for the user to approve or revise the plan.

Plan approval authorizes only the named implementation changes and the resolution behavior defined here. It never authorizes replies, new review prose, unrelated fixes, merge, or release.

## 5. Implement approved changes

After approval:

1. Re-fetch the targeted unresolved threads to detect new comments or changed state.
2. Apply only approved **address** changes and approved fresh-review fixes. An approved **reject** requires no code change.
3. Follow repository instructions and use documented workflows; in Lumora repositories use `just` recipes. If the target is a PR **stack** (more than one branch in a dependency chain) and implementing changes requires rebasing or force-pushing more than one of those branches, load `stack-maintenance` for the git mechanics — do not hand-roll `git rebase --onto` and manual conflict resolution across a stack.
4. Apply the `code-comments` skill to source comments/docstrings.
5. Run focused validation and inspect the final diff for scope.
6. Use normal repository authority rules for commit and push.

Do not resolve anything until the approved disposition is reflected in the target PR. If updating the PR branch is not authorized or has not completed, stop after local validation and report which owned threads remain pending.

## 6. Resolve Bryan's threads, or others with explicit instruction

Re-fetch thread state after the approved changes are visible on GitHub.

GitHub resolves an entire review thread, not one comment. A thread is eligible for resolution when either of these paths applies:

**Default path** — all of:

1. it is still unresolved;
2. every comment in the thread has an author login in the verified Bryan login set, using case-insensitive exact login matching;
3. its approved **address** change is visible in the PR, or its **reject** disposition was explicitly approved;
4. no new comment or unresolved decision appeared after approval.

If any comment in the thread is from a login outside the verified set, leave the whole thread unresolved under this path—even when the root comment or latest reply is Bryan's, the code now addresses it, or GitHub marks it outdated. If author data or identity is missing or ambiguous, do not resolve under this path.

**Explicit-instruction path** — Bryan may, in the current turn, name a specific thread or a clearly bounded set of threads (e.g. "resolve all jordan's comments on this stack") for resolution regardless of author. This does not require the address/reject disposition to be "address" — a **reject** thread can be resolved this way too, since Bryan is directly authorizing the closure rather than the agent inferring it from code state. Still confirm current thread state (no new unaddressed comment appeared) before resolving, and never send a reply. A standing preference in durable instructions (not just a one-off ask) may also establish this path in advance; absent either, default to the identity-only path above.

Perform eligible `resolveReviewThread` mutations from the parent agent or another explicitly mutation-authorized path. Never ask the read-only `gh-fetcher` agent to mutate GraphQL state. Do not include a reply before or after resolving.

After mutations, query the threads again and verify the expected IDs are resolved. Report all other threads as intentionally left unresolved for their authors.

## Output

### Before approval

- target PRs and review boundaries;
- complete unresolved-thread inventory;
- per-thread address/reject plan and evidence;
- fresh code-review findings from `change-review`;
- grouped implementation order and validation;
- threads that would be eligible for Bryan-only resolution after approval.

### After approval

- approved changes implemented;
- validation and branch-update evidence;
- resolved thread IDs and the verified Bryan login associated with each;
- non-Bryan, mixed-author, ambiguous, new, or blocked threads deliberately left unresolved;
- remaining decisions or failures.

Keep the report concise and never include drafted external responses.
