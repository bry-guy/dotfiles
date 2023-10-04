# bry-guy's dotfiles

## Unified macOS / popOS Hotkeys

I unify my hotkeys between macOS and popOS as much as possible. These are set in:
- `.config/karabiner/karabiner.json`
- [proposed] `.config/gnome/media-keys/keybindings.dconf`

Philosophically:
- macOS should be configured in Karabiner, so disabling config reverts to default
- Parity is constrained by macOS system constraints (popOS is more configurable)
- When hotkeys diverge substantially (Lock, Close Window, etc), use macOS hotkeys
- Terminal signals are not compromised

### Weird Hotkeys

- Open Link in New Tab: ctrl + space (Karabiner cannot remap button presses :sob:)

### popOS config

To create, change, and update `keybinds.dconf`:
- View: `conf dump /org/gnome/settings-daemon/plugins/media-keys/`
- Create Config: `dconf dump /org/gnome/settings-daemon/plugins/media-keys/ > ~/.config/gnome/media-keys/keybindings.dconf`
- Load Config: `dconf load /org/gnome/settings-daemon/plugins/media-keys/ < ~/.config/gnome/media-keys/keybindings.dconf`

### macOS System Preferences Keyboard Shortcuts

Most Keyboard Shortcuts are disabled on macOS, but a few are configured to create parity with popOS:

#### Mission Control

- Application Windows: `cmd + ``
- Move left a space: `option+<-`
- Move right a space: `option + ->`
- Switch to Desktop N: `option + N`

#### Keyboard

- Move focus or active to next window: `option + tab`

#### Screenshots

Default. Cmd+Shift+3/4 is swapped to Ctrl+Shift+3/4 via `karabiner.json`.

#### Spotlight

- Show Spotlight search: `option + /`

