# Sunfly Theme Plan

Status: in progress
Author: pi
Date: 2026-04-12

> Status note (2026-04-13): the published Sunfly source of truth now lives in
> `github.com/bry-guy/sunfly`. The detailed implementation notes below are kept
> as design history from the local prototyping phase; current local dotfiles now
> consume the public repo instead of hand-maintaining the Sunfly files here.

## Goal

Create a first-pass `sunfly` light theme that feels like a coherent sibling to the existing `moonfly` setup, with the earliest iteration loop focused on Neovim semantics and readability.

The implementation should be safe to try on this machine:

- default day-to-day config must remain `moonfly`
- previewing `sunfly` must be isolated and easy to discard
- changes should be reversible with small targeted edits

## Why start in Neovim

The strongest requirement is not “make everything light.” It is:

- preserve semantic color intuition across languages
- keep Treesitter / syntax categories feeling consistent with `moonfly`
- validate whether a Moonfly-derived light palette is actually pleasant to use

If `sunfly` does not feel right in Neovim, there is little value in porting it to Ghostty, Pi, Posting, or Harlequin.

## Design principles for `sunfly`

1. Keep Moonfly’s semantic hue roles stable.
   - functions stay blue-ish
   - keywords stay violet-ish
   - strings stay warm/khaki
   - types stay teal/green
2. Flip luminance, not identity.
   - `moonfly` = bright pigment on charcoal
   - `sunfly` = dark ink on warm paper
3. Use warm neutrals.
   - avoid sterile white backgrounds
   - prefer cream / paper / parchment values
4. Reduce accent intensity for light mode.
   - colors that work on near-black often feel too loud on paper
5. Iterate from real coding surfaces first.
   - code
   - diagnostics
   - completion menu
   - search / selection
   - statusline / floats

## Initial implementation plan

### Phase 1: safe preview infrastructure

Add a small theme-selection layer to the tracked Neovim config while preserving the current default behavior:

- default theme remains `moonfly`
- add a new `sunfly` colorscheme wrapper and palette module
- add a `~/script/nvim-preview-sunfly` launcher
- add an isolated Neovim app config at `~/.config/nvim-sunfly-preview`

The isolated preview should use `NVIM_APPNAME=nvim-sunfly-preview`, so it gets its own:

- config namespace
- plugin install directory
- cache/state directories

This avoids disturbing the main Neovim runtime state while still reusing the tracked dotfiles config as the source of truth.

### Phase 2: first-pass Sunfly palette

Implement a Moonfly-derived palette override with:

- warm paper background
- dark ink foreground
- softened but recognizable semantic accents
- a custom lualine theme for light mode
- targeted highlight overrides where Moonfly’s dark-mode defaults do not translate well

### Phase 3: iteration loop

Primary review loop:

1. launch `~/script/nvim-preview-sunfly <file>`
2. inspect a few representative files / languages
3. collect feedback on:
   - background warmth
   - keyword / function / string distinction
   - comments visibility
   - search / selection contrast
   - float / completion / statusline separation
4. adjust the shared `sunfly` palette and retest

## Proposed files

- `docs/plans/sunfly-theme.md`
- `.config/nvim/lua/config/theme.lua`
- `.config/nvim/lua/sunfly/init.lua`
- `.config/nvim/colors/sunfly.lua`
- `.config/nvim/lua/lualine/themes/sunfly.lua`
- `.config/nvim-sunfly-preview/init.lua`
- `script/nvim-preview-sunfly`

And small edits to:

- `.config/nvim/lua/config/options.lua`
- `.config/nvim/lua/plugins/lualine.lua`

## Safety / rollback

- default live Neovim startup remains on `moonfly`
- `sunfly` preview is opt-in only
- rollback is:
  - remove preview launcher/config
  - remove `sunfly` files
  - restore the previous hardcoded theme lines in Neovim config

## Success criteria for pass 1

A successful first pass should:

- feel recognizably related to `moonfly`
- be readable for normal coding sessions in daylight
- keep semantic categories easy to parse
- not require switching the main daily-driver config yet
- give a fast feedback loop for follow-up tuning

---

## Progress snapshot

Status: published and consumed from the public repo
Last updated: 2026-04-13

What is implemented now:

