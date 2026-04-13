#!/usr/bin/env bash
# tests/01-sign-raw-success.sh
set -euo pipefail
. "$(dirname "$0")/lib.sh"

WORKDIR="$(new_workdir 01-raw)"
OUTDIR="$WORKDIR/out"
INPUT="fixtures/sample.bin"

bash "$TEST_SCRIPT" \
  --mode raw \
  --trust-domain "$TEST_TRUST_DOMAIN" \
  --tsa-url "$TSA_URL" \
  --tsa-ca-file "$TSA_CA_FILE" \
  --tsa-untrusted-file "$TSA_UNTRUSTED_FILE" \
  --output-dir "$OUTDIR" \
  "$INPUT"

must_exist "$OUTDIR/cert.pem"
must_exist "$OUTDIR/cert.der"
must_exist "$OUTDIR/sample.bin.sig"
must_exist "$OUTDIR/sample.bin.sig.tsq"
must_exist "$OUTDIR/sample.bin.sig.tsr"
must_exist "$OUTDIR/signing-metadata.json"
must_exist "$OUTDIR/evidence-bundle.json"

must_contain "$OUTDIR/signing-metadata.json" '"trust_model": "tea-native"'
must_contain "$OUTDIR/evidence-bundle.json" '"format": "rfc3161"'

echo "PASS: raw signing success"
