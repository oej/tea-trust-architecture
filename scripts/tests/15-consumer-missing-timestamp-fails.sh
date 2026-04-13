#!/usr/bin/env bash
# scripts/tests/15-consumer-missing-timestamp-fails.sh
set -euo pipefail
. "$(dirname "$0")/lib.sh"

WORKDIR="$(new_workdir 15-consumer-missing-timestamp)"
OUTDIR="$WORKDIR/out"
INPUT="$FIXTURE_ROOT/sample.bin"

bash "$TEST_SIGN_SCRIPT" \
  --mode raw \
  --trust-domain "$TEST_TRUST_DOMAIN" \
  --tsa-url "$TSA_URL" \
  --tsa-ca-file "$TSA_CA_FILE" \
  --tsa-untrusted-file "$TSA_UNTRUSTED_FILE" \
  --output-dir "$OUTDIR" \
  "$INPUT"

rm -f "$OUTDIR/sample.bin.sig.tsr"

must_fail bash "$TEST_CONSUMER_SCRIPT" \
  --mode raw \
  "$INPUT" \
  "$OUTDIR"

echo "PASS: consumer rejects missing timestamp"
