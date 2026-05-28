# Sunfly Variant Reification Plan

Status: in progress
Owner: bryan + pi
Date: 2026-05-05

## Goal

Make Sunfly explicit as two coordinated light-theme variants so a terminal session and the Neovim session inside it share the same background, while still allowing comparison between the two existing Sunfly feels:

1. **paper / dark-paper variant**: today's Neovim background, `#f0e8da`.
2. **bright / light-paper variant**: today's terminal Sunfly background, `#f8f2ea`.

## Progress snapshot

Implemented locally on 2026-05-05:

- the local `bry-guy/sunfly` checkout now exposes `sunfly-paper` and `sunfly-bright` Neovim colorschemes
- generated Sunfly variant extras now exist for Ghostty, Pi, Posting, and tmux
- dotfiles now default light-mode Sunfly to `paper`, with `DOTFILES_SUNFLY_VARIANT=bright` available for the lighter background
- `theme-sync`, `sunfly-install`, and `nvim-preview-sunfly` understand the variants
- Ghostty variant themes use dark ink for ANSI color 0 so ANSI-based light UIs remain readable
- the temporary Neovim-only red override remains removed

Remaining publication step: decide whether to first complete the standalone Neovim migration in `docs/plans/sunfly-standalone.md`, then commit/push/tag the `bry-guy/sunfly` changes and update the dotfiles plugin pin / `sunfly-install` default ref as appropriate.

Each variant should have its own tuned accent colors. Do not fix variant-specific readability by adding local Neovim-only highlight overrides.

## Immediate cleanup

- [x] Remove the temporary local red-family override from `.config/nvim/lua/plugins/sunfly.lua`.
- [x] Remove the temporary reapply hook from `.config/nvim/lua/config/theme.lua`.
- [x] Remove documentation that described that temporary override as current behavior.

## Design principles

- Background parity is mandatory within a variant:
  - Ghostty background = Neovim `Normal.bg` = tmux/status surface baseline for that variant.
- Accent parity is semantic, not necessarily identical hex across variants:
  - both variants keep Moonfly-like roles: functions blue, strings khaki, types green, keywords violet, errors red.
  - each variant gets independently tuned red/green/string values because the background lightness changes perceived contrast.
- The public `bry-guy/sunfly` repo should own the palettes and generated extras.
- Dotfiles should only select a variant and consume generated files; avoid local per-highlight color patches.

## Proposed naming

Use neutral names that describe background lightness rather than quality:

- `sunfly-paper` — darker paper, background `#f0e8da`; matches today's Neovim feel.
- `sunfly-bright` — lighter paper, background `#f8f2ea`; matches today's terminal Sunfly feel.

Compatibility option:

- Keep `sunfly` as an alias to whichever variant becomes the preferred default during rollout.
- Keep or retire `Sunfly Crisp` later; it is currently even lighter (`#fdfcf8`) and should not block the two-variant plan.

## Public `bry-guy/sunfly` changes

1. Refactor palette source of truth. **Done locally.**
   - Replace one implicit palette with either:
     - `palette/sunfly-paper.json` and `palette/sunfly-bright.json`, or
     - one `palette/sunfly.json` containing a `variants` table.
   - Each variant defines full neutrals, accents, terminal colors, and integration vars.

2. Generate variant-specific outputs. **Done locally.**
   - Neovim colorschemes:
     - `colors/sunfly-paper.lua`
     - `colors/sunfly-bright.lua`
     - optional compatibility `colors/sunfly.lua`
   - lualine themes:
     - `lua/lualine/themes/sunfly-paper.lua`
     - `lua/lualine/themes/sunfly-bright.lua`
   - Extras:
     - `extras/ghostty/Sunfly Paper`
     - `extras/ghostty/Sunfly Bright`
     - `extras/pi/sunfly-paper.json`
     - `extras/pi/sunfly-bright.json`
     - `extras/posting/sunfly-paper.yaml`
     - `extras/posting/sunfly-bright.yaml`
     - `extras/tmux/sunfly-paper.conf`
     - `extras/tmux/sunfly-bright.conf`

3. Tune both variants separately. **Initial pass done locally; taste-testing still needed.**
   - Start from current values:
     - paper: existing Neovim palette/background.
     - bright: existing Ghostty terminal background.
   - Tune red, green, and khaki/string families per variant using real Neovim buffers and terminal ANSI swatches.
   - Keep contrast acceptable on each background without forcing colors so dark that they collapse into normal ink.

4. Add checks.
   - `scripts/build-extras.py --check` verifies all generated files.
   - Add a small palette report/check for contrast of semantic accents against each variant background.

## Dotfiles changes after public repo support exists

1. Update plugin selection in `.config/nvim/lua/plugins/sunfly.lua`. **Done locally.**
   - Install/consume the new Sunfly version.
   - Select `sunfly-paper` or `sunfly-bright` based on a dotfiles-level variant setting.

2. Extend `.config/nvim/lua/config/theme.lua`. **Done locally.**
   - Keep dark mode = `moonfly`.
   - Light mode = selected Sunfly variant.
   - Suggested selector precedence:
     1. `vim.g.dotfiles_sunfly_variant`
     2. `DOTFILES_SUNFLY_VARIANT`
     3. default from dotfiles settings, initially `paper` or `bright` after taste-testing.

3. Update Ghostty. **Done locally.**
   - Change `.config/ghostty/config` from `light:Sunfly` to the matching variant, e.g. `light:Sunfly Paper` or `light:Sunfly Bright`.
   - If switching variants should be runtime-configurable, teach `script/theme-sync` to rewrite or include the light theme name from `DOTFILES_SUNFLY_VARIANT`.

4. Update `script/sunfly-install`. **Done locally.**
   - Add `--variant paper|bright|all`.
   - Install the matching Ghostty/Pi/Posting/tmux generated files.

5. Update `script/theme-sync`. **Done locally.**
   - Resolve a single `sunfly_variant` in light mode.
   - Use matching app theme names for Pi, Posting, tmux, and Ghostty status output.
   - Ensure Neovim remote refresh selects the same variant as the terminal.

6. Update preview workflow. **Done locally.**
   - Extend `script/nvim-preview-sunfly` to accept variant names, for example:
     - `nvim-preview-sunfly paper <file>`
     - `nvim-preview-sunfly bright <file>`
   - Optionally add terminal swatch preview helpers for both variants.

## Validation checklist

For each variant:

- [ ] Open Ghostty with the variant and confirm background color.
- [ ] Open Neovim inside that Ghostty session and confirm `Normal.bg` matches Ghostty.
- [ ] Check Java, Lua, Markdown, a `justfile`, and diffs.
- [ ] Check diagnostics/error red against normal text.
- [ ] Check strings/khaki and green/type readability.
- [ ] Check lualine, completion menu, floats, search, visual selection, and tmux status.
- [x] Run headless Neovim startup smoke test for both variants.

## Rollout order

1. Undo temporary local override. Done.
2. Implement variant palettes and generated extras in `bry-guy/sunfly`. Done locally.
3. Install both variant extras locally. Done.
4. Wire dotfiles to select one light variant consistently across terminal + Neovim. Done.
5. Taste-test both variants for a few days.
6. Commit/push/tag `bry-guy/sunfly`, update the dotfiles plugin pin / installer ref, then pick the default alias for `sunfly` and keep the other variant available.
