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
  block "--prod/--production/--staging must be run only by Claude with explicit user instruction."
fi

if printf '%s\n' "$cmd" | grep -Eiq '(^|[[:space:]])--(env|environment|stage|target)(=|[[:space:]])[^[:space:]]*(prod|production|staging)[^[:space:]]*([[:space:]]|$)'; then
  block "prod/staging environment flags must be run only by Claude with explicit user instruction."
fi

if printf '%s\n' "$cmd" | grep -Eiq '(^|[[:space:]])(AWS_PROFILE|AWS_ENV|ENV|ENVIRONMENT|STAGE|TARGET_ENV|DEPLOY_ENV)=[^[:space:]]*(prod|production|staging)[^[:space:]]*([[:space:]]|$)'; then
  block "prod/staging environment variables must be run only by Claude with explicit user instruction."
fi

# Global kubectl prohibition: no subagent may run kubectl. Claude is also instructed to avoid it (see CLAUDE.md).
if printf '%s\n' "$cmd" | grep -Eiq '(^|[[:space:]])kubectl([[:space:]]|$)'; then
  block "kubectl is forbidden for all subagents. Claude must avoid it as well (see CLAUDE.md)."
fi

# gh-fetcher may run read-only GitHub/GHE commands only.
if [ "$mode" = "gh-fetcher" ]; then
  case "$cmd" in
    *$'\n'*) block "gh-fetcher may only run one-line gh commands." ;;
  esac

  if printf '%s\n' "$cmd" | grep -Eq '[;&|<>`]|\$\('; then
    block "gh-fetcher may not use shell operators, pipes, redirection, or command substitution."
  fi

  stripped="$cmd"
  stripped="${stripped#GH_HOST=lumora.ghe.com }"

  case "$stripped" in
    gh\ pr\ comment\ *|gh\ pr\ review\ *|gh\ pr\ merge\ *|gh\ pr\ checkout\ *|gh\ pr\ create\ *|gh\ pr\ edit\ *|gh\ pr\ close\ *|gh\ pr\ reopen\ *|gh\ workflow\ run\ *|gh\ repo\ fork\ *|gh\ auth\ login\ *)
      block "gh-fetcher may only run read-only gh commands."
      ;;
  esac

  if printf '%s\n' "$stripped" | grep -Eiq '(^|[[:space:]])(-X|--method)(=|[[:space:]]|$)'; then
    block "gh-fetcher may not override gh api HTTP methods."
  fi

  case "$stripped" in
    gh\ api\ graphql\ *)
      if printf '%s\n' "$stripped" | grep -Eiq '(^|[^[:alnum:]_])mutation([^[:alnum:]_]|$)'; then
        block "gh-fetcher may not run GraphQL mutations."
      fi
      ;;
    gh\ api\ *)
      if printf '%s\n' "$stripped" | grep -Eiq '(^|[[:space:]])(-f|--field|-F|--raw-field|--input)(=|[[:space:]]|$)'; then
        block "gh-fetcher may not send REST gh api fields or request bodies."
      fi
      ;;
  esac

  case "$stripped" in
    gh\ pr\ view\ *|gh\ pr\ diff\ *|gh\ pr\ checks\ *|gh\ api\ repos/*/pulls/*|gh\ api\ repos/*/issues/*/comments*|gh\ api\ repos/*/commits/*/status*|gh\ api\ repos/*/commits/*/check-runs*|gh\ api\ graphql\ *) exit 0 ;;
  esac

  block "gh-fetcher command is outside the read-only gh allowlist."
fi

# Coder is trusted for implementation Bash, except operational commands and the global staging/prod guard above.
if [ "$mode" = "coder" ]; then
  if printf '%s\n' "$cmd" | grep -Eiq '(^|[[:space:]])just[[:space:]]+(release|deploy)([[:space:]]|$)|(^|[[:space:]])(release|deploy)([[:space:]]|$)'; then
    block "coder may not run operational release/deploy commands."
  fi
  exit 0
fi

# Basher is Haiku. Two tiers:
#   * Scratchpad sandbox (relaxed) — commands operating inside the session
#     scratchpad get a throwaway local sandbox: chaining, pipes, redirection,
#     file mutation, and local build/test tooling are all allowed.
#   * Everywhere else (strict) — narrow default-deny allowlist of diagnostics and
#     safe local lifecycle commands, plus a single pipe chain into read-only
#     filters and redirection into the scratchpad.
# The global prod/staging + kubectl guards above apply to BOTH tiers.
if [ "$mode" = "basher" ]; then
  case "$cmd" in
    *$'\n'*) block "basher may only run one-line commands." ;;
  esac

  scratch_re='(/private)?/tmp/claude-[^[:space:]]+/scratchpad'

  # --- Scratchpad sandbox (relaxed) -----------------------------------------
  # Entered when the command sets cwd into the scratchpad via a leading
  # `cd <scratchpad>`, or is a `pnpm -C/--dir <scratchpad> ...` invocation.
  # Inside, arbitrary local commands are permitted; we still block network,
  # remote, privileged, remote-git, and package-publish egress (dangerous
  # regardless of cwd). Confinement is best-effort: a relaxed command could
  # still name an absolute path outside the scratchpad. This is an accepted
  # tradeoff for a cooperative agent working on ephemeral, gitignored files.
  if printf '%s\n' "$cmd" | grep -Eq "^cd[[:space:]]+${scratch_re}" \
     || printf '%s\n' "$cmd" | grep -Eq "^pnpm[[:space:]]+(-C|--dir)[[:space:]]+${scratch_re}/"; then
    if printf '%s\n' "$cmd" | grep -Eiq '(^|[[:space:]])(sudo|aws|curl|wget|ssh|scp|sftp|rsync|nc|telnet)([[:space:]]|$)'; then
      block "basher may not run privileged, network, or remote-service commands, even in the scratchpad."
    fi
    if printf '%s\n' "$cmd" | grep -Eiq '(^|[[:space:]])git[[:space:]]+(push|pull|fetch|clone|remote)([[:space:]]|$)'; then
      block "basher may not run remote git operations, even in the scratchpad."
    fi
    if printf '%s\n' "$cmd" | grep -Eiq '(^|[[:space:]])(pnpm|npm|npx|yarn)[[:space:]]+publish([[:space:]]|$)'; then
      block "basher may not publish packages, even in the scratchpad."
    fi
    exit 0
  fi

  # --- Strict tier (real repos) ---------------------------------------------
  # Allowed operators: a single pipe chain into read-only filters, and
  # redirection (>/>>) targeting a scratchpad path. Everything else is blocked.
  if printf '%s\n' "$cmd" | grep -Eq '[;&`]|\$\(|<'; then
    block "basher may not use command chaining (;, &&, &), backgrounding, input redirection, or command substitution."
  fi

  # Redirection: every > / >> target must be a scratchpad path.
  if printf '%s\n' "$cmd" | grep -Eq '>'; then
    redir_all=$(printf '%s\n' "$cmd" | grep -oE '>>?' | wc -l | tr -d ' ' || true)
    redir_ok=$(printf '%s\n' "$cmd" | grep -oE ">>?[[:space:]]*${scratch_re}[^[:space:]]*" | wc -l | tr -d ' ' || true)
    if [ "$redir_all" != "$redir_ok" ]; then
      block "basher redirection may target only a scratchpad path (.../claude-*/.../scratchpad/...)."
    fi
  fi

  # Pipes: stages after the first must be read-only filters. The first stage is
  # validated against the allowlist below.
  cmd_head="$cmd"
  if printf '%s\n' "$cmd" | grep -q '|'; then
    IFS='|' read -ra _stages <<< "$cmd" || true
    _i=1
    while [ "$_i" -lt "${#_stages[@]}" ]; do
      _stage="$(printf '%s' "${_stages[$_i]}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
      _bin="$(printf '%s' "$_stage" | awk '{print $1}')"
      case "$_bin" in
        grep|head|tail|wc|sort|uniq|jq|cut) ;;
        *) block "basher pipe stage '$_bin' is not a read-only filter (allowed: grep head tail wc sort uniq jq cut)." ;;
      esac
      _i=$((_i + 1))
    done
    cmd_head="$(printf '%s' "${_stages[0]}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
  fi

  if printf '%s\n' "$cmd" | grep -Eq '^[A-Za-z_][A-Za-z0-9_]*='; then
    block "basher may not set environment variables."
  fi

  if printf '%s\n' "$cmd" | grep -Eiq '(^|[[:space:]])(sudo|rm|rmdir|mv|cp|chmod|chown|aws|curl|wget|ssh|scp|sftp|kubectl|mysql|redis-cli|brew|npx|npm|yarn)([[:space:]]|$)'; then
    block "basher may not run mutating, network, remote-service, package-manager, or privileged commands outside the scratchpad."
  fi

  if printf '%s\n' "$cmd" | grep -Eiq '(^|[[:space:]])git[[:space:]]+(add|commit|push|pull|fetch|merge|rebase|reset|checkout|switch|restore|clean|stash)([[:space:]]|$)'; then
    block "basher may only run read-only git status/diff commands."
  fi

  if printf '%s\n' "$cmd" | grep -Eiq '(^|[[:space:]])just[[:space:]]+(fix|run|serve|server|release|deploy)([[:space:]]|$)'; then
    block "basher may not run mutating, remote lifecycle, release, or deploy just recipes."
  fi

  if printf '%s\n' "$cmd" | grep -Eiq '(^|[[:space:]])(--write|format)(=|[[:space:]]|$)'; then
    block "basher may not run formatter/write commands."
  fi

  if printf '%s\n' "$cmd" | grep -Eq '(^|[[:space:]])find([[:space:]]|$)' && \
      printf '%s\n' "$cmd" | grep -Eq '(^|[[:space:]])-(exec|ok|delete)([[:space:]]|$)'; then
    block "basher may not run mutating or exec-style find actions."
  fi

  if printf '%s\n' "$cmd" | grep -Eiq '(^|[[:space:]])psql([[:space:]]|$)'; then
    if printf '%s\n' "$cmd" | grep -Eiq 'postgres(ql)?://|(^|[[:space:]])(host|hostaddr|service)='; then
      block "basher psql may not use connection URLs or libpq remote connection strings."
    fi

    if printf '%s\n' "$cmd" | grep -Eiq '(^|[[:space:]])(--host|-h)(=|[[:space:]])' && \
        ! printf '%s\n' "$cmd" | grep -Eiq '(^|[[:space:]])(--host|-h)(=|[[:space:]])['"'"'\"]?(localhost|127\.0\.0\.1|::1|/tmp|/var/run/postgresql|/opt/homebrew/var/run/postgresql)['"'"'\"]?([[:space:]]|$)'; then
      block "basher psql may connect only to local sockets or localhost."
    fi

    if printf '%s\n' "$cmd" | grep -Eiq '(^|[[:space:]])-h[^[:space:]]+' && \
        ! printf '%s\n' "$cmd" | grep -Eiq '(^|[[:space:]])-h(localhost|127\.0\.0\.1|::1|/tmp|/var/run/postgresql|/opt/homebrew/var/run/postgresql)([[:space:]]|$)'; then
      block "basher psql may connect only to local sockets or localhost."
    fi

    if printf '%s\n' "$cmd" | grep -Eiq '(^|[[:space:]_./-])(prod|production|staging)([[:space:]_./-]|$)'; then
      block "basher psql may not target staging/prod-like databases or paths."
    fi

    if ! printf '%s\n' "$cmd" | grep -Eiq '(^|[[:space:]])(-c|--command)(=|[[:space:]])|(^|[[:space:]])(-l|--list|--version)([[:space:]]|$)'; then
      block "basher psql must be non-interactive: use -c/--command, -l/--list, or --version."
    fi

    if printf '%s\n' "$cmd" | grep -Eiq '(^|[[:space:]])(-f|--file)(=|[[:space:]]|$)|(^|[^[:alnum:]_])(insert|update|delete|merge|drop|alter|truncate|create|replace|grant|revoke|comment|copy|vacuum|analyze|reindex|cluster|refresh|listen|notify|call|do)([^[:alnum:]_]|$)|\\(copy|gexec|!|o)([[:space:]]|$)'; then
      block "basher psql may run only read-only local inspection commands."
    fi
  fi

  case "$cmd_head" in
    just\ --list|just\ status|just\ lint|just\ build|just\ build\ *|just\ test|just\ test\ *|just\ up|just\ up\ *|just\ down|just\ down\ *|just\ restart|just\ restart\ *) exit 0 ;;
    pnpm\ typecheck|pnpm\ typecheck\ *) exit 0 ;;
    pnpm\ exec\ biome\ check|pnpm\ exec\ biome\ check\ *) exit 0 ;;
    git\ status|git\ status\ *|git\ diff|git\ diff\ *|git\ branch\ --show-current|git\ rev-parse\ --show-toplevel|git\ ls-files|git\ ls-files\ *) exit 0 ;;
    rg|rg\ *|grep|grep\ *|find|find\ *|ls|ls\ *|pwd|tail|tail\ *|head|head\ *|wc|wc\ *|lsof|lsof\ *|ps|ps\ *|pgrep|pgrep\ *) exit 0 ;;
    docker\ ps|docker\ ps\ *|docker\ logs|docker\ logs\ *|docker\ inspect|docker\ inspect\ *) exit 0 ;;
    flyway\ info|flyway\ info\ *|flyway\ validate|flyway\ validate\ *|flyway\ *\ info|flyway\ *\ info\ *|flyway\ *\ validate|flyway\ *\ validate\ *) exit 0 ;;
    psql\ --version|psql\ -l|psql\ --list|psql\ -l\ *|psql\ --list\ *|psql\ *\ -c\ *|psql\ *\ --command\ *|psql\ *\ --command=*|psql\ -c\ *|psql\ --command\ *|psql\ --command=*) exit 0 ;;
  esac

  block "basher command is outside the allowed diagnostic command set."
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

