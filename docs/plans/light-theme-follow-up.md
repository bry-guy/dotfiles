# Light Theme Follow-up Bug Plan

Status: open
Owner: bryan + pi
Date: 2026-04-13

## Goal

Make the Moonfly/Sunfly automatic switching path reliable and readable across the terminal stack, with special focus on macOS light mode.

## Current state

### Good / verified enough

- Posting now launches with the generated `sunfly` theme.
- Pi / Claude / Posting / Harlequin / Neovim are all on the shared appearance-state path.
- Pi, Claude, and Posting use stable `adaptive` selections with ignored runtime projections.
- Harlequin keeps shared profiles/themes in `~/.harlequin.toml`; its local launcher registers Moonfly/Sunfly and watches shared state in adaptive mode.
- tmux is on the `theme-sync` path via complete generated light/dark theme includes.
- Ghostty font selection can follow Studio Display presence; manual font profiles pause that automation.
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

#### 2. Harlequin now follows adaptive state

- Current mapping is:
  - dark -> `moonfly`
  - light -> `sunfly`
- Project-local `.harlequin.toml` files now only set `default_profile`; the shared profile theme is `adaptive`.
- `~/.local/bin/harlequin` registers the generated Sunfly theme plus local adaptive Moonfly/Sunfly definitions, then switches the running Textual app when shared state changes.

##### Follow-up checklist

- [x] Replace the weak `solarized-light` approximation with generated Sunfly Textual themes.
- [ ] Launch Harlequin in light mode and verify catalog, editor, tabs, and result grid contrast with `sunfly`.
- [ ] Keep the chosen light theme aligned in `~/script/theme-sync` + docs.

#### 3. tmux light palette still needs a real-world readability pass

- tmux is now on the `theme-sync` path.
- `~/script/theme-sync` copies either `~/.config/tmux/theme.dark.conf` or `~/.config/tmux/theme.light.conf` into `~/.config/tmux/theme.conf`, then reloads tmux when a server is running.
- This resolves the original "tmux is static" problem, but the light palette still needs practical validation.

##### Follow-up checklist

- [ ] Check tmux status line, copy-mode highlight, active border, and window-status colors with Sunfly.
- [ ] If inactive text is still too faint, darken `window-status-style` in `extras/tmux/sunfly.conf` in `github.com/bry-guy/sunfly`, then reinstall it locally.
- [ ] If copy-mode or borders still feel weak, tune `mode-style` / `pane-active-border-style` in the light theme template.

#### 4. Runtime behavior now has explicit contracts

- Pi, Claude, and Posting watch the active adaptive projection files.
- Harlequin and Neovim poll the shared state file while running.
- tmux is explicitly reloaded.
- Ghostty uses native appearance selection plus a best-effort reload signal.
- Fresh-session and already-running behavior still needs the deferred matrix in `docs/plans/adaptive-theme-validation.md`.

#### 5. Runtime theme projection is now local-only

- Tracked settings select `adaptive` once.
- Appearance changes replace ignored adaptive files and `.local/state/dotfiles/theme-sync`.
- tmux and explicit Ghostty overrides are local runtime projections.
- A final tracked-file cleanliness check remains in the deferred validation plan.

#### 6. Claude light theme quality

- Current mapping:
  - dark -> `custom:moonfly`
  - light -> `custom:sunfly`
- Rationale: `light-ansi` depends on the terminal ANSI palette. Sunfly now has Claude Code custom themes with explicit hex diff backgrounds, so light mode no longer depends on ANSI diff colors.
- The Sunfly Ghostty ANSI palette also now keeps ANSI black as dark ink and ANSI white / bright-white as light paper tints, which fixes the specific inverse/diff contrast failure seen in Claude `light-ansi`.

##### Follow-up checklist

- [x] Compare `light-ansi` vs plain `light` in a fresh Claude session.
- [x] Replace plain `light` with the generated `custom:sunfly` Claude theme.
- [x] Fix Sunfly terminal ANSI white/bright-white mappings for Claude `light-ansi` contrast.

## Recommended validation order

1. Run `docs/plans/adaptive-theme-validation.md` on fresh and existing sessions.
2. Re-check Harlequin contrast with both `moonfly` and `sunfly`.
3. Inspect tmux under both modes, including command messages and copy mode.
4. Re-check Claude, Pi, and Posting adaptive reload behavior in real sessions.
5. Validate Studio Display connect/disconnect and manual font override recovery.
