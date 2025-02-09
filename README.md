# bry-guy's dotfiles

## Bootstrap and Setup

My configuration depends on a few core apps:
- `chezmoi`: dotfiles management
- `1password`: secrets management
- `brew`: app management

To use these dotfiles, clone and run:
```sh
script/bootstrap
script/setup
```

`bootstrap` installs the core dependencies to run `setup`.

## Installing Apps

Apps are namespaced via usage (WIP). Each machine has it's own `.brewfile`, which is *not tracked by chezmoi*. Instead, to "commit" an app, it must be added to one of the following:
```
.brewfile.core
.brewfile.me
.brewfile.dev
.brewfile.virtual
.brewfile.work
```
Brew namespaces can be installed via `script/install {namespace}`.

Use `brew-diff` to check for local changes not tracked in namespaced brewfiles.

## Unified macOS / popOS Hotkeys

I use macOS hotkeys everywhere. In Linux, use kinto.sh. Rolling my own config is for the birds.

