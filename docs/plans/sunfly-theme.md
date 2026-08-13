# Sunfly Theme Plan

Status: in progress
Author: pi
Date: 2026-04-12

## Goal

Maintain one warm-paper `sunfly` light theme that feels like a coherent sibling to Moonfly and works consistently across the terminal stack.

## Design principles

1. Keep Moonfly's semantic hue roles stable:
   - functions stay blue
   - keywords stay violet
   - strings stay khaki
   - types stay teal/green
2. Flip luminance, not identity.
3. Use warm neutrals instead of sterile white surfaces.
4. Separate semantic colors by hue while keeping foreground contrast strong.
5. Use modest surface tints and clearer borders instead of large, highly saturated fills.
6. Iterate from real code, diagnostics, completion menus, search, selection, statuslines, and Pi message surfaces.

## Current implementation

The published source of truth lives at `github.com/bry-guy/sunfly`.

- colorscheme: `sunfly`
- background: `#f0e8da`
- generated extras: Ghostty, Pi, Posting, tmux, Claude Code, and Harlequin
- local preview: `~/script/nvim-preview-sunfly [file...]`
- palette source: `palette/sunfly.json` in the Sunfly repository

The former Paper theme is now simply Sunfly. The experimental Bright theme has been removed.

Sunfly is still Moonfly-backed internally: it passes the Sunfly palette to Moonfly, loads Moonfly's highlight coverage, applies Sunfly overrides, and exposes the resulting colorscheme as `sunfly`. The standalone migration remains documented in `docs/plans/sunfly-standalone.md`.

## Current tuning pass

- retain the parchment background
- soften primary ink from `#271e17` to `#372d25` on large text surfaces
- strengthen comment and documentation text
- use light text on dark search-result fills
- make visual selections, current lines, borders, and Pi cards easier to distinguish
- reduce syntax collisions by reusing semantic colors intentionally rather than maintaining near-duplicate accents

## Feedback loop

1. Install generated extras from the local checkout:

   ```sh
   SUNFLY_SOURCE_DIR=~/.local/share/nvim/lazy/sunfly ~/script/sunfly-install all
   ~/script/theme-sync light
   ```

2. Preview representative Java, Lua, Markdown, justfile, and diff buffers.
3. Open Pi in a fresh process so it reads the updated `sunfly` theme.
4. Check the palette under daylight and evening room lighting.
5. Record feedback about background warmth, text weight, semantic separation, selection visibility, and card/tool surfaces.

## Success criteria

Sunfly should:

- feel recognizably related to Moonfly
- remain comfortable for normal coding sessions on the Studio Display
- keep semantic categories easy to parse
- distinguish selections, borders, and message surfaces without looking busy
- stay consistent across Neovim, Ghostty, tmux, Pi, Posting, Claude Code, and Harlequin
