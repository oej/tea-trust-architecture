#!/usr/bin/env bash
# tests/06-invalid-json-jcs-fails.sh
set -euo pipefail
. "$(dirname "$0")/lib.sh"

WORKDIR="$(new_workdir 06-invalid-json)"
OUTDIR="$WORKDIR/out"
INPUT="$FIXTURE_ROOT/invalid.json"

must_fail bash "$TEST_SCRIPT" \
  --mode jcs \
  --trust-domain "$TEST_TRUST_DOMAIN" \
  --tsa-url "$TSA_URL" \
  --tsa-ca-file "$TSA_CA_FILE" \
  --tsa-untrusted-file "$TSA_UNTRUSTED_FILE" \
  --output-dir "$OUTDIR" \
  "$INPUT"

echo "PASS: invalid JSON fails in jcs mode"
