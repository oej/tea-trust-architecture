#!/usr/bin/env bash
# scripts/tests/07-evidence-manifest-check.sh
set -euo pipefail
. "$(dirname "$0")/lib.sh"

WORKDIR="$(new_workdir 07-evidence-manifest)"
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

python3 - "$OUTDIR/evidence-bundle.json" <<'PY'
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as f:
    data = json.load(f)

assert data["trust_model"] == "tea-native"
assert data["signature"]["algorithm"] == "Ed25519"
assert data["timestamp"]["format"] == "rfc3161"
assert "certificate_proof_file" in data["transparency"]
assert "artefact_proof_file" in data["transparency"]
assert "zone_file" in data["dns_publication_candidates"]
assert "nsupdate_file" in data["dns_publication_candidates"]
PY

echo "PASS: evidence manifest check"
