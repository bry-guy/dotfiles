# Sunfly Rollout Plan — Full Terminal Stack

Status: in progress
Author: claude
Date: 2026-04-12

> Status note (2026-05-05): Sunfly is being split into explicit `paper` and
> `bright` light variants. Local dotfiles now select `sunfly-paper` by default
> and can use `DOTFILES_SUNFLY_VARIANT=bright` to switch the whole terminal stack
> to `sunfly-bright`. The variant implementation exists in the local
> `github.com/bry-guy/sunfly` checkout and still needs the normal publish/pin
> step.

## What's done

### Neovim (complete)

- `sunfly-paper` (parchment, `#f0e8da` bg) is the default light theme
- `sunfly-bright` (lighter paper, `#f8f2ea` bg) matches the original terminal Sunfly background
- Full treesitter/LSP coverage matching moonfly 1:1 (~150 highlight groups)
- Lualine theme dynamically tracks the active variant
- Preview infrastructure: `~/script/nvim-preview-sunfly [paper|bright] [file...]`
- macOS-aware startup + `FocusGained` sync is wired in `~/.config/nvim/lua/config/theme.lua`

### Ghostty (complete)

- Custom `Sunfly Paper` and `Sunfly Bright` themes in `~/.config/ghostty/themes/`
- Auto dark/light switching enabled:
  ```
  theme = dark:Moonfly,light:Sunfly Paper
  ```
- Ghostty natively detects macOS appearance changes — no external tool needed

## What's next

### Neovim auto-switching (implemented)

`~/.config/nvim/lua/config/theme.lua` now:

- detects macOS appearance on startup
- uses `moonfly` for dark mode and `sunfly-${DOTFILES_SUNFLY_VARIANT:-paper}` for light mode when there is no explicit theme override
- re-applies the correct theme on `FocusGained`
- refreshes lualine when the theme flips
- resets cached `moonfly` / `sunfly` modules before live theme refreshes so Sunfly's Moonfly-backed palette changes do not leak across mode switches

Implementation note: the current Neovim `sunfly` plugin is still Moonfly-backed internally. It keeps `bluz71/vim-moonfly-colors` as an explicit dependency and layers the Sunfly palette/overrides on top.

Explicit overrides still win:

- `vim.g.dotfiles_theme`
- `DOTFILES_NVIM_THEME`
- `DOTFILES_SUNFLY_VARIANT` / `SUNFLY_VARIANT` for choosing `paper` vs `bright`

So previews and one-off forced themes still behave predictably.

### Pi

Pi has a `"theme"` field in `~/.pi/agent/settings.json`.

- Pi supports built-in and custom themes
- Local Pi theme files live in `~/.pi/agent/themes/`:
  - `moonfly` → tracked in dotfiles at `.pi/agent/themes/moonfly.json`
  - `sunfly-paper` / `sunfly-bright` → tracked in dotfiles at `.pi/agent/themes/sunfly-{paper,bright}.json`, refreshed via `~/script/sunfly-install --variant ... pi`
- No native auto dark/light switching support
- **Implemented**: `~/script/theme-sync` rewrites that field to switch between `moonfly` and the selected Sunfly variant

### Harlequin

Harlequin is a Textual TUI app. Theming:

- Supports built-in Textual themes via `--theme <name>` flag or config file
- No moonfly/sunfly custom theme support without writing Textual CSS
- Config file is tracked at `~/.harlequin.toml`
- **Implemented plan**: `~/script/theme-sync` rewrites profile themes to:
  - dark → `harlequin`
  - light → `solarized-light`

This is a best-effort approximation rather than a custom Sunfly port.

### Posting

Posting supports custom YAML themes.

- Active theme is configured in `~/.config/posting/config.yaml`
- Local custom themes live in `~/.local/share/posting/themes/` (Posting's default XDG data location)
- **Implemented** custom themes:
  - `moonfly` → tracked in dotfiles at `.local/share/posting/themes/moonfly.yaml`
  - `sunfly-paper` / `sunfly-bright` → tracked in dotfiles at `.local/share/posting/themes/sunfly-{paper,bright}.yaml`, refreshed via `~/script/sunfly-install --variant ... posting`
- `~/script/theme-sync` rewrites the active Posting theme between `moonfly` and the selected Sunfly variant
- Project-local Posting overrides should use `posting.env` / `POSTING_*`; avoid setting `POSTING_THEME` there unless you intentionally want to bypass system light/dark sync

This gives Posting a real Moonfly/Sunfly pairing instead of a generic Textual fallback.

### Claude Code

Claude Code CLI theming:

- Theme is selected via `/theme` / `/config`
- Built-in themes include `dark`, `light`, `dark-ansi`, and `light-ansi`
- No custom color themes (open feature request: anthropics/claude-code#1302)
- Practical note: Claude's active user preference is stored in `~/.claude.json`; current defaults are also tracked in `~/.claude/settings.json`
- **Implemented**: `~/script/theme-sync` now rewrites the top-level `theme` field in `~/.claude.json`, so Claude is part of the automatic switching path too
- Default mapping uses `dark-ansi` for dark mode and plain `light` for light mode; `light-ansi` proved too sensitive to terminal ANSI palette choices on Sunfly

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
- local Posting theme files:
  - `~/.local/share/posting/themes/moonfly.yaml` (tracked)
  - `~/.local/share/posting/themes/sunfly-paper.yaml` / `sunfly-bright.yaml` (tracked, refreshed from the public Sunfly repo)

`theme-sync` rewrites:
- `~/.pi/agent/settings.json`
- `~/.harlequin.toml`
- `~/.config/posting/config.yaml`
- `~/.config/tmux/theme.conf` (copied from tracked dark/light templates)
- `~/.claude.json`

It also pokes running Neovim servers to re-apply `require("config.theme").apply()`, reloads tmux when a server is running, and sends a best-effort `SIGUSR2` reload signal to running Ghostty on macOS.

macOS automation is handled by `dark-notify` running under the tracked `launchd` agent.

**What auto-switches natively (no script needed):**
- Ghostty — built-in `dark:X,light:Y` syntax
- Safari, Notion, Obsidian — follow macOS system appearance

**Current caveat:** Ghostty native switching has still shown some macOS light-mode flakiness in practice, so `theme-sync` now also sends Ghostty a best-effort reload signal as a local mitigation.

**What needs the script:**
- Pi — settings.json rewrite to local custom `moonfly` / selected `sunfly-*` variant themes
- Posting — switch between local custom `moonfly` / selected `sunfly-*` variant themes
- Harlequin — switch between built-in dark/light themes
- tmux — switch between tracked dark / tracked Sunfly light theme templates and reload the server when available
- Claude Code — `~/.claude.json` theme rewrite

## Priority order

1. ~~Neovim Sunfly theme + variants~~ ✓
2. ~~Ghostty theme + auto-switch~~ ✓
3. ~~Neovim auto-switch (startup + FocusGained)~~ ✓
4. ~~Posting custom moonfly / Sunfly variant themes~~ ✓
5. ~~Pi / Posting / Harlequin sync script~~ ✓
6. ~~dark-notify + launchd automation~~ ✓
7. ~~Fine-tune Claude theme choice; light mode now uses plain `light` instead of `light-ansi`~~ ✓