# Remoter is Haiku: read-only AWS diagnostics via aws-vault with -readonly profiles only.
if [ "$mode" = "remoter" ]; then
  case "$cmd" in
    *$'\n'*) block "remoter may only run one-line commands." ;;
  esac

  if printf '%s\n' "$cmd" | grep -Eq '&&|;|\$\(|`'; then
    block "remoter may not chain commands or use substitution."
  fi
  if printf '%s\n' "$cmd" | grep -Eq '&[[:space:]]*$'; then
    block "remoter may not background commands."
  fi

  # At most one pipe, and the target must be a filter utility.
  pipe_count=$(printf '%s\n' "$cmd" | awk -F'|' '{print NF-1}')
  if [ "$pipe_count" -gt 1 ]; then
    block "remoter may use at most one pipe (to a filter utility)."
  fi
  if [ "$pipe_count" -eq 1 ]; then
    tail_cmd="$(printf '%s\n' "$cmd" | sed -E 's/^.*\|[[:space:]]*//')"
    pipe_target="$(printf '%s\n' "$tail_cmd" | awk '{print $1}')"
    case "$pipe_target" in
      grep|head|tail|wc|awk|sort|uniq|jq|cut|tr|sed) ;;
      *) block "remoter pipe target '$pipe_target' is not in {grep,head,tail,wc,awk,sort,uniq,jq,cut,tr,sed}." ;;
    esac
    head_cmd="$(printf '%s\n' "$cmd" | sed -E 's/[[:space:]]*\|[[:space:]]*[^|]+$//')"
  else
    head_cmd="$cmd"
  fi

  # Redirection only to /tmp/remoter-*.
  if printf '%s\n' "$head_cmd" | grep -Eq '>'; then
    if ! printf '%s\n' "$head_cmd" | grep -Eq '>[[:space:]]*/tmp/remoter-[^[:space:]]+'; then
      block "remoter redirection must target /tmp/remoter-* only."
    fi
  fi

  case "$head_cmd" in
    aws-vault\ exec\ *)
      profile="$(printf '%s\n' "$head_cmd" | awk '{print $3}')"
      case "$profile" in
        *-readonly) ;;
        *) block "remoter aws-vault profile must end in -readonly (got '$profile')." ;;
      esac

      if ! printf '%s\n' "$head_cmd" | grep -Eq '^aws-vault[[:space:]]+exec[[:space:]]+[^[:space:]]+[[:space:]]+--[[:space:]]+aws[[:space:]]'; then
        block "remoter must invoke aws as: aws-vault exec <profile>-readonly -- aws <subcommand>."
      fi

      after_aws="$(printf '%s\n' "$head_cmd" | sed -E 's/^aws-vault[[:space:]]+exec[[:space:]]+[^[:space:]]+[[:space:]]+--[[:space:]]+aws[[:space:]]+//')"
      service="$(printf '%s\n' "$after_aws" | awk '{print $1}')"
      verb="$(printf '%s\n' "$after_aws" | awk '{print $2}')"

      case "$service" in
        logs)
          case "$verb" in
            describe-log-groups|describe-log-streams|start-query|get-query-results|filter-log-events|get-log-events|describe-queries|describe-resource-policies|describe-subscription-filters|describe-metric-filters|test-metric-filter) ;;
            *) block "remoter aws logs verb '$verb' is not in the allowed read-only set." ;;
          esac
          ;;
        rds)
          case "$verb" in
            describe-*|download-db-log-file-portion) ;;
            *) block "remoter aws rds verb '$verb' is not allowed (use describe-* or download-db-log-file-portion)." ;;
          esac
          ;;
        s3)
          case "$verb" in
            ls) ;;
            *) block "remoter aws s3 verb '$verb' is not allowed (only ls)." ;;
          esac
          ;;
        s3api)
          case "$verb" in
            list-*|head-object|head-bucket|get-object-acl|get-bucket-*) ;;
            *) block "remoter aws s3api verb '$verb' is not allowed (read-only only)." ;;
          esac
          ;;
        sts)
          case "$verb" in
            get-caller-identity) ;;
            *) block "remoter aws sts verb '$verb' is not allowed (only get-caller-identity)." ;;
          esac
          ;;
        *)
          case "$verb" in
            describe-*|list-*|get-*) ;;
            *) block "remoter aws verb '$verb' for service '$service' is not in the read-only verb set (describe-*/list-*/get-*)." ;;
          esac
          ;;
      esac

      exit 0
      ;;
    python3\ -c\ *|python\ -c\ *)
      script_body="$(printf '%s\n' "$head_cmd" | sed -E 's/^python3?[[:space:]]+-c[[:space:]]+//')"
      if printf '%s\n' "$script_body" | grep -Eiq '(^|[^[:alnum:]_])(kubectl|subprocess|requests|urllib|socket|paramiko|fabric)([^[:alnum:]_]|$)'; then
        block "remoter python3 -c may not import subprocess/network libs or reference kubectl."
      fi
      if printf '%s\n' "$script_body" | grep -Eiq 'os\.(system|exec|popen|spawn|fork)'; then
        block "remoter python3 -c may not call os.system/exec/popen/spawn/fork."
      fi
      if ! printf '%s\n' "$script_body" | grep -Eiq '(boto3|botocore|aws_)'; then
        block "remoter python3 -c must use boto3 / botocore for AWS access."
      fi
      exit 0
      ;;
    *)
      block "remoter command must start with 'aws-vault exec <profile>-readonly -- aws ...' or 'python3 -c <boto3-script>'."
      ;;
  esac
fi

block "unknown guard mode '$mode'."
