#!/usr/bin/env bash
# scripts/tests/12-consumer-jcs-success.sh
set -euo pipefail
. "$(dirname "$0")/lib.sh"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"
WORKDIR="$(new_workdir 12-consumer-jcs)"
OUTDIR="$WORKDIR/out"
INPUT="$FIXTURE_ROOT/sample.json"

bash "$TEST_SIGN_SCRIPT" \
  --mode jcs \
  --trust-domain "$TEST_TRUST_DOMAIN" \
  --tsa-url "$TSA_URL" \
  --tsa-ca-file "$TSA_CA_FILE" \
  --tsa-untrusted-file "$TSA_UNTRUSTED_FILE" \
  --output-dir "$OUTDIR" \
  "$INPUT"

bash "$TEST_CONSUMER_SCRIPT" \
  --mode jcs \
  "$INPUT" \
  "$OUTDIR"

echo "PASS: consumer jcs validation"
