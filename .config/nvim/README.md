# Develop

Use `NVIM_APPNAME` to develop:

```sh
NVIM_APPNAME=nvim2 nvim
```

Preview Sunfly variants:

```sh
~/script/nvim-preview-sunfly paper path/to/file
~/script/nvim-preview-sunfly bright path/to/file
```

## Python LSP setup

Python buffers use Pyright when `pyright-langserver` is available on `PATH`. A project-local `mise.local.toml` can provide the interpreter and the language server, for example:

```toml
[tools]
python = "latest"
"npm:pyright" = "latest"
```

Then run `mise install` from that project and open Neovim from a shell with the mise environment active.

## AI / ACP setup

This config uses `agentic.nvim` with the `pi-acp` provider and keeps AI provider CLIs outside Neovim. Neovim expects `pi-acp` and `pi` to already be available on `PATH` in the project where Neovim is launched.

Current local setup for `pi-acp` is a temporary WIP exception until it has a Brew formula:

```toml
# ~/.mise.local.toml, local-only and untracked
[tools]
"npm:pi-acp" = "0.0.26"
```

Install/update it outside Neovim:

```sh
mise trust ~/.mise.local.toml
mise install
```

Then verify from a project directory:

```sh
command -v pi-acp
mise current npm:pi-acp
```

CodeCompanion is intentionally disabled while trying Agentic.

Useful mappings:

- `<leader>ac` toggles chat
- `<leader>ap` adds the current file or visual selection
- `<leader>an` starts a new session
- `<leader>ar` restores a session
- `<leader>ad` adds current buffer diagnostics
- `<leader>as` stops generation
- `<leader>at` toggles Agentic between right and bottom layouts

## Git diff review

Gitsigns attaches to Git-backed buffers and exposes the `<leader>g` group:

- `<leader>gn` / `<leader>gN` — next / previous hunk
- `<leader>gp` — preview the current hunk
- `<leader>gd` — open a diff against the index (unstaged changes)
- `<leader>gD` — open a diff against `HEAD` (staged and unstaged changes)
- `<leader>gdm` — open the current-file diff against the local `main` tip
- `<leader>gq` / `<leader>gQ` — put this buffer's / the repository's hunks in quickfix
- `<leader>gb` / `<leader>gB` — show blame for the current line / toggle line blame
- `<leader>gs` / `<leader>gr` — stage / discard the current hunk; use them in Visual mode for a selected range
- `<leader>gS` — stage the entire buffer

A quick local review loop is:

1. Open a changed file.
2. Use `<leader>gn` and `<leader>gN` to move between hunks.
3. Use `<leader>gp` for a compact preview.
4. Use `<leader>gd` or `<leader>gD` when you need a side-by-side diff.
5. Use `<leader>gq` or `<leader>gQ`, then `:copen`, to collect hunks for navigation across files.

Gitsigns reviews the current buffer and its hunks; it is not a whole-branch file-list UI. Fugitive remains available through `:Git` for broader Git operations, and no branch push is needed for any of these views.
