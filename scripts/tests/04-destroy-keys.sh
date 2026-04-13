#!/usr/bin/env bash
# tests/04-destroy-keys.sh
set -euo pipefail
. "$(dirname "$0")/lib.sh"

WORKDIR="$(new_workdir 04-destroy-keys)"
OUTDIR="$WORKDIR/out"
INPUT="$FIXTURE_ROOT/sample.bin"

bash "$TEST_SCRIPT" \
  --mode raw \
  --trust-domain "$TEST_TRUST_DOMAIN" \
  --tsa-url "$TSA_URL" \
  --tsa-ca-file "$TSA_CA_FILE" \
  --tsa-untrusted-file "$TSA_UNTRUSTED_FILE" \
  --destroy-keys \
  --output-dir "$OUTDIR" \
  "$INPUT"

must_not_exist "$OUTDIR/private_key"
must_not_exist "$OUTDIR/private_key.pk8.pem"
must_exist "$OUTDIR/cert.pem"

echo "PASS: destroy keys"
