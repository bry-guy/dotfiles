#!/usr/bin/env bash
# Regression tests for lumora-subagent-bash-guard.sh. Feeds hook JSON only; never runs payload commands.
set -uo pipefail

guard="$(cd "$(dirname "$0")" && pwd)/lumora-subagent-bash-guard.sh"
fake_home="$(mktemp -d)"
trap 'rm -rf "$fake_home"' EXIT
mkdir -p "$fake_home/.config/dotfiles"
fail=0

run() { # profile mode command -> exit code
  if [ "$1" = none ]; then rm -f "$fake_home/.config/dotfiles/identity-profile"
  else printf '%s\n' "$1" > "$fake_home/.config/dotfiles/identity-profile"; fi
  python3 -c 'import json,sys; print(json.dumps({"tool_input":{"command":sys.argv[1]}}))' "$3" |
    HOME="$fake_home" "$guard" "$2" >/dev/null 2>&1
  echo $?
}
expect() { # want profile mode command
  local got; got="$(run "$2" "$3" "$4")"
  if [ "$got" != "$1" ]; then echo "FAIL want=$1 got=$got [$2/$3] $4"; fail=1; fi
}
allow() { expect 0 work explore "$1"; }
deny() { expect 2 work explore "$1"; }

# Local reads
allow 'rg -n foo src'
allow 'git log --oneline -20'
allow 'git show HEAD~1 --stat'
allow 'git blame src/a.ts'
allow 'git diff main | head -50'
allow 'just test'
# GitHub reads
allow 'gh pr view 12'
allow 'GH_HOST=lumora.ghe.com gh pr diff 12'
# AWS reads
allow 'aws-vault exec dev-readonly -- aws logs describe-log-groups'
allow 'aws-vault exec dev-readonly -- aws sts get-caller-identity'

# Writes, remote, prod
deny 'rm -rf src'
deny 'git push origin main'
deny 'git log --output=/tmp/x'
deny 'git show --ext-diff HEAD'
deny 'gh pr comment 12 -b hi'
deny 'gh api -X POST repos/o/r/pulls'
deny 'aws-vault exec dev -- aws s3 ls'
deny 'aws-vault exec dev-readonly -- aws s3 rm s3://b/k'
deny 'just deploy --prod'
deny 'just test --env=staging'
deny 'kubectl get pods'
deny 'curl https://example.com'
# Shell operators and scratch escapes
deny 'rg foo; rm x'
deny 'rg foo && rm x'
deny 'echo $(id)'
deny 'rg foo > src/out.txt'
deny 'cd /tmp/claude-1/scratchpad && curl https://example.com'
deny 'git diff | sh'
# Unknown mode fails closed
expect 2 work bogus 'ls'
# Profile gate
expect 0 personal explore 'rm -rf src'
expect 2 none explore 'rm -rf src'
expect 2 garbage explore 'rm -rf src'

[ "$fail" = 0 ] && echo "all guard tests passed"
exit "$fail"
