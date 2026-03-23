# TODO

## Setup

Test the following under a new macOS user. Don't ruin my current setup!
- [x] Include chezmoi in setup scripts
- [x] (chezmoi) Ignore linux folder on darwin machines
- [ ] (chezmoi) Ignore \_work files on non-work machines

## Linux

- [ ] Use kinto.sh

## Identity

- [ ] Finalize work machine identity
  - [x] Create a dedicated 1Password SSH key item for work (`git-work`)
  - [ ] Decide work git name/email/username defaults
  - [ ] Update `script/identity-apply work` defaults once work details are known
  - [ ] Decide whether the personal legacy key item `brainbook.local` should be renamed to `git-personal` in the 1Password app
  - [ ] Test work identity on a real work-scoped machine before using it broadly

## Neovim

### LSPs

- [ ] Fix mason, asdf, and vscode all having different LSP sourcing
  - [x] gopls
  - [x] golangci-lint

### Linters

- [x] Fix golangci-lint for `make lint` invoking from shell (similar to above)
