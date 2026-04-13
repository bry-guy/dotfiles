# Sunfly Rollout Plan — Full Terminal Stack

Status: in progress
Author: claude
Date: 2026-04-12

## What's done

### Neovim (complete)

- `sunfly` (parchment, `#f0e8da` bg) is the default light theme
- `crisp` (near-white, `#fdfcf8` bg, AAA contrast) is the high-contrast alternate
- Full treesitter/LSP coverage matching moonfly 1:1 (~150 highlight groups)
- Lualine theme dynamically tracks the active variant
- Preview infrastructure: `~/script/nvim-preview-sunfly [sunfly|crisp] [file...]`
- macOS-aware startup + `FocusGained` sync is wired in `~/.config/nvim/lua/config/theme.lua`

### Ghostty (complete)

- Custom `Sunfly` and `Sunfly Crisp` themes in `~/.config/ghostty/themes/`
- Auto dark/light switching enabled:
  ```
  theme = dark:Moonfly,light:Sunfly
  ```
- Ghostty natively detects macOS appearance changes — no external tool needed

## What's next

### Neovim auto-switching (implemented)

`~/.config/nvim/lua/config/theme.lua` now:

- detects macOS appearance on startup
- uses `moonfly` for dark mode and `sunfly` for light mode when there is no explicit theme override
- re-applies the correct theme on `FocusGained`
- refreshes lualine when the theme flips

Explicit overrides still win:

- `vim.g.dotfiles_theme`
- `DOTFILES_NVIM_THEME`

So previews and one-off forced themes still behave predictably.

### Pi

Pi has a `"theme"` field in `~/.pi/agent/settings.json`.

- Pi supports `"dark"` and `"light"` themes (built-in, no custom themes)
- No native auto dark/light switching support
- **Implemented**: `~/script/theme-sync` rewrites that field to match macOS appearance (or an explicit `dark` / `light` argument)

### Harlequin

Harlequin is a Textual TUI app. Theming:

- Supports built-in Textual themes via `--theme <name>` flag or config file
- No moonfly/sunfly custom theme support without writing Textual CSS
- Config file is tracked at `~/.harlequin.toml`
- **Implemented plan**: `~/script/theme-sync` rewrites profile themes to:
  - dark → `harlequin`
  - light → `textual-light`

This is a best-effort approximation rather than a custom Sunfly port.

### Posting

Posting supports custom YAML themes.

- Active theme is configured in `~/.config/posting/config.yaml`
- Tracked custom themes live in `~/.local/share/posting/themes/` (Posting's default XDG data location)
- **Implemented** custom themes:
  - `moonfly` → `.local/share/posting/themes/moonfly.yaml`
  - `sunfly` → `.local/share/posting/themes/sunfly.yaml`
- `~/script/theme-sync` rewrites the active Posting theme between those two names

This gives Posting a real Moonfly/Sunfly pairing instead of a generic Textual fallback.

### Claude Code

Claude Code CLI theming:

- Theme is selected via `/theme` / `/config`
- 6 built-in themes: `dark`, `light`, `dark-high-contrast`, `light-high-contrast`, `dark-ansi`, `light-ansi`
- No custom color themes (open feature request: anthropics/claude-code#1302)
- Practical note: `theme` is not recognized in `~/.claude/settings.json`; Claude's docs and issue tracker point to user preferences being stored in `~/.claude.json`
- **Implemented**: `~/script/theme-sync` now rewrites the top-level `theme` field in `~/.claude.json`, so Claude is part of the automatic switching path too
- Default mapping uses ANSI modes (`dark-ansi` / `light-ansi`) so Claude tracks the terminal palette as closely as current Claude behavior allows

### macOS auto-switching architecture

**Recommended approach: `dark-notify` + hook scripts**

```
brew install cormacrelf/tap/dark-notify
```

Implemented scripts and automation:

- `~/script/theme-sync [auto|dark|light]`
- `~/script/theme-watch` → wraps `dark-notify` on macOS
- `~/script/theme-sync-enable` / `~/script/theme-sync-disable` → manage the `launchd` agent
- tracked macOS agent: `~/Library/LaunchAgents/net.bryguy.theme-sync.plist`
- tracked Linux darkman hooks:
  - `~/.local/share/darkman/dark-mode.d/50-theme-sync`
  - `~/.local/share/darkman/light-mode.d/50-theme-sync`
- tracked Posting theme files:
  - `~/.local/share/posting/themes/moonfly.yaml`
  - `~/.local/share/posting/themes/sunfly.yaml`

`theme-sync` rewrites:
- `~/.pi/agent/settings.json`
- `~/.harlequin.toml`
- `~/.config/posting/config.yaml`
- `~/.claude.json`

It also pokes running Neovim servers to re-apply `require("config.theme").apply()` and sends a best-effort `SIGUSR2` reload signal to running Ghostty on macOS.

macOS automation is handled by `dark-notify` running under the tracked `launchd` agent.

**What auto-switches natively (no script needed):**
- Ghostty — built-in `dark:X,light:Y` syntax
- Safari, Notion, Obsidian — follow macOS system appearance

**Current caveat:** Ghostty native switching has still shown some macOS light-mode flakiness in practice, so `theme-sync` now also sends Ghostty a best-effort reload signal as a local mitigation.

**What needs the script:**
- Pi — settings.json rewrite
- Posting — switch between custom `moonfly` / `sunfly` themes
- Harlequin — switch between built-in dark/light themes
- Claude Code — `~/.claude.json` theme rewrite

## Priority order

1. ~~Neovim sunfly theme~~ ✓
2. ~~Ghostty theme + auto-switch~~ ✓
3. ~~Neovim auto-switch (startup + FocusGained)~~ ✓
4. ~~Posting custom moonfly/sunfly themes~~ ✓
5. ~~Pi / Posting / Harlequin sync script~~ ✓
6. ~~dark-notify + launchd automation~~ ✓
7. Fine-tune Claude theme choice if `light-ansi` proves visually worse than `light`
