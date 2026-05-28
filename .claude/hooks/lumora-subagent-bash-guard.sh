#!/usr/bin/env bash
set -euo pipefail

mode="${1:-coder}"
input="$(cat)"

block() {
  echo "Blocked by Lumora subagent Bash guard: $*" >&2
  exit 2
}

if command -v jq >/dev/null 2>&1; then
  cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')" || block "could not parse hook JSON with jq."
else
  command -v python3 >/dev/null 2>&1 || block "jq/python3 unavailable; cannot safely inspect Bash command."
  cmd="$(python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("command", ""))' <<< "$input")" || block "could not parse hook JSON with python3."
fi

# Trim leading/trailing whitespace.
cmd="$(printf '%s' "$cmd" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
[ -z "$cmd" ] && exit 0

# Global remote-environment guard: no subagent may target staging/prod.
if printf '%s\n' "$cmd" | grep -Eiq '(^|[[:space:]])--(prod|production|staging)(=|[[:space:]]|$)'; then
  block "--prod/--production/--staging must be run only by Opus with explicit user instruction."
fi

if printf '%s\n' "$cmd" | grep -Eiq '(^|[[:space:]])--(env|environment|stage|target)(=|[[:space:]])[^[:space:]]*(prod|production|staging)[^[:space:]]*([[:space:]]|$)'; then
  block "prod/staging environment flags must be run only by Opus with explicit user instruction."
fi

if printf '%s\n' "$cmd" | grep -Eiq '(^|[[:space:]])(AWS_PROFILE|AWS_ENV|ENV|ENVIRONMENT|STAGE|TARGET_ENV|DEPLOY_ENV)=[^[:space:]]*(prod|production|staging)[^[:space:]]*([[:space:]]|$)'; then
  block "prod/staging environment variables must be run only by Opus with explicit user instruction."
fi

# Coder is trusted for implementation Bash, except operational commands and the global staging/prod guard above.
if [ "$mode" = "coder" ]; then
  if printf '%s\n' "$cmd" | grep -Eiq '(^|[[:space:]])just[[:space:]]+(release|deploy)([[:space:]]|$)|(^|[[:space:]])(release|deploy)([[:space:]]|$)'; then
    block "coder may not run operational release/deploy commands."
  fi
  exit 0
fi

# Fetcher is Haiku: it gets only simple single just commands, not arbitrary shell.
if [ "$mode" = "fetcher" ]; then
  case "$cmd" in
    *$'\n'*) block "fetcher may only run one-line just commands." ;;
  esac

  if printf '%s\n' "$cmd" | grep -Eq '[;&|<>`]|\$\('; then
    block "fetcher may only run simple just commands without shell operators, command substitution, pipes, or redirection."
  fi

  case "$cmd" in
    just\ *) ;;
    just) block "fetcher may not run bare 'just'; specify an explicit recipe or 'just --list'." ;;
    *) block "fetcher may only run simple just commands." ;;
  esac

  # Keep fetcher in the current repo's justfile and avoid option-based indirection.
  if printf '%s\n' "$cmd" | grep -Eq '(^|[[:space:]])(--justfile|--working-directory|--dotenv-path|-f|-d)(=|[[:space:]]|$)'; then
    block "fetcher may not override the justfile, working directory, or dotenv path."
  fi

  # Fetcher may not run release/deploy recipes. Coder may, subject to the global staging/prod guard.
  if printf '%s\n' "$cmd" | grep -Eiq '(^|[[:space:]])(release|deploy)([[:space:]]|$)'; then
    block "fetcher may not run operational release/deploy commands."
  fi

  exit 0
fi

block "unknown guard mode '$mode'."
