# Sunfly Standalone Neovim Plan

Status: proposed
Owner: bryan + pi
Date: 2026-05-05

## Goal

Make the Neovim Sunfly colorschemes (`sunfly-paper`, `sunfly-bright`, and compatibility `sunfly`) fully standalone, with no runtime dependency on `bluz71/vim-moonfly-colors`.

The desired final model is:

```text
palette/sunfly.json
  -> Neovim Sunfly palettes/highlights
  -> lualine themes
  -> Ghostty / Pi / Posting / tmux extras
```

No hidden Moonfly base layer, no `require("moonfly").custom_colors(...)`, and no `vim.cmd("colorscheme moonfly")` during Sunfly load.

## Current state

Today Sunfly still works by:

1. selecting a Sunfly variant palette
2. passing that palette into Moonfly via `require("moonfly").custom_colors(...)`
3. loading Moonfly with `vim.cmd("colorscheme moonfly")`
4. applying Sunfly-specific overrides
5. renaming `vim.g.colors_name` to `sunfly-paper` / `sunfly-bright`

This is pragmatic, but it couples Sunfly to Moonfly internals and makes debugging color behavior less obvious.

## Non-goals

- Do not redesign the Sunfly palettes during the standalone migration.
- Do not remove the generated extras path.
- Do not rewrite terminal/Pi/Posting/tmux themes except as needed to keep generation aligned.
- Do not solve every taste issue in the same change; preserve current visual output first, then tune later.

## Success criteria

- `sunfly-paper` and `sunfly-bright` load in Neovim without Moonfly installed.
- `:colorscheme moonfly` is never invoked while loading Sunfly.
- `bluz71/vim-moonfly-colors` is no longer a required dependency of `bry-guy/sunfly`.
- Dotfiles no longer list Moonfly as a Sunfly dependency, though Moonfly may remain installed for dark mode.
- Existing variant backgrounds remain exact:
  - paper: `#f0e8da`
  - bright: `#f8f2ea`
- Headless smoke tests pass for both variants.
- Real-world checks cover Java, Lua, Markdown, justfiles, diffs, diagnostics, completion/floats, Telescope, lualine, and tmux-in-terminal.

## Phase 1 — Snapshot current behavior

Purpose: preserve the current Moonfly-backed output so the standalone migration can be compared objectively.

Tasks:

1. Add a temporary/development dump script in the Sunfly repo, for example:
   - `scripts/dump-nvim-highlights.lua`, or
   - `scripts/dump-nvim-highlights.sh`
2. Dump resolved highlight groups for both variants:
   - `sunfly-paper`
   - `sunfly-bright`
3. Include:
   - group name
   - resolved `fg`, `bg`, `sp`
   - style flags (`bold`, `italic`, `underline`, `undercurl`, etc.)
   - link target when relevant
4. Save snapshots under an ignored or test-fixture path, depending on size:
   - preferred local-only: `tmp/highlights-*.json`
   - committed only if small/useful: `test/fixtures/highlights-*.json`
5. Add a simple diff helper to compare current standalone output against the snapshot.

Deliverable:

- A repeatable command that says “these highlight groups changed” after the migration.

## Phase 2 — Make palette JSON the source of truth

Purpose: avoid two separate palette definitions after the standalone work.

Tasks:

1. Keep `palette/sunfly.json` as the canonical source.
2. Generate a Lua palette module from it, for example:
   - `lua/sunfly/palette.lua`, or
   - `lua/sunfly/generated_palette.lua`
3. Update `scripts/build-extras.py` or add a sibling generator so both extras and Lua palette data come from the same JSON.
4. Ensure generated Lua includes:
   - variants
   - neutrals
   - accents
   - terminal colors used by Neovim `:terminal`
   - lualine colors / variant metadata
5. Add `--check` coverage so generated Lua and extras cannot drift.

Deliverable:

- No hand-maintained duplicate palette table in `lua/sunfly/init.lua`.

## Phase 3 — Build a standalone highlight engine

Purpose: replace Moonfly loading with direct Sunfly highlight definitions.

