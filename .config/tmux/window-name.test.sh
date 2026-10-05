#!/usr/bin/env bash
set -euo pipefail

script="$(dirname "$0")/window-name.sh"
tmux() { printf '%s\n' "$TEST_TITLE"; }
export -f tmux

check() {
  local command="$1" title="$2" expected="$3" actual
  actual="$(TEST_TITLE="$title" bash "$script" '' "$command" "${4:-$HOME}" '%1')"
  if [[ "$actual" != "$expected" ]]; then
    printf 'FAIL: %s: expected <%s>, got <%s>\n' "$title" "$expected" "$actual" >&2
    exit 1
  fi
}

check python3.14 '✳ job-user-filtering' 'cc:job-user-filtering'
check claude '✳ OPS-1284 504 investigation' 'cc:OPS-1284 504 investigation'
check node "π - my session - ${HOME##*/}" 'pi:my session'
check pi "π - name - with separators - ${HOME##*/}" 'pi:name - with separators'
check node "π - ${HOME##*/}" 'pi:~'
check pi "π -  - ${HOME##*/}" 'pi:~'
check python3.14 '✳ ' 'cc:~'
check claude '✳ 12345678-abcd-1234-abcd-123456789abc' 'cc:~'
check pi "π - 12345678-abcd-1234-abcd-123456789abc - ${HOME##*/}" 'pi:~'
check zsh '✳ stale Claude title' 'zsh:~'
check zsh "π - stale Pi title - ${HOME##*/}" 'zsh:~'
check claude '✳ "quotes" $(exit 99) `exit 99`' 'cc:"quotes" $(exit 99) `exit 99`'
check node "π - \"quotes\" \$(exit 99) - ${HOME##*/}" 'pi:"quotes" $(exit 99)'
check python3.14 'ordinary Python' 'python3.14:~'
check node 'ordinary Node' 'node:~'
check claude '' 'cc:~'
check nvim '✳ stale Claude title' 'nvim:~'

test_dir="$(mktemp -d)"
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/my-project/src"
git -C "$test_dir/my-project" init -q
check nvim '' 'nvim:my-project' "$test_dir/my-project/src"
ps() {
  case "$2" in
    100) printf '/bin/zsh\n' ;;
    200) printf '/opt/bin/mise exec -- just\n' ;;
    300) printf '%s\n' "$JUST_ARGS" ;;
    400) printf '/usr/bin/python3 server.py\n' ;;
  esac
}
pgrep() {
  case "$2" in
    100) printf '200\n' ;;
    200) printf '300\n' ;;
    300) printf '400\n' ;;
  esac
}
export -f ps pgrep

check_just() {
  local args="$1" expected="$2" pid="${3:-100}" actual
  actual="$(JUST_ARGS="$args" TEST_TITLE='' bash "$script" "$pid" python3 "$test_dir/my-project/src" '%1')"
  if [[ "$actual" != "$expected" ]]; then
    printf 'FAIL: %s: expected <%s>, got <%s>\n' "$args" "$expected" "$actual" >&2
    exit 1
  fi
}
check_just '/opt/bin/just run' 'just:my-project/run'
check_just '/opt/bin/just run' 'just:my-project/run' 300
check_just '/opt/bin/just --quiet --no-deps test-watch argument' 'just:my-project/test-watch'
check_just '/opt/bin/just -- module::run' 'just:my-project/module::run'
check_just '/opt/bin/just run build' 'just:my-project/run'
check_just '/opt/bin/just' 'just:my-project'
check_just '/opt/bin/just FOO=hello world run' 'just:my-project'
check_just '/opt/bin/just --set foo value run' 'just:my-project'
check_just '/opt/bin/just --justfile /some/file run' 'just:my-project'
check_just '/opt/bin/just --unknown run' 'just:my-project'
check_just '/opt/bin/just --command python3 server.py' 'just:my-project'
check_just '/opt/bin/just $(exit 99)' 'just:my-project'
printf 'All window-name checks passed.\n'
