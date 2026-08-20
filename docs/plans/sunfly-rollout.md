# Sunfly Rollout Plan — Full Terminal Stack

Status: in progress
Author: claude
Date: 2026-04-12

> Status note (2026-05-06): Sunfly now has one coordinated light palette. The former `sunfly-paper` theme is named `sunfly`; the experimental `sunfly-bright` variant has been removed.

## What's done

### Neovim

- `sunfly` uses the parchment background (`#f0e8da`)
- Treesitter/LSP coverage remains aligned with Moonfly semantics
- `~/script/nvim-preview-sunfly [file...]` uses the local Sunfly checkout when present
- macOS-aware startup and `FocusGained` sync are wired in `~/.config/nvim/lua/config/theme.lua`

The current Sunfly plugin is still Moonfly-backed internally, so `bluz71/vim-moonfly-colors` remains an explicit dependency.

### Ghostty

- The custom `Sunfly` theme lives at `~/.config/ghostty/themes/Sunfly`
- Native appearance switching uses:

  ```conf
  theme = dark:Moonfly,light:Sunfly
  ```

### Pi, Posting, Harlequin, tmux, and Claude Code

`~/script/theme-sync` publishes a stable adaptive selection:

- dark: Moonfly or the app's corresponding dark theme
- light: Sunfly

Pi, Posting, and Claude select `adaptive` once; ignored runtime projections
contain the current palette. Harlequin and Neovim follow the shared state file.

Generated Sunfly files are installed with:

```sh
SUNFLY_SOURCE_DIR=~/.local/share/nvim/lazy/sunfly ~/script/sunfly-install all
```

Tracked/local destinations:

- Pi: `~/.pi/agent/themes/sunfly.json`
- Posting: `~/.local/share/posting/themes/sunfly.yaml`
- tmux: `~/.config/tmux/theme.light.conf`
- Ghostty: `~/.config/ghostty/themes/Sunfly`
- Claude Code: `~/.claude/themes/sunfly.json`
- Harlequin: `~/.config/harlequin/sunfly_textual_themes.py`

### Automatic switching

Implemented scripts and automation:

- `~/script/theme-sync [auto|dark|light]`
- `~/script/theme-watch`
- `~/script/theme-sync-enable` / `~/script/theme-sync-disable`
- `~/Library/LaunchAgents/net.bryguy.theme-sync.plist`
- Linux darkman hooks under `~/.local/share/darkman/`

`theme-sync` updates adaptive projections for Pi, Posting, Claude Code, and
Harlequin, publishes shared state for Neovim/Harlequin, reloads tmux, and
signals Ghostty. Ghostty keeps native Moonfly/Sunfly selection. On macOS,
`theme-watch` also polls for Studio Display changes and selects the thick or
regular SF Mono profile automatically unless a manual font override is active;
Ghostty uses 14pt on the Studio Display and 12pt on laptop/other displays.

## Remaining validation

- [ ] Compare Sunfly in Ghostty, tmux, Neovim, and Pi on the Studio Display
- [ ] Check Java, Lua, Markdown, justfiles, and diffs
- [ ] Check search, visual selection, completion menus, floats, diagnostics, and lualine
- [ ] Check Pi message/tool surfaces and Markdown syntax colors
- [ ] Taste-test under daylight and evening room lighting
- [ ] Publish the Sunfly source changes after feedback
