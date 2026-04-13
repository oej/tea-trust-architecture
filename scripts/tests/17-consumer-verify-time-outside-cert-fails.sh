#!/usr/bin/env bash
# scripts/tests/17-consumer-verify-time-outside-cert-fails.sh
set -euo pipefail
. "$(dirname "$0")/lib.sh"

WORKDIR="$(new_workdir 17-consumer-verify-time)"
OUTDIR="$WORKDIR/out"
INPUT="fixtures/sample.bin"

bash "$TEST_SIGN_SCRIPT" \
  --mode raw \
  --trust-domain "$TEST_TRUST_DOMAIN" \
  --tsa-url "$TSA_URL" \
  --tsa-ca-file "$TSA_CA_FILE" \
  --tsa-untrusted-file "$TSA_UNTRUSTED_FILE" \
  --output-dir "$OUTDIR" \
  "$INPUT"

must_fail bash "$TEST_CONSUMER_SCRIPT" \
  --mode raw \
  --verify-time 2035-01-01T00:00:00+00:00 \
  "$INPUT" \
  "$OUTDIR"

echo "PASS: consumer rejects verify-time outside cert validity"
