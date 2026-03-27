#!/usr/bin/env bash
set -euo pipefail

pane_pid="${1:-}"
current_command="${2:-shell}"
pane_path="${3:-$PWD}"
pane_title="${4:-}"

trim() {
  local value="$1"
  value="${value#${value%%[![:space:]]*}}"
  value="${value%${value##*[![:space:]]}}"
  printf '%s' "$value"
}

abbrev_segment() {
  local segment="$1"

  if [[ -z "$segment" || "$segment" == "." || "$segment" == ".." ]]; then
    printf '%s' "$segment"
    return
  fi

  if [[ "$segment" == .* ]]; then
    local rest="${segment#.}"
    if [[ -z "$rest" ]]; then
      printf '.'
    elif (( ${#rest} <= 2 )); then
      printf '.%s' "$rest"
    else
      printf '.%s' "${rest:0:2}"
    fi
    return
  fi

  if (( ${#segment} <= 2 )); then
    printf '%s' "$segment"
  else
    printf '%s' "${segment:0:2}"
  fi
}

shorten_path() {
  local path="$1"

  if [[ -n "${HOME:-}" && "$path" == "$HOME" ]]; then
    printf '~'
    return
  fi

  if [[ -n "${HOME:-}" && "$path" == "$HOME/"* ]]; then
    path="~${path#$HOME}"
  fi

  IFS='/' read -r -a parts <<< "$path"

  local out=""
  local last_index=$(( ${#parts[@]} - 1 ))
  local part

  for i in "${!parts[@]}"; do
    part="${parts[$i]}"

    if [[ $i -eq 0 ]]; then
      if [[ -z "$part" ]]; then
        out="/"
      else
        out="$part"
      fi
      continue
    fi

    [[ -z "$part" ]] && continue

    if [[ $i -lt $last_index ]]; then
      part="$(abbrev_segment "$part")"
    fi

    if [[ "$out" == "/" ]]; then
      out="/$part"
    else
      out="$out/$part"
    fi
  done

  printf '%s' "$out"
}

ps_command_name() {
  local pid="$1"
  local args exe

  args="$(ps -p "$pid" -o args= 2>/dev/null || true)"
  args="$(trim "$args")"
  if [[ -n "$args" ]]; then
    exe="${args%% *}"
    exe="${exe##*/}"
    exe="${exe#-}"
    if [[ -n "$exe" ]]; then
      printf '%s' "$exe"
      return
    fi
  fi

  exe="$(ps -p "$pid" -o comm= 2>/dev/null || true)"
  exe="$(trim "$exe")"
  exe="${exe##*/}"
  exe="${exe#-}"
  printf '%s' "$exe"
}

is_wrapper_command() {
  case "$1" in
    bash|sh|zsh|fish|env|direnv|mise|sudo|nohup|time|setsid)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

resolve_command() {
  local pid="$1"
  local fallback="$2"
  local title="$3"
  local candidate child_name resolved=""
  local -a children=()

  if [[ "$pid" =~ ^[0-9]+$ ]]; then
    candidate="$pid"

    mapfile -t children < <(pgrep -P "$candidate" 2>/dev/null || true)
    if (( ${#children[@]} == 1 )); then
      candidate="${children[0]}"
      child_name="$(ps_command_name "$candidate")"
      resolved="$child_name"

      while [[ -n "$resolved" ]] && is_wrapper_command "$resolved"; do
        mapfile -t children < <(pgrep -P "$candidate" 2>/dev/null || true)
        if (( ${#children[@]} != 1 )); then
          break
        fi

        candidate="${children[0]}"
        child_name="$(ps_command_name "$candidate")"
        [[ -z "$child_name" ]] && break
        resolved="$child_name"
      done
    fi
  fi

  if [[ -n "$resolved" ]]; then
    printf '%s' "$resolved"
    return
  fi

  fallback="${fallback##*/}"
  fallback="${fallback#-}"

  if [[ "$fallback" == "node" && "$title" == "π - "* ]]; then
    printf 'pi'
    return
  fi

  printf '%s' "$fallback"
}

location_name() {
  local path="$1"
  local root

  if root="$(git -C "$path" rev-parse --show-toplevel 2>/dev/null)"; then
    printf '%s' "${root##*/}"
    return
  fi

  printf '%s' "$(shorten_path "$path")"
}

command_name="$(resolve_command "$pane_pid" "$current_command" "$pane_title")"
printf '%s@%s\n' "$command_name" "$(location_name "$pane_path")"