- default `nvim` still starts with `moonfly`
- light mode still switches to `sunfly`
- the Neovim Sunfly colorscheme is now consumed from `github.com/bry-guy/sunfly`
- local dotfiles no longer hand-maintain the Sunfly Neovim files
- the preview launcher still exists at `~/script/nvim-preview-sunfly`
- preview Neovim still runs with `NVIM_APPNAME=nvim-sunfly-preview`

Validation completed:

- normal `nvim` reports `sunfly` when light mode selects it through the public plugin
- preview `nvim` reports `sunfly` through the public plugin
- isolated preview state is still stored under the `nvim-sunfly-preview` app namespace

## Files added / changed

Current local pieces:

- `docs/plans/sunfly-theme.md`
- `.config/nvim/lua/config/theme.lua`
- `.config/nvim/lua/plugins/sunfly.lua`
- `.config/nvim-sunfly-preview/init.lua`
- `.config/nvim-sunfly-preview/lua/plugins/sunfly.lua`
- `script/nvim-preview-sunfly`

Removed from local source-of-truth status:

- `.config/nvim/lua/sunfly/init.lua`
- `.config/nvim/colors/sunfly.lua`
- `.config/nvim/lua/lualine/themes/sunfly.lua`

Those now come from the published `bry-guy/sunfly` repository instead.

## Current Sunfly specification

### Base palette

Current published palette source of truth: `github.com/bry-guy/sunfly` (`palette/sunfly.json` in that repo).

```lua
-- Coordinated ink-band palette: all accents at CIELAB L* 30-37, WCAG AAA (>=7:1) vs bg
{
  black = "#19120d",
  white = "#271e17",
  bg = "#fdfcf8",
  grey0 = "#e0d5c5",
  grey1 = "#d4c5b1",
  grey89 = "#372d25",
  grey70 = "#463c33",
  grey62 = "#564b41",
  grey58 = "#65594e",
  grey50 = "#75685b",
  grey39 = "#8b7d6f",
  grey35 = "#988979",
  grey30 = "#a59686",
  grey27 = "#b7a896",
  grey23 = "#c8b9a7",
  grey18 = "#dad0c1",
  grey16 = "#e7ddd1",
  grey15 = "#ece3d8",
  grey13 = "#f2ebe2",
  grey11 = "#f8f2ea",
  grey7 = "#fffefb",
  red = "#9b1b23",       -- L*33.7  CR 7.94  wine/deep red
  crimson = "#831e58",   -- L*30.5  CR 8.93  deep magenta
  cranberry = "#862848", -- L*31.9  CR 8.49  dark rose
  coral = "#8a3b1c",     -- L*35.2  CR 7.51  burnt sienna
  cinnamon = "#7f3d2e",  -- L*34.1  CR 7.84  dark terracotta
  orchid = "#8a3578",    -- L*36.6  CR 7.15  warm plum (28° from violet)
  orange = "#874000",    -- L*35.6  CR 7.40  deep amber
  yellow = "#6b5200",    -- L*36.3  CR 7.22  dark gold
  khaki = "#594800",     -- L*31.3  CR 8.70  raw umber
  lime = "#2b5e0e",      -- L*35.1  CR 7.55  dark leaf
  green = "#2c5f00",     -- L*35.4  CR 7.45  forest
  emerald = "#0d5f20",   -- L*34.7  CR 7.65  deep emerald
  turquoise = "#005c6c", -- L*35.5  CR 7.45  dark teal
  sky = "#004ca8",       -- L*34.0  CR 7.87  deep azure
  blue = "#1b4fae",      -- L*35.8  CR 7.37  ink blue
  lavender = "#4840b0",  -- L*34.4  CR 7.76  deep lavender
  violet = "#5530bb",    -- L*33.2  CR 8.10  deep violet
  purple = "#4a38c0",    -- L*34.2  CR 7.81  deep purple
  mineral = "#dceee7",
  bay = "#b3cdf7",
  slate = "#7489a7",
  haze = "#60758f",
}
```

### Semantic intent

Current semantic mapping intentionally stays close to Moonfly:

- functions / methods → `sky`
- strings → `khaki`
- types / class-like things → `emerald`
- statements / modifiers → `violet`
- properties / members / constructors → `blue`
- parameters → `orchid`
- operators / import-ish accents → `cranberry`
- errors / exception-ish accents → `red`
- annotations / attributes → `sky`

### Current lualine spec

Current published lualine source of truth: `github.com/bry-guy/sunfly` (`lua/lualine/themes/sunfly.lua` in that repo).

