# bry-guy's dotfiles

## Bootstrap and Setup

My setup still uses:
- `chezmoi` for dotfile application
- `1Password` for secrets and SSH
- `brew` for machine-global packages and apps

On a fresh macOS machine, run:
```sh
script/setup
```

`setup` bootstraps Homebrew, installs the baseline Brew manifests, and applies chezmoi.

## Brew manifests and profiles

Homebrew state is tracked via small reusable manifests under:
- `script/brew/manifests/`

Machine profiles are tracked under:
- `script/brew/profiles/`

Current profiles:
- `personal-macos`
- `work-macos`

### Useful commands

Apply a full profile:
```sh
script/brew-apply-profile personal-macos
```

Apply one or more manifests:
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

## Remembering Brew drift

Interactive shells wrap `brew` and mark package state dirty after successful mutating commands.
When that happens, the shell reminds me to run `script/brew-audit`.

To avoid passing a profile every time, set one of:
- `DOTFILES_BREW_PROFILE=personal-macos`, or
- `~/.config/dotfiles/brew-profile` containing `personal-macos`

## Package ownership

- **Brew** owns machine-global CLI tools, GUI apps, and workstation utilities.
- **mise** is preferred for project-local tooling and versioned project runtimes.

## Unified macOS / popOS Hotkeys

I use macOS hotkeys everywhere. In Linux, use kinto.sh. Rolling my own config is for the birds.
