# Light Theme Follow-up Bug Plan

Status: open
Owner: bryan + pi
Date: 2026-04-13

## Goal

Make the Moonfly/Sunfly automatic switching path reliable and readable across the terminal stack, with special focus on macOS light mode.

## Current state

### Good / verified enough

- Posting now launches and the `sunfly` theme looks good.
- Pi / Claude / Posting / Harlequin / Neovim are all on the `theme-sync` path.
- macOS appearance changes are being observed by `dark-notify` via the tracked `launchd` agent.

### Known issues / follow-ups

#### 1. Ghostty does not always visibly switch on macOS appearance change

- Expected: Ghostty should handle `theme = dark:Moonfly,light:Sunfly` natively.
- Observed: after switching macOS to light mode, Ghostty did not visibly update as expected.
- Evidence:
  - config uses native dark/light syntax in `~/.config/ghostty/config`
  - local Ghostty app version is `1.3.1`
  - Ghostty docs say separate light/dark themes should auto-switch with system appearance
  - there are still upstream macOS dark/light/theme-reload issues in Ghostty discussions/issues:
    - `ghostty-org/ghostty#10398`
    - `ghostty-org/ghostty#7939`
    - `ghostty-org/ghostty#3354`

##### Mitigation added

- `~/script/theme-sync` now sends `SIGUSR2` to running `ghostty` on macOS as a best-effort config reload after appearance changes.
- This is a workaround, not proof that Ghostty's native auto-switch is fully reliable.

##### Follow-up checklist

- [ ] Manually toggle macOS appearance with an already-open Ghostty window.
- [ ] Confirm whether the reload signal makes the active window repaint correctly.
- [ ] Confirm whether only new tabs/windows switch, or existing ones do too.
- [ ] If Ghostty still fails, decide whether to:
  - track it as an upstream-only bug, or
  - add a stronger local workaround (for example, app relaunch or AppleScript-driven reload).

#### 2. Harlequin light theme has readability problems

- Observed: Harlequin switched, but some light-theme text is hard to read.
- Previous mapping was:
  - dark -> `harlequin`
  - light -> `solarized-light`
- Adjustment made:
  - dark -> `harlequin`
  - light -> `textual-light`

##### Follow-up checklist

- [ ] Launch Harlequin in light mode and verify catalog, editor, tabs, and result grid contrast.
- [ ] If `textual-light` is still weak, test these built-in alternatives:
  - `flexoki`
  - `catppuccin-latte`
  - `solarized-light` (baseline / compare only)
- [ ] Pick the best readable light theme and lock it in `~/script/theme-sync` + docs.

#### 3. tmux is not actually theme-switched today

- tmux is not on the `theme-sync` path.
- Current `~/.tmux.conf` mostly uses terminal background defaults, so it is not completely broken in light mode.
- But several colors are hard-coded and dark-biased, for example:
  - `status-fg colour165`
  - `mode-style bg='#4a2f57',fg='#e4e4e4'`
  - `pane-active-border-style ... fg=colour165`
- This means tmux is more of a readability/polish risk than an automatic-switching failure.

##### Follow-up checklist

- [ ] Check tmux status line, copy-mode highlight, active border, and window-status colors in Sunfly/Ghostty light mode.
- [ ] Decide whether tmux should:
  - stay static but use more neutral colors, or
  - join `theme-sync` with generated light/dark tmux theme includes.
- [ ] If theme-sync is added, prefer a generated include file plus `tmux source-file ~/.tmux.conf` over rewriting the main config.

#### 4. Startup-only vs live-reload behavior still differs by app

Even with automatic config rewriting, some tools may only fully reflect theme changes on relaunch.

##### Follow-up checklist

- [ ] Verify live behavior vs relaunch-required behavior for:
  - Ghostty
  - Pi
  - Claude Code
  - Posting
  - Harlequin
  - tmux inside Ghostty
- [ ] Document any app that only reads theme config on startup.

#### 5. Theme-sync dirties tracked dotfiles when the OS theme flips

- Today, `theme-sync` rewrites tracked config files in place.
- That means macOS appearance changes can create normal-but-noisy `yadm status` drift.
- Likely affected files:
  - `~/.pi/agent/settings.json`
  - `~/.config/posting/config.yaml`
  - `~/.harlequin.toml`
  - any other tracked config file we later place on the sync path

##### Follow-up checklist

- [ ] Decide whether this repo should tolerate theme-driven drift in tracked files.
- [ ] If not, move runtime theme state into local generated/untracked files or app-specific override layers.
- [ ] Prefer a design where tracked files express mappings/defaults and local runtime files hold the current mode.

#### 6. Claude light theme quality still needs a taste check

- Current mapping:
  - dark -> `dark-ansi`
  - light -> `light-ansi`
- This is still a usability question, not a correctness issue.

##### Follow-up checklist

- [ ] Compare `light-ansi` vs plain `light` in a fresh Claude session.
- [ ] If `light` is cleaner, update `CLAUDE_THEME_LIGHT` default in `~/script/theme-sync`.

## Recommended execution order

1. Verify Ghostty after the new reload-signal mitigation.
2. Re-check Harlequin contrast with `textual-light`.
3. Inspect tmux under light mode and decide whether it needs full automation or only color cleanup.
4. Re-check Claude light theme choice.
5. Update docs once the final light-mode decisions are settled.