Tasks:

1. Create a clean loader flow:

   ```lua
   function M.load(variant)
     local active_variant = M.set_variant(variant or M.current_variant())
     vim.cmd("highlight clear")
     if vim.fn.exists("syntax_on") == 1 then
       vim.cmd("syntax reset")
     end
     vim.o.background = "light"
     vim.g.colors_name = M.variants[active_variant].colors_name
     M.apply_terminal_colors(active_variant)
     M.apply_highlights()
   end
   ```

2. Add a small helper wrapper:

   ```lua
   local function hi(group, spec)
     vim.api.nvim_set_hl(0, group, spec)
   end
   ```

3. Split highlight definitions into maintainable sections or files:
   - `lua/sunfly/highlights/core.lua`
   - `lua/sunfly/highlights/syntax.lua`
   - `lua/sunfly/highlights/treesitter.lua`
   - `lua/sunfly/highlights/lsp.lua`
   - `lua/sunfly/highlights/plugins.lua`
   - or keep one file initially, then split once stable
4. Start by moving existing `M.apply_overrides()` into the standalone base.
5. Fill in groups that Moonfly previously supplied implicitly.

Deliverable:

- `colors/sunfly-paper.lua` and `colors/sunfly-bright.lua` load without requiring or invoking Moonfly.

## Phase 4 — Fill coverage previously inherited from Moonfly

Prioritize coverage in this order:

### Core Vim/editor groups

- `Normal`, `NormalNC`, `NormalFloat`, `FloatBorder`, `FloatTitle`
- `LineNr`, `CursorLine`, `CursorLineNr`, `SignColumn`, `FoldColumn`, `Folded`
- `Visual`, `Search`, `CurSearch`, `IncSearch`
- `StatusLine`, `StatusLineNC`, `TabLine`, `TabLineSel`, `TabLineFill`
- `Pmenu`, `PmenuSel`, `PmenuBorder`, `WildMenu`
- `ErrorMsg`, `WarningMsg`, `Question`, `MoreMsg`, `ModeMsg`
- `MatchParen`, `ColorColumn`, `Conceal`, `Directory`, `Title`

### Diff/version-control groups

- `DiffAdd`, `DiffChange`, `DiffDelete`, `DiffText`
- `diffAdded`, `diffChanged`, `diffRemoved`
- `Added`, `Changed`, `Removed`
- GitSigns groups if installed / useful

### Legacy syntax groups

- `Comment`, `Constant`, `String`, `Character`, `Number`, `Boolean`, `Float`
- `Identifier`, `Function`
- `Statement`, `Conditional`, `Repeat`, `Label`, `Operator`, `Keyword`, `Exception`
- `PreProc`, `Include`, `Define`, `Macro`, `PreCondit`
- `Type`, `StorageClass`, `Structure`, `Typedef`
- `Special`, `SpecialChar`, `Tag`, `Delimiter`, `SpecialComment`, `Debug`
- `Underlined`, `Ignore`, `Error`, `Todo`

### Treesitter groups

Use the current Sunfly coverage as the baseline and add missing modern aliases where needed:

- `@variable`, `@variable.member`, `@variable.parameter`, `@variable.builtin`
- `@constant`, `@constant.builtin`, `@constant.macro`
- `@module`, `@constructor`, `@type`, `@type.builtin`, `@type.definition`
- `@function`, `@function.call`, `@function.method`, `@function.method.call`, `@function.builtin`, `@function.macro`
- `@keyword.*`
- `@string.*`
- `@comment.*`
- `@markup.*`
- `@diff.*`
- language-specific overrides currently in Sunfly

### LSP and diagnostics

- `DiagnosticError`, `DiagnosticWarn`, `DiagnosticInfo`, `DiagnosticHint`, `DiagnosticOk`
- underline, virtual text, virtual lines, signs, and floating diagnostic groups
- `LspReferenceText`, `LspReferenceRead`, `LspReferenceWrite`
- `LspInlayHint`, `LspCodeLens`, `LspSignatureActiveParameter`
- existing `@lsp.type.*` and `@lsp.typemod.*` groups

