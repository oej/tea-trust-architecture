#!/usr/bin/env bash
set -euo pipefail

TEST_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_ROOT="$TEST_LIB_DIR"
WORK_ROOT="${WORK_ROOT:-$TEST_ROOT/.work}"
FIXTURE_ROOT="${FIXTURE_ROOT:-$TEST_ROOT/fixtures}"

TEST_SIGN_SCRIPT="${TEST_SIGN_SCRIPT:-$(cd "$TEST_ROOT/.." && pwd)/sign-objects.sh}"
TEST_CONSUMER_SCRIPT="${TEST_CONSUMER_SCRIPT:-$(cd "$TEST_ROOT/.." && pwd)/consumer-validation.sh}"

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

new_workdir() {
  local name="$1"
  local dir="$WORK_ROOT/$name"
  rm -rf "$dir"
  mkdir -p "$dir"
  printf '%s\n' "$dir"
}
