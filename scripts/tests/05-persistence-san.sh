#!/usr/bin/env bash
# tests/05-persistence-san.sh
set -euo pipefail
. "$(dirname "$0")/lib.sh"

WORKDIR="$(new_workdir 05-persistence-san)"
OUTDIR="$WORKDIR/out"
INPUT="$FIXTURE_ROOT/sample.bin"

bash "$TEST_SCRIPT" \
  --mode raw \
  --trust-domain "$TEST_TRUST_DOMAIN" \
  --persistence-trust-domain "$TEST_PERSISTENCE_DOMAIN" \
  --tsa-url "$TSA_URL" \
  --tsa-ca-file "$TSA_CA_FILE" \
  --tsa-untrusted-file "$TSA_UNTRUSTED_FILE" \
  --output-dir "$OUTDIR" \
  "$INPUT"

must_exist "$OUTDIR/dns-cert-record.txt"
must_contain "$OUTDIR/dns-cert-record.txt" ".$TEST_TRUST_DOMAIN."
must_contain "$OUTDIR/dns-cert-record.txt" ".$TEST_PERSISTENCE_DOMAIN."

echo "PASS: persistence SAN"
