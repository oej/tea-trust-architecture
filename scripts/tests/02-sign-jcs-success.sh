#!/usr/bin/env bash
# tests/02-sign-jcs-success.sh
set -euo pipefail
. "$(dirname "$0")/lib.sh"

WORKDIR="$(new_workdir 02-jcs)"
OUTDIR="$WORKDIR/out"
INPUT="fixtures/sample.json"

bash "$TEST_SCRIPT" \
  --mode jcs \
  --trust-domain "$TEST_TRUST_DOMAIN" \
  --tsa-url "$TSA_URL" \
  --tsa-ca-file "$TSA_CA_FILE" \
  --tsa-untrusted-file "$TSA_UNTRUSTED_FILE" \
  --output-dir "$OUTDIR" \
  "$INPUT"

must_exist "$OUTDIR/sample.json.to-be-signed"
must_exist "$OUTDIR/sample.json.sig"
must_exist "$OUTDIR/signing-metadata.json"

must_contain "$OUTDIR/signing-metadata.json" '"mode": "jcs"'
must_contain "$OUTDIR/signing-metadata.json" '"trust_model": "tea-native"'

echo "PASS: jcs signing success"
