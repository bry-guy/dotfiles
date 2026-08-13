# Adaptive Theme Validation Plan

This plan is intentionally saved for a later validation pass. It is not an
approval that every runtime integration has been visually verified.

## Projection and source checks

- Confirm Moonfly and Sunfly remain the only concrete palettes.
- Confirm `adaptive` is only a stable runtime identity, not a third palette.
- Run `~/script/theme-sync light`, `dark`, and `auto`.
- Parse adaptive Pi and Claude JSON plus Posting YAML.
- Validate Ghostty configuration.
- Confirm dark and light tmux templates define the same message/status/border
  option set.
- Confirm `sunfly-install all` restores generated Sunfly output without
  overwriting adaptive Harlequin support.
- Confirm appearance changes do not modify tracked settings after the initial
  stable `adaptive` selection.

## Running application matrix

For each application, test both a fresh launch and an already-running session:

- Pi: adaptive file reload and `/reload` fallback.
- Claude Code: active `custom:adaptive` file reload and `/theme` fallback.
- Posting: adaptive theme-directory watcher and restart behavior if selection
  does not repaint.
- Harlequin: adaptive startup selection and live Textual theme change.
- Neovim: shared state timer, `FocusGained`, and lualine/devicon refresh.
- tmux: active include reload, status line, pane borders, copy mode, and
  message/command lines.
- Ghostty: native Moonfly/Sunfly selection and explicit-mode override.

## Transition matrix

- light → dark → light;
- dark → light → dark;
- repeated identical events (must be idempotent);
- concurrent appearance events (must serialize);
- malformed or temporarily incomplete adaptive files;
- missing source themes;
- stale reconciliation lock;
- dark-notify restart and exit;
- display connect/disconnect;
- Studio Display present versus other/laptop display;
- manual `sfmono`, `sfmono-thick`, Google, and Hack font overrides;
- return to `~/script/ghostty-font auto` after a manual override;
- display changes while a manual font override is active.

## Visual review

On the Studio Display and laptop display, inspect:

- Pi borders, thinking-level borders, tool cards, Markdown, diffs, and ANSI
  output;
- Claude user messages, tool output, diffs, warnings, and spinners;
- Posting editor, selection, methods, JSON syntax, and response panels;
- Harlequin catalog, editor, tabs, footer, and result grid;
- Neovim syntax, diagnostics, search, floats, lualine, and devicons;
- tmux status, active/inactive panes, copy mode, and command messages;
- Ghostty shell ANSI colors, selection, cursor, and font weight.

Record any mismatch as a semantic token problem first, rather than tuning an
individual application color in isolation.
