# bry-guy's dotfiles

This repo manages my machine setup with:
- `chezmoi` for applying dotfiles
- `brew` for machine-global packages and apps
- `1Password` for secrets, SSH, and identity material

A machine should be reproducible, composable, and scoped to a domain like `personal` or `work`.

## Important model

There are two different layers here:

1. **Repo/source layer**
   - the chezmoi source repo
   - contains bootstrap/setup scripts under `script/`
   - contains Brew manifests and profiles
2. **Applied target layer**
   - the actual files in `$HOME`
   - managed by `chezmoi apply`

The `script/` directory is part of the repo/source layer. It is **not** applied into `$HOME` by chezmoi.
That means fresh-machine bootstrap should be run from the repo/source checkout, not from an applied home-directory file.

## Bootstrap and setup

On a fresh macOS machine:

```sh
script/setup personal-macos
```

or for a work-scoped machine:

```sh
script/setup work-macos
```

`script/setup [brew-profile]` currently does the following:
- installs Homebrew if needed
- installs baseline Brew manifests
- installs 1Password dependencies
- applies chezmoi
- persists the selected Brew profile to `~/.config/dotfiles/brew-profile`
- applies the selected Brew profile if one was provided

Running `script/setup` without a profile still performs the baseline bootstrap only.

After that, Homebrew package state is managed through the manifest/profile system below.

## Brew manifests and profiles

Homebrew state is tracked via small reusable manifests under:
- `script/brew/manifests/`

Machine profiles are tracked under:
- `script/brew/profiles/`

### Current profiles
- `personal-macos`
- `work-macos`

### Current manifest layout
- `auth.1password`
- `base.core`
- `base.desktop-macos`
- `dev.common`
- `infra.common`
- `infra.personal`
- `infra.work`
- `ai.common`
- `ai.personal`
- `ai.work`
- `virtual.colima`
- `apps.common`
- `apps.personal`

### Useful commands

Apply a full profile:
```sh
script/brew-apply-profile personal-macos
```

`brew-apply-profile` automatically taps any required taps declared by the manifests and will continue past a failing manifest, then report a skipped-manifest summary at the end.

Apply one or more manifests directly:
```sh
script/brew-apply-manifest base.core ai.common ai.personal
```

Show the fully merged desired Brewfile for a profile:
```sh
script/brew-wanted personal-macos
```

Audit installed Homebrew state against a profile:
```sh
script/brew-audit personal-macos
```

### Current local machine selection
To avoid passing a profile every time, set one of:
- `DOTFILES_BREW_PROFILE=personal-macos`, or
- `~/.config/dotfiles/brew-profile` containing the selected profile name

Normally, `script/setup personal-macos` or `script/setup work-macos` writes this file automatically.
On this machine, the local profile file is used.

## Remembering Brew drift

Interactive shells wrap `brew` and mark package state dirty after successful mutating commands such as:
- `brew install`
- `brew uninstall`
- `brew tap`
- `brew upgrade`

When state is dirty, the shell reminds me to run:

```sh
script/brew-audit
```

The intended workflow is:
1. install something normally when needed
2. run `script/brew-audit`
3. classify it into the right manifest if it should stay
4. uninstall it if it was temporary or accidental

## Package ownership

### Brew owns
- machine-global CLI tools
- GUI apps
- workstation utilities
- machine-level infra / AI / virtualization tools

### mise owns
- project-local tooling
- versioned project runtimes
- repo-specific development toolchains

Global `mise` usage is intentionally minimized in favor of Brew for machine-global tools.

## Identity selection

Machine identity is selected locally, not committed.

### Commands
Apply the personal identity:
```sh
script/identity-apply personal
```

Inspect the current generated identity files:
```sh
script/identity-current
```

### What identity apply writes locally
- `~/.config/dotfiles/identity-profile`
- `~/.gitconfig.identity.local`
- `~/.ssh/config.identity`
- `~/.ssh/git-personal.pub` or `~/.ssh/git-work.pub`

Tracked git config includes `~/.gitconfig.identity.local`, so machine identity can change without changing the committed repo.

Tracked SSH config includes `~/.ssh/config.identity` and uses the 1Password SSH agent.

### Personal identity
Personal identity currently resolves to:
- git name: `Bryan Smith`
- git email: `bryan@bry-guy.net`
- git username: `bry-guy`

Personal identity expects a 1Password SSH key item titled `git-personal` in the `Private` vault.
For now, the helper also falls back to the legacy item title `brainbook.local`.

### Work identity
Work identity support exists structurally, but it is **not finalized yet**.
A dedicated work SSH key item titled `git-work` has already been created in the `Private` vault, but the work git defaults are still intentionally undecided.
When work details are known, this will be completed by:
- deciding work git name/email/username defaults
- updating `script/identity-apply work` defaults
- testing the work identity on a real work-scoped machine

Today, you can still apply work identity manually by supplying explicit environment variables:
```sh
DOTFILES_IDENTITY_WORK_NAME='Your Name' \
DOTFILES_IDENTITY_WORK_EMAIL='you@work.example' \
DOTFILES_IDENTITY_WORK_USERNAME='your-work-handle' \
script/identity-apply work
```

## Secrets

Secrets should live in 1Password, not in a sourced `~/.secrets` file.

Current shell behavior already loads some secrets from 1Password when available. For example, `GEMINI_API_KEY` is now loaded from:

```text
op://bry-guy/GEMINI_API_KEY/credential
```

The direction is:
- no new secrets in `~/.secrets`
- prefer `op read`, `op run`, or targeted shell loading
- keep machine-global secrets in the appropriate 1Password vault

## Current repo status / future work

Current major improvements already in place:
- composable Brew manifests and profiles
- profile-aware Brew audit flow
- machine-local identity selection
- initial migration away from `~/.secrets`

Known future work is tracked in `TODO.md`, especially:
- finalizing work identity
- improving non-work exclusion of work-only files
- expanding personal/work infra manifests

## Unified macOS / popOS Hotkeys

I use macOS hotkeys everywhere. In Linux, use kinto.sh. Rolling my own config is for the birds.
