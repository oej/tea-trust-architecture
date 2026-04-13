#!/usr/bin/env bash
# scripts/tests/14-consumer-metadata-mismatch-fails.sh
set -euo pipefail
. "$(dirname "$0")/lib.sh"

WORKDIR="$(new_workdir 14-consumer-metadata-mismatch)"
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

python3 - "$OUTDIR/signing-metadata.json" <<'PY'
import json, sys
p = sys.argv[1]
with open(p, "r", encoding="utf-8") as f:
    data = json.load(f)
data["manufacturer_san"] = "wrong.example.test"
with open(p, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, sort_keys=True)
PY

must_fail bash "$TEST_CONSUMER_SCRIPT" \
  --mode raw \
  "$INPUT" \
  "$OUTDIR"

echo "PASS: consumer rejects metadata mismatch"
