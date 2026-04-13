#!/usr/bin/env bash
# scripts/tests/13-consumer-tampered-artefact-fails.sh
set -euo pipefail
. "$(dirname "$0")/lib.sh"

WORKDIR="$(new_workdir 13-consumer-tampered)"
OUTDIR="$WORKDIR/out"
INPUT="$WORKDIR/sample.bin"

cp "fixtures/sample.bin" "$INPUT"

bash "$TEST_SIGN_SCRIPT" \
  --mode raw \
  --trust-domain "$TEST_TRUST_DOMAIN" \
  --tsa-url "$TSA_URL" \
  --tsa-ca-file "$TSA_CA_FILE" \
  --tsa-untrusted-file "$TSA_UNTRUSTED_FILE" \
  --output-dir "$OUTDIR" \
  "$INPUT"

printf 'tampered\n' >> "$INPUT"

must_fail bash "$TEST_CONSUMER_SCRIPT" \
  --mode raw \
  "$INPUT" \
  "$OUTDIR"

echo "PASS: consumer rejects tampered artefact"
