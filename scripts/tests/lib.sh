#!/usr/bin/env bash
# tests/lib.sh
set -euo pipefail
TEST_SIGN_SCRIPT="${TEST_SIGN_SCRIPT:-$(cd "$(dirname "$0")/.." && pwd)/sign-objects.sh}"
TEST_CONSUMER_SCRIPT="${TEST_CONSUMER_SCRIPT:-$(cd "$(dirname "$0")/.." && pwd)/consumer-validation.sh}"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

must_exist() {
  [ -e "$1" ] || fail "expected file to exist: $1"
}

must_not_exist() {
  [ ! -e "$1" ] || fail "expected file to be absent: $1"
}

must_contain() {
  local file="$1"
  local needle="$2"
  grep -F "$needle" "$file" >/dev/null 2>&1 || fail "expected '$needle' in $file"
}

must_fail() {
  if "$@"; then
    fail "command unexpectedly succeeded: $*"
  fi
}
make_tmpdir() {
  new_workdir tmp
}

new_workdir() {
  local name="$1"
  local dir="tests/.work/${name}"
  rm -rf "$dir"
  mkdir -p "$dir"
  printf '%s\n' "$dir"
}
