---
name: pr-screenshots
description: Use for any UI-change PR approval — write a manual click-through script for the user to run themselves, then process the screenshots they capture into ~/Desktop/prs/<PR#>/n.jpg and embed them image-only into the PR body.
---

# PR screenshots

When a PR changes UI, the user clicks through the app themselves and takes
the screenshots — Claude does not drive the browser for this. Claude's job
is to write a precise, numbered click-through script the user can follow
step by step, then take the resulting images and turn them into PR
evidence.

## Write the script, don't drive the browser

For each PR in scope, produce a numbered script: `a. do this -> b. do this
-> c. take the screenshot`. Each step should be small and unambiguous
(exact button/tab labels, exact URL params, exact field values), so the
user can execute it without needing to reverse-engineer what you meant.

For each screenshot the script calls for, say what it needs to prove (e.g.
"the Target tab is active and the full tab bar is visible, showing
Decomposition is gone") — that's what the user should check before moving
on, and what you'll be looking for when you process the result.

Before handing over the script:

- State any environment choices that affect what's shown (backend mode,
  e.g. `local-staging`; data filtering, e.g. scoping to a specific job
  type) — don't leave these for the user to guess.
- If a step in the plan doesn't correspond to any real control in the
  current UI (e.g. the PR's stated scope mentions a flow the component
  doesn't actually support), say so instead of writing a script step for
  it — don't invent a workaround the user then discovers doesn't exist.
- If a PR requires new feature/behavior work before it can be
  screenshotted, do that implementation first, as its own step, before
  handing over the click-through script.
- Tell the user where to save the raw screenshots (any scratch folder is
  fine — you'll process them from there) and to let you know once they've
  taken them.

Do not open a browser, install/drive Playwright or Stagehand, or take the
screenshots yourself for this workflow — that's the part being handed to
the user.

## Rule

- **1-3 screenshots per PR. Fewer is better.** Pick the smallest set that
  shows the change happened — one clean before/after or one shot of the new
  UI state is often enough. Don't ask for every debug/intermediate
  screenshot.
- Destination: `~/Desktop/prs/<PR#>/n.jpg` — `<PR#>` is the GitHub PR
  number (not the branch name or a letter/codename), `n` is `1`, `2`, `3` in
  the order that best tells the story.
- **Always JPEG, quality 90**, regardless of the source format the user's
  screenshot tool produced.

## Command

```bash
mkdir -p ~/Desktop/prs/<PR#>
sips -s format jpeg -s formatOptions 90 <source.png> --out ~/Desktop/prs/<PR#>/n.jpg
```

`sips` is a macOS built-in (no ImageMagick dependency needed).

## Choosing which shots

Once the user hands back their raw screenshots, prefer, in order:

1. The single shot that most directly shows the new behavior working (e.g.
   the new UI element in its "success" state).
2. A shot showing a bug that's now fixed no longer reproducing, if that's
   what the PR is about.
3. One supporting shot for a secondary interaction only if the PR's change
   has more than one distinct user-visible surface (e.g. both a list view
   and a detail view changed).

Do not include: login/auth-check screenshots, generic navigation shots
unrelated to the diff, or every step of a multi-step verification flow —
only the step(s) that show the actual change.

## Verify before exporting

Before copying the final set into `~/Desktop/prs/<PR#>/`, ask advisor to
look at the chosen screenshots (in order) against the PR's actual diff and
confirm they tell the story of the change effectively — that a reviewer who
only sees these images (not the diff) would understand what changed and
that it works. If advisor flags a gap (wrong state captured, missing
before/after contrast, an included shot that doesn't add anything), tell
the user what's missing and ask them to grab an additional/replacement
shot, rather than trying to fix the selection by cropping or editing the
image yourself.

## When multiple PRs are stacked

Map each screenshot to the PR whose diff actually introduced that piece of
UI, not the PR the user happened to be testing on top of. If a screenshot
shows a modal that existed before this PR and unrelated pre-existing UI,
but the PR only changed one button's label, ask for (or pick) a shot where
that button is visible rather than a full-page shot.

## Embed the final set into the PR body

After exporting to `~/Desktop/prs/<PR#>/n.jpg` and getting advisor's
sign-off, put the same images into the PR body itself, not just on disk —
load `external-writing-policy` first: it permits image-only PR-body content
(bare `![](url)` lines, no caption/heading/commentary) even though authored
text in a body is otherwise off-limits. This only applies while the body is
currently empty (true for a stack opened via `gh pr create --body ""` /
`gh stack link`) — if a body already holds real prose, leave it untouched
and tell the user instead, per that skill's "never touched again" rule.

Getting an image into a GH/GHE body needs a real URL; there is no `gh`
subcommand that uploads an attachment. Two ways to get one, in order of
preference:

1. **Data URI**, when it fits: `![](data:image/jpeg;base64,<...>)`. Only
   safe for a small single image — base64 adds ~33% overhead on top of an
   already-JPEG file, and GitHub/GHE bodies have a practical size ceiling
   (~65KB). Check the encoded length before using this; don't guess.
2. **Orphan attachment branch**, the reliable default for anything bigger
   or multi-image: commit the jpgs to a dedicated branch that never merges
   (e.g. `attachments/pr-<PR#>`, orphaned from no history, containing only
   the images), push it, and reference the raw content URL
   (`https://<host>/raw/<owner>/<repo>/attachments/pr-<PR#>/n.jpg` — adjust
   host scheme to whatever this GH/GHE instance's raw-content path is).
   This keeps the images out of the actual product-code branches/history
   while giving GitHub's renderer a real fetchable URL.

```bash
# orphan attachment branch, from the repo root (not a stacked worktree)
git checkout --orphan attachments/pr-<PR#>
git rm -rf --cached . > /dev/null 2>&1
cp ~/Desktop/prs/<PR#>/*.jpg .
git add *.jpg
git commit -m "screenshots"
git push -u origin attachments/pr-<PR#>
git checkout -   # back to whatever branch you were on
```

Then:

```bash
gh pr edit <PR#> --body "$(printf '![](%s)\n' "${urls[@]}")"
```

Only ever write bare image lines into that body — nothing else, per the
policy above.
