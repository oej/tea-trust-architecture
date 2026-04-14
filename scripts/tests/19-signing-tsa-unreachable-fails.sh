#!/usr/bin/env bash
# scripts/tests/19-signing-tsa-unreachable-fails.sh
set -euo pipefail
. "$(dirname "$0")/lib.sh"

WORKDIR="$(new_workdir 19-signing-tsa-unreachable)"
OUTDIR="$WORKDIR/out"
INPUT="$FIXTURE_ROOT/sample.bin"

must_fail bash "$TEST_SIGN_SCRIPT" \
  --mode raw \
  --trust-domain "$TEST_TRUST_DOMAIN" \
  --tsa-url "https://tsa.invalid.example.test/tsr" \
  --output-dir "$OUTDIR" \
  "$INPUT"

echo "PASS: signing fails cleanly when TSA is unreachable"
