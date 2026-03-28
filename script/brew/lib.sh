#!/bin/bash
set -euo pipefail

BREW_LIB_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd -- "$BREW_LIB_DIR/../.." && pwd)"
BREW_MANIFEST_DIR="$BREW_LIB_DIR/manifests"
BREW_PROFILE_DIR="$BREW_LIB_DIR/profiles"
BREW_STATE_DIR="$HOME/.local/state/dotfiles"
BREW_DIRTY_FILE="$BREW_STATE_DIR/brew-dirty"
BREW_LAST_RUN_FILE="$BREW_STATE_DIR/brew-audit-last-run"
BREW_PROFILE_FILE="$HOME/.config/dotfiles/brew-profile"
BREW_IGNORE_FILE="${DOTFILES_BREW_IGNORE_FILE:-$HOME/.config/dotfiles/brew-ignore}"

error() {
    echo "Error: $*" >&2
    exit 1
}

brew_bin() {
    local candidate

    if command -v brew >/dev/null 2>&1; then
        command -v brew
        return 0
    fi

    for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
        if [ -x "$candidate" ]; then
            echo "$candidate"
            return 0
        fi
    done

    error "Homebrew is not installed or not on PATH."
}

resolve_profile() {
    local requested="${1:-}"
    local profile

    if [ -n "$requested" ]; then
        echo "$requested"
        return 0
    fi

    if [ -n "${DOTFILES_BREW_PROFILE:-}" ]; then
        echo "$DOTFILES_BREW_PROFILE"
        return 0
    fi

    if [ -f "$BREW_PROFILE_FILE" ]; then
        profile="$(awk 'NF { print; exit }' "$BREW_PROFILE_FILE")"
        if [ -n "$profile" ]; then
            echo "$profile"
            return 0
        fi
    fi

    error "Unable to resolve brew profile. Pass one explicitly, set DOTFILES_BREW_PROFILE, or write ~/.config/dotfiles/brew-profile."
}

profile_path() {
    echo "$BREW_PROFILE_DIR/$1"
}

manifest_path() {
    echo "$BREW_MANIFEST_DIR/$1.Brewfile"
}

ignore_file_path() {
    echo "$BREW_IGNORE_FILE"
}

manifest_taps() {
    local path
    path="$(manifest_path "$1")"

    [ -f "$path" ] || error "Manifest '$1' not found at $path"

    sed -n -E 's/^[[:space:]]*tap[[:space:]]+"([^"]+)".*/\1/p' "$path"
}

ensure_manifest_taps() {
    local tap_name
    local failed=0

    while IFS= read -r tap_name; do
        [ -n "$tap_name" ] || continue
        if ! brew tap | grep -qxF "$tap_name"; then
            echo "Tapping '$tap_name'..."
            if ! brew tap "$tap_name"; then
                echo "Error: failed to tap '$tap_name'" >&2
                failed=1
            fi
        fi
    done < <(manifest_taps "$1")

    return "$failed"
}

profile_manifests() {
    local profile
    local path

    profile="$(resolve_profile "${1:-}")"
    path="$(profile_path "$profile")"

    [ -f "$path" ] || error "Profile '$profile' not found at $path"

    awk '
        /^[[:space:]]*(#|$)/ { next }
        {
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0)
            print $0
        }
    ' "$path"
}

normalize_brewfile() {
    awk '
        /^[[:space:]]*(#|$)/ { next }
        {
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0)
            print $0
        }
    ' "$@" | python3 -c '
import sys
buckets = {"tap": [], "brew": [], "cask": [], "mas": [], "vscode": [], "other": []}
seen = set()
for raw in sys.stdin:
    line = raw.strip()
    if not line or line.startswith("#") or line in seen:
        continue
    seen.add(line)
    head = line.split(None, 1)[0]
    buckets.setdefault(head, buckets["other"]).append(line)
for key in ["tap", "brew", "cask", "mas", "vscode", "other"]:
    for line in sorted(buckets.get(key, [])):
        print(line)
'
}

ensure_state_dir() {
    mkdir -p "$BREW_STATE_DIR"
}
