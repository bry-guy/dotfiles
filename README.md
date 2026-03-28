# bry-guy's dotfiles

This repo manages my machine setup with:
- `yadm` for tracked dotfiles in `$HOME`
- `brew` for machine-global packages and apps
- `1Password` for secrets, SSH, and identity material

A machine should be reproducible, composable, and scoped to a domain like `personal` or `work`.

> Today, dotfiles is heavily configured around macOS. In the future, linux distributions and other OSes may see more functionality contributed.

## Important model

There are three layers here:

1. **Tracked home files**
   - this repo is laid out like `$HOME`
   - `yadm` tracks the shared dotfiles directly
   - examples: `.gitconfig`, `.zshrc`, `.config/nvim`, `.pi/agent/settings.json`
2. **Bootstrap/ops scripts**
   - tracked under `~/script`
   - used for setup, package management, identity helpers, and audits
3. **Local-only machine state**
   - identity files, secrets, and machine-specific overrides
   - intentionally not committed

That means `~/script` is part of the tracked home layout and is expected to be available on every machine after `yadm clone`.

## Bootstrap and setup

On a fresh macOS machine:

```sh
brew install yadm
yadm clone git@github.com:bry-guy/dotfiles.git
yadm bootstrap personal-macos
```

Or for a work-scoped machine:

```sh
yadm bootstrap work-macos
```

`yadm bootstrap` is a thin wrapper around `~/script/setup`, so the explicit form below also works:

```sh
~/script/setup personal-macos
```

Running `~/script/setup [brew-profile]` currently does the following:
- installs Homebrew if needed
- installs baseline Brew manifests
- installs 1Password dependencies where appropriate
- persists the selected Brew profile to `~/.config/dotfiles/brew-profile`
- applies the selected Brew profile if one was provided
- bootstraps SSH known_hosts for common remotes

Running `~/script/setup` without a profile still performs the baseline bootstrap only.

After that, Homebrew package state is managed through the manifest/profile system below.

## Brew manifests and profiles

Homebrew state is tracked via small reusable manifests under:
- `~/script/brew/manifests/`

Machine profiles are tracked under:
- `~/script/brew/profiles/`

The old top-level legacy files like `~/.brewfile.*` are no longer used and should not exist.

### Current profiles

Profiles represent the intended machine role and decide which Brew manifest groups get applied beyond the baseline bootstrap.

- `personal-macos`
  - intended for a personal macOS workstation
  - includes personal infrastructure, personal AI tooling, and personal GUI apps
- `work-macos`
  - intended for a work-scoped macOS workstation
  - includes work infrastructure and work AI tooling
  - currently does **not** include `apps.personal`

If no profile is selected, `~/script/setup` still performs the baseline bootstrap, but it does **not** persist `~/.config/dotfiles/brew-profile` and does **not** apply a role-specific package set.

### Current profile composition

#### `personal-macos`
- `auth.1password`
- `base.core`
- `base.desktop-macos`
- `dev.common`
- `infra.common`
- `infra.personal`
- `ai.common`
- `ai.personal`
- `virtual.colima`
- `apps.common`
- `apps.personal`

#### `work-macos`
- `auth.1password`
- `base.core`
- `base.desktop-macos`
- `dev.common`
- `infra.common`
- `infra.work`
- `ai.common`
- `ai.work`
- `virtual.colima`
- `apps.common`

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

`ai.common` currently includes shared AI/dev tooling such as `ccusage`, `claude-code`, `codex`, and `pi-coding-agent`.

### Useful commands

Apply a full profile:
```sh
~/script/brew-apply-profile personal-macos
```

`brew-apply-profile` automatically taps any required taps declared by the manifests and will continue past a failing manifest, then report a skipped-manifest summary at the end.

Apply one or more manifests directly:
```sh
~/script/brew-apply-manifest base.core ai.common ai.personal
```

Show the fully merged desired Brewfile for a profile:
```sh
~/script/brew-wanted personal-macos
```

Audit installed Homebrew state against a profile:
```sh
~/script/brew-audit personal-macos
```

Ignore a local-only package explicitly by adding a Brewfile-style entry to:
- `~/.config/dotfiles/brew-ignore`

Example:
```sh
cat >> ~/.config/dotfiles/brew-ignore <<'EOF'
brew "foo"
cask "bar"
tap "homebrew/cask-fonts"
EOF
```

`brew-audit` treats ignored entries as intentional local exceptions. It also reports stale ignores so the file stays tidy.

### Current local machine selection
To avoid passing a profile every time, set one of:
- `DOTFILES_BREW_PROFILE=personal-macos`, or
- `~/.config/dotfiles/brew-profile` containing the selected profile name

Normally, `~/script/setup personal-macos` or `~/script/setup work-macos` writes this file automatically.
On this machine, the local profile file is used.

## Remembering Brew drift

Interactive shells wrap `brew` and mark package state dirty after successful mutating commands such as:
- `brew install`
- `brew uninstall`
- `brew tap`
- `brew upgrade`

When state is dirty, the shell reminds me to run:

```sh
~/script/brew-audit
```

The intended workflow is:
1. install something normally when needed
2. run `~/script/brew-audit`
3. either add it to the right tracked manifest or explicitly add it to `~/.config/dotfiles/brew-ignore`
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
Apply machine-local identity files:
```sh
~/script/identity-apply personal
```

On a work-scoped machine, this also works and records the machine profile as `work`:
```sh
script/identity-apply work
```

Inspect the current generated identity files:
```sh
~/script/identity-current
```

### What identity apply writes locally
- `~/.config/dotfiles/identity-profile`
- `~/.gitconfig.identity.local`
- `~/.gitconfig.identity.work`
- `~/.ssh/config.identity`
- `~/.ssh/git-personal.pub`
- `~/.ssh/git-work.pub` (when available)

Tracked git config includes:
- `~/.gitconfig.identity.local` as the personal default
- `~/.gitconfig.identity.work` for repos whose remote points at `lumora.ghe.com`

Tracked SSH config includes `~/.ssh/config.identity` and uses the 1Password SSH agent.

### Host-based identity behavior
- `github.com` uses the personal SSH key and personal git email
- `lumora.ghe.com` uses the work SSH key and work git email

That means the same tracked dotfiles can be used on personal and work machines without changing committed config.
The machine-local files are generated from 1Password and kept out of the repo.

### Personal identity defaults
- git name: `Bryan Smith`
- git email: `bryan@bry-guy.net`
- 1Password account: `my.1password.com`
- 1Password vault: `Private`
- key item title: `git-personal`
- legacy fallback key item title: `brainbook.local`

### Work identity defaults
- git name: `Bryan Smith`
- git email: `bryan@lumoratech.com`
- 1Password account: `my.1password.com`
- 1Password vault: `Lumora`
- key item title: `git-work`

Both personal and work defaults can be overridden with environment variables before running `script/identity-apply`.

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

