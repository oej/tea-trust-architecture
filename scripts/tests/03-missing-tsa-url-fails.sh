#!/usr/bin/env bash
# scripts/tests/03-missing-tsa-url-fails.sh
set -euo pipefail
. "$(dirname "$0")/lib.sh"

WORKDIR="$(new_workdir 03-missing-tsa)"
OUTDIR="$WORKDIR/out"
INPUT="fixtures/sample.bin"

must_fail env TSA_URL= bash "$TEST_SCRIPT" \
  --mode raw \
  --trust-domain "$TEST_TRUST_DOMAIN" \
  --output-dir "$OUTDIR" \
  "$INPUT"

echo "PASS: missing TSA URL fails"