### Plugin/UI groups

Start with groups actually used in this config:

- Telescope
- nvim-cmp completion menu groups if applicable
- nvim-web-devicons refresh compatibility
- Oil
- markview / markdown surfaces
- DAP UI groups if present
- WhichKey
- Lazy UI groups if useful

Deliverable:

- Snapshot diff is understandable and intentional; no major regressions from inherited Moonfly coverage.

## Phase 5 — Remove Moonfly dependency

Tasks:

1. In `bry-guy/sunfly` README:
   - remove Moonfly runtime dependency from install examples
   - mention Moonfly only as inspiration/attribution
2. In dotfiles `.config/nvim/lua/plugins/sunfly.lua`:
   - remove Moonfly from Sunfly dependencies
   - keep Moonfly separately installed for dark mode via `.config/nvim/lua/plugins/moonfly.lua`
3. Confirm `sunfly-paper` and `sunfly-bright` still load when Moonfly plugin is absent from runtimepath.
4. Update docs/plans that currently say Sunfly is Moonfly-backed.

Deliverable:

- Sunfly plugin no longer requires Moonfly.

## Phase 6 — Validation

Automated checks:

```sh
cd ~/.local/share/nvim/lazy/sunfly
python3 scripts/build-extras.py --check
python3 -m py_compile scripts/build-extras.py

SUNFLY_PLUGIN_DIR=$PWD DOTFILES_NVIM_THEME=sunfly-paper nvim --headless +qa
SUNFLY_PLUGIN_DIR=$PWD DOTFILES_NVIM_THEME=sunfly-bright nvim --headless +qa
```

Suggested no-Moonfly smoke test:

```sh
# Use a temporary minimal app/config/runtime so Moonfly is not on runtimepath.
# Load only lazy.nvim + local Sunfly, then run both colorschemes headlessly.
```

Manual checks:

- Java controller file
- Lua config file
- Markdown file
- `justfile`
- git diff buffer
- diagnostics in a file with known errors
- Telescope picker
- completion popup
- floating hover/signature window
- lualine mode changes
- terminal buffer ANSI colors

Deliverable:

- Both variants are acceptable before removing the Moonfly dependency from dotfiles.

## Phase 7 — Publish and consume

Tasks:

1. Commit standalone changes in `bry-guy/sunfly`.
2. Push and tag a release, for example `v0.2.0`.
3. Update dotfiles to consume that tag or branch deliberately.
4. Run `~/script/sunfly-install --variant all all` from the published ref.
5. Update `lazy-lock.json` through normal Neovim/lazy workflow.
6. Update docs:
   - `docs/plans/sunfly-theme.md`
   - `docs/plans/sunfly-rollout.md`
   - `docs/plans/sunfly-variants.md`
   - `README.md` if workflow commands change

## Risks and mitigations

| Risk | Mitigation |
| --- | --- |
| Missing highlight groups that Moonfly used to provide | Snapshot current output, compare after standalone, fill gaps intentionally |
| Palette drift between Lua and extras | Generate Lua palette and extras from `palette/sunfly.json` with `--check` |
| Over-large first change | Preserve current visuals first, tune later |
| Hard-to-debug plugin-specific regressions | Validate against actual configured plugins and real files |
| Breaking dark Moonfly workflow | Keep Moonfly plugin installed separately for dark mode until/unless replaced |

## Estimated effort

- MVP standalone loader and core coverage: 2–4 hours
- Solid replacement with useful coverage and docs: ~1 day
- Polished, confidently equivalent result: 1–2 days

## Recommended execution order

1. Snapshot current Moonfly-backed highlight output.
2. Generate Lua palette data from `palette/sunfly.json`.
3. Replace the Moonfly load path with direct highlight setup.
4. Fill inherited groups until snapshot diffs are acceptable.
5. Add no-Moonfly smoke tests.
6. Remove dependency declarations and update docs.
7. Publish/tag Sunfly and update dotfiles.
