# TODO

## Setup

Test the following under a new macOS user. Don't ruin my current setup!
- [x] Migrate repo layout for yadm
- [x] Make `~/script/setup` bootstrap the machine without applying dotfiles
- [ ] Decide whether work-only tracked files should remain shared or move behind local machine gating

## Linux

- [ ] Use kinto.sh

## Identity

- [ ] Decide whether the personal legacy key item `brainbook.local` should be renamed to `git-personal` in the 1Password app
- [ ] Test identity bootstrap on a fresh personal macOS machine
- [ ] Test identity bootstrap on a fresh work macOS machine

## Neovim

### LSPs

- [ ] Fix mason, asdf, and vscode all having different LSP sourcing
  - [x] gopls
  - [x] golangci-lint

### Linters

- [x] Fix golangci-lint for `make lint` invoking from shell (similar to above)