```lua
{
  color_bg1 = "#d2c5b5",
  color_bg2 = "#efe7dc",
  color1 = "#1b4fae",   -- normal (blue)
  color2 = "#0d5f20",   -- insert (emerald)
  color3 = "#5530bb",   -- visual (violet)
  color4 = "#594800",   -- command (khaki)
  color5 = "#9b1b23",   -- replace (red)
  color6 = "#fffefb",   -- light fg for mode chips
  color7 = "#65594e",   -- inactive fg
  color8 = "#271e17",   -- dark fg
  color9 = "#463c33",   -- section c fg
}
```

Design intent:

- mode chip should be strongly differentiated from the surrounding statusline
- `b` and `c` sections should have visibly different background layers
- accent chip text can use light foreground if the accent color is dark enough

## Research / reasoning recorded so far

The tuning direction shifted after reviewing light-theme contrast reasoning from:

- `vim-moonfly-colors` itself for the original Moonfly semantic mappings
- Flexoki / Solarized / Selenized design notes

Working conclusions:

1. The main issue is not just hue selection; it is accent **lightness** against a light background.
2. Light themes often fail when accent colors are too close to the paper background in perceptual lightness.
3. Dark-theme accent colors do not translate directly to light themes; Sunfly likely needs darker, more ink-like versions of its accent families.
4. Bold should not be used as the primary fix for insufficient contrast.
5. Lualine / float / menu layering matters a lot in light themes because weak background separation makes everything feel washed out.

## Feedback summary from this conversation

### What improved

- broad semantic mapping in Java now feels roughly correct
- blues became much better than the earliest iterations
- field-name blue is contrasty enough without bold
- parameter-name purple is decent
- strings improved compared to the earliest passes
- overall Sunfly is now in a “decent spot” for future iteration rather than unusable

### What did not work

- early passes used insufficient contrast overall compared to Moonfly dark mode
- some passes overused warm/off-white paper without enough accent ink depth
- bolding `private final` and annotations was disliked and removed
- green family still feels weak / hard to read as green
- red family still feels weak / muddy
- strings are better but still not yet good enough
- lualine `NORMAL` chip / overall statusline layering still needs work
- some background layers may still be off, especially in lualine and related UI surfaces

### Specific preferences inferred

These were inferred from feedback and should guide future changes:

- perceived contrast matters more than preserving exact transformed Moonfly hues
- non-bold but clearly readable text is preferred over bold compensation
- blue family is currently the closest to “working” in light mode
- Sunfly should remain semantically related to Moonfly, but may need fundamentally different light-mode accent values
- annotations should stay blue-like, matching Moonfly more closely

## Open issues / suspected root causes

1. **Accent family mismatch in light mode**
   - blue works reasonably well
   - green and red currently do not carry enough identity or contrast
   - this suggests Sunfly may need a less literal Moonfly derivation for those families

2. **Statusline layering is still weak**
   - the lualine mode chip and background sections do not yet feel as crisp as the dark version
   - likely needs stronger separation between `bg1`, `bg2`, and accent chip foreground/background behavior

3. **Treesitter / LSP group coverage may still be incomplete**
   - Java now looks roughly mapped correctly, but future passes should verify exact captures rather than assuming all important groups are covered

4. **Need better cross-family contrast parity**
   - blue reached acceptable contrast sooner than green/red/yellow/purple
   - likely indicates the palette should be tuned as a coordinated “ink band” rather than family-by-family guesses

## Recommended next session plan

When resuming, start here:

1. keep the existing preview infrastructure; do not rework that first
2. inspect the exact current captures in:
   - `DataSourceController.java`
   - `justfile`
3. focus only on these areas first:
   - green family
   - red family
   - string / khaki family
   - lualine layering
4. avoid bold as a contrast fix
5. prefer solving with better accent lightness / hue selection
6. if needed, propose a more fundamentally different Sunfly accent set while keeping Moonfly semantic roles

## How to preview later

```sh
~/script/nvim-preview-sunfly
~/script/nvim-preview-sunfly path/to/DataSourceController.java
~/script/nvim-preview-sunfly justfile
```

To remove preview runtime state later if desired:

```sh
rm -rf ~/.local/share/nvim-sunfly-preview ~/.local/state/nvim-sunfly-preview ~/.cache/nvim-sunfly-preview
```
