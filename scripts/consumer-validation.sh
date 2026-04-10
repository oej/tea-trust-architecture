#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

OPENSSL_BIN="${OPENSSL_BIN:-openssl}"
MAX_CERT_VALIDITY_HOURS="${MAX_CERT_VALIDITY_HOURS:-24}"

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "missing required command: $1"
}

check_cryptography_version() {
  python3 - <<'PY' || exit 1
import cryptography

def parse(v):
    parts = []
    for p in v.split("."):
        num = ""
        for ch in p:
            if ch.isdigit():
                num += ch
            else:
                break
        parts.append(int(num) if num else 0)
    while len(parts) < 3:
        parts.append(0)
    return tuple(parts[:3])

required = (41, 0, 0)
current = parse(cryptography.__version__)
if current < required:
    raise SystemExit(
        f"cryptography >= 41.0.0 required, found {cryptography.__version__}"
    )
PY
}

check_jcs_module_if_needed() {
  local mode="$1"
  if [ "$mode" = "jcs" ]; then
    python3 - <<'PY' || exit 1
import jcs
print("ok")
PY
  fi
}

warn_if_libressl() {
  if command -v "$OPENSSL_BIN" >/dev/null 2>&1; then
    local ver
    ver="$("$OPENSSL_BIN" version 2>/dev/null || true)"
    case "$ver" in
      *LibreSSL*)
        echo "WARNING: selected OpenSSL binary is LibreSSL: $ver" >&2
        echo "WARNING: it may not display Ed25519 X.509 certificates correctly." >&2
        echo "WARNING: use OpenSSL 3.x for manual inspection." >&2
        ;;
    esac
  fi
}

get_openssl_version_if_available() {
  if command -v "$OPENSSL_BIN" >/dev/null 2>&1; then
    "$OPENSSL_BIN" version 2>/dev/null || true
  fi
}

canonicalize_if_needed() {
  local mode="$1"
  local infile="$2"
  local outfile="$3"

  case "$mode" in
    raw)
      cp "$infile" "$outfile" || fail "failed to copy raw artefact for verification"
      ;;
    jcs)
      python3 - "$infile" "$outfile" <<'PY' || exit 1
import json
import sys
import jcs

infile = sys.argv[1]
outfile = sys.argv[2]

with open(infile, "rb") as f:
    data = json.load(f)

canonical = jcs.canonicalize(data)

with open(outfile, "wb") as f:
    f.write(canonical)
PY
      ;;
    *)
      fail "unknown mode: $mode"
      ;;
  esac
}

MODE=""
VERIFY_TIME=""
POSITIONAL=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    --mode)
      [ "$#" -ge 2 ] || fail "--mode requires a value"
      MODE="$2"
      shift 2
      ;;
    --verify-time)
      [ "$#" -ge 2 ] || fail "--verify-time requires a value"
      VERIFY_TIME="$2"
      shift 2
      ;;
    --help|-h)
      cat <<'EOF'
Usage:
  verify-tea-artefact.sh --mode raw|jcs [--verify-time RFC3339] <artefact-file> <output-dir>

Environment:
  OPENSSL_BIN=/path/to/openssl
  MAX_CERT_VALIDITY_HOURS=24

Arguments:
  artefact-file   Original artefact file
  output-dir      Output directory created by the signing script

Modes:
  raw  - verify exact artefact bytes
  jcs  - canonicalize JSON with RFC 8785 before verification

Examples:
  verify-tea-artefact.sh --mode jcs sbom.json tea-output
  verify-tea-artefact.sh --mode raw firmware.bin tea-output
  verify-tea-artefact.sh --mode jcs --verify-time 2026-03-30T12:00:00+00:00 sbom.json tea-output

macOS with Homebrew OpenSSL:
  OPENSSL_BIN=/opt/homebrew/bin/openssl \
  verify-tea-artefact.sh --mode jcs sbom.json tea-output
EOF
      exit 0
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done

[ "${#POSITIONAL[@]}" -eq 2 ] || fail "expected exactly two positional arguments: <artefact-file> <output-dir>"
[ -n "$MODE" ] || fail "--mode is required"

ARTEFACT_PATH="${POSITIONAL[0]}"
OUTDIR="${POSITIONAL[1]}"

[ -f "$ARTEFACT_PATH" ] || fail "artefact file not found: $ARTEFACT_PATH"
[ -d "$OUTDIR" ] || fail "output directory not found: $OUTDIR"

case "$MODE" in
  raw|jcs) ;;
  *) fail "mode must be 'raw' or 'jcs'" ;;
esac

case "$MAX_CERT_VALIDITY_HOURS" in
  ''|*[!0-9]*)
    fail "MAX_CERT_VALIDITY_HOURS must be a positive integer"
    ;;
esac

need_cmd python3
need_cmd shasum
need_cmd sigsum-verify
need_cmd "$OPENSSL_BIN"

check_cryptography_version
check_jcs_module_if_needed "$MODE" || fail "python package 'jcs' is not installed. Run: pip3 install jcs"
warn_if_libressl
OPENSSL_VERSION="$(get_openssl_version_if_available)"

CERT_PEM="$OUTDIR/cert.pem"
CERT_DER="$OUTDIR/cert.der"
SSH_PUB="$OUTDIR/public_key.pub"
DNS_ZONE_TXT="$OUTDIR/dns-cert-record.txt"
META_JSON="$OUTDIR/signing-metadata.json"
SIGSUM_POLICY_FILE="$OUTDIR/sigsum-policy.txt"

ARTEFACT_BASENAME="$(basename "$ARTEFACT_PATH")"
SIG_BIN="$OUTDIR/${ARTEFACT_BASENAME}.sig"
PREPARED_ARTEFACT="$OUTDIR/${ARTEFACT_BASENAME}.verify-input"
ARTEFACT_PROOF="$PREPARED_ARTEFACT.proof"
CERT_PROOF="$CERT_DER.proof"

[ -f "$CERT_PEM" ] || fail "missing certificate: $CERT_PEM"
[ -f "$CERT_DER" ] || fail "missing certificate DER: $CERT_DER"
[ -f "$SSH_PUB" ] || fail "missing OpenSSH public key: $SSH_PUB"
[ -f "$DNS_ZONE_TXT" ] || fail "missing DNS zone snippet: $DNS_ZONE_TXT"
[ -f "$META_JSON" ] || fail "missing metadata JSON: $META_JSON"
[ -f "$SIGSUM_POLICY_FILE" ] || fail "missing Sigsum policy file: $SIGSUM_POLICY_FILE"
[ -f "$SIG_BIN" ] || fail "missing detached signature: $SIG_BIN"
[ -f "$CERT_PROOF" ] || fail "missing certificate Sigsum proof: $CERT_PROOF"

echo "[1/10] Reconstruct artefact bytes to verify (mode: $MODE)..."
canonicalize_if_needed "$MODE" "$ARTEFACT_PATH" "$PREPARED_ARTEFACT"
[ -s "$PREPARED_ARTEFACT" ] || fail "failed to reconstruct verification input"

if [ ! -f "$ARTEFACT_PROOF" ]; then
  fail "missing artefact Sigsum proof: $ARTEFACT_PROOF"
fi

echo "[2/10] Recompute public key fingerprint and expected SAN identities..."

read -r EXPECTED_PUBKEY_FP <<EOF
$(python3 - "$SSH_PUB" <<'PY'
import sys, base64, hashlib

ssh_pub_path = sys.argv[1]
with open(ssh_pub_path, "r", encoding="utf-8") as f:
    parts = f.read().strip().split()

if len(parts) < 2:
    raise SystemExit("invalid OpenSSH public key format")

key_blob = base64.b64decode(parts[1])
fp = hashlib.sha256(key_blob).hexdigest().lower()
print(fp)
PY
)
EOF

read -r EXPECTED_MANUFACTURER_SAN EXPECTED_PERSISTENCE_SAN <<EOF
$(python3 - "$META_JSON" <<'PY'
import sys, json

with open(sys.argv[1], "r", encoding="utf-8") as f:
    meta = json.load(f)

manufacturer = meta.get("manufacturer_san_dns")
persistence = meta.get("persistence_san_dns") or ""

if not manufacturer:
    manufacturer = meta.get("dns_name", "")

if not manufacturer:
    raise SystemExit("metadata does not contain manufacturer_san_dns or dns_name")

print(manufacturer, persistence)
PY
)
EOF

[ -n "$EXPECTED_PUBKEY_FP" ] || fail "failed to compute public key fingerprint"
[ -n "$EXPECTED_MANUFACTURER_SAN" ] || fail "failed to read manufacturer SAN from metadata"

echo "      Public key fingerprint        : $EXPECTED_PUBKEY_FP"
echo "      Expected manufacturer SAN     : $EXPECTED_MANUFACTURER_SAN"
if [ -n "$EXPECTED_PERSISTENCE_SAN" ]; then
  echo "      Expected persistence SAN      : $EXPECTED_PERSISTENCE_SAN"
fi

echo "[3/10] Validate certificate profile, SAN binding, key identity, and validity policy..."

python3 - "$CERT_PEM" "$SSH_PUB" "$EXPECTED_PUBKEY_FP" "$EXPECTED_MANUFACTURER_SAN" "$EXPECTED_PERSISTENCE_SAN" "$VERIFY_TIME" "$MAX_CERT_VALIDITY_HOURS" <<'PY'
import sys, base64, hashlib
from datetime import datetime, timezone
from cryptography import x509
from cryptography.x509.oid import NameOID
from cryptography.hazmat.primitives import serialization

(
    cert_path,
    ssh_pub_path,
    expected_pubkey_fp,
    expected_manufacturer_san,
    expected_persistence_san,
    verify_time,
    max_validity_hours,
) = sys.argv[1:8]

with open(cert_path, "rb") as f:
    cert = x509.load_pem_x509_certificate(f.read())

with open(ssh_pub_path, "r", encoding="utf-8") as f:
    parts = f.read().strip().split()
if len(parts) < 2:
    raise SystemExit("invalid OpenSSH public key format")

key_blob = base64.b64decode(parts[1])
pubkey_fp = hashlib.sha256(key_blob).hexdigest().lower()
if pubkey_fp != expected_pubkey_fp:
    raise SystemExit("recomputed public key fingerprint mismatch")

san = cert.extensions.get_extension_for_class(x509.SubjectAlternativeName).value
dns_names = san.get_values_for_type(x509.DNSName)

if len(dns_names) < 1 or len(dns_names) > 2:
    raise SystemExit("certificate must contain one required manufacturer SAN and at most one optional persistence SAN")

expected = [expected_manufacturer_san]
if expected_persistence_san:
    expected.append(expected_persistence_san)

if dns_names != expected:
    raise SystemExit(f"SAN DNS mismatch: expected {expected}, got {dns_names}")

for dns_name in dns_names:
    prefix = f"{expected_pubkey_fp}."
    if not dns_name.startswith(prefix):
        raise SystemExit(f"SAN DNS name is not fingerprint-derived: {dns_name}")

for attr in cert.subject:
    if attr.oid == NameOID.COMMON_NAME:
        raise SystemExit("certificate subject MUST NOT contain CN")

ku = cert.extensions.get_extension_for_class(x509.KeyUsage).value
if not ku.digital_signature:
    raise SystemExit("certificate KeyUsage must include digitalSignature")

cert_pub_raw = cert.public_key().public_bytes(
    encoding=serialization.Encoding.Raw,
    format=serialization.PublicFormat.Raw
)

blob = key_blob

def read_u32(b, off):
    return int.from_bytes(b[off:off+4], "big"), off + 4

n1, o = read_u32(blob, 0)
alg = blob[o:o+n1]
o += n1
if alg != b"ssh-ed25519":
    raise SystemExit("OpenSSH public key is not ssh-ed25519")

n2, o = read_u32(blob, o)
raw_pub = blob[o:o+n2]
if len(raw_pub) != 32:
    raise SystemExit("unexpected Ed25519 public key length in OpenSSH blob")

if raw_pub != cert_pub_raw:
    raise SystemExit("certificate public key does not match OpenSSH public key")

not_before = getattr(cert, "not_valid_before_utc", cert.not_valid_before)
not_after = getattr(cert, "not_valid_after_utc", cert.not_valid_after)

def ensure_aware(dt):
    if dt.tzinfo is None:
        return dt.replace(tzinfo=timezone.utc)
    return dt

not_before = ensure_aware(not_before)
not_after = ensure_aware(not_after)

validity_seconds = (not_after - not_before).total_seconds()
max_seconds = int(max_validity_hours) * 3600
if validity_seconds > max_seconds:
    raise SystemExit(
        f"certificate validity duration exceeds policy: "
        f"{validity_seconds/3600:.2f}h > {int(max_validity_hours)}h"
    )

if verify_time:
    try:
        vt = datetime.fromisoformat(verify_time)
    except Exception as e:
        raise SystemExit(f"invalid --verify-time value: {e}")
    vt = ensure_aware(vt)
    if not (not_before <= vt <= not_after):
        raise SystemExit(
            f"verification time {vt.isoformat()} is outside certificate validity window "
            f"{not_before.isoformat()} .. {not_after.isoformat()}"
        )

print("ok")
PY

echo "[4/10] Verify packaged DNS publication snippet consistency..."

python3 - "$DNS_ZONE_TXT" "$EXPECTED_MANUFACTURER_SAN" "$EXPECTED_PERSISTENCE_SAN" <<'PY'
import sys

zone_path, manufacturer_san, persistence_san = sys.argv[1:4]
with open(zone_path, "r", encoding="utf-8") as f:
    text = f.read()

if f"{manufacturer_san}. IN CERT PKIX 0 0 (" not in text:
    raise SystemExit("DNS zone-file snippet does not contain expected manufacturer CERT owner name")

if persistence_san:
    if f"{persistence_san}. IN CERT PKIX 0 0 (" not in text:
        raise SystemExit("DNS zone-file snippet does not contain expected persistence CERT owner name")

print("ok")
PY

echo "[5/10] Verify detached artefact signature..."

python3 - "$CERT_PEM" "$PREPARED_ARTEFACT" "$SIG_BIN" <<'PY'
import sys
from cryptography import x509

cert_path, artefact_path, sig_path = sys.argv[1:4]

with open(cert_path, "rb") as f:
    cert = x509.load_pem_x509_certificate(f.read())

with open(artefact_path, "rb") as f:
    data = f.read()

with open(sig_path, "rb") as f:
    sig = f.read()

cert.public_key().verify(sig, data)
print("ok")
PY

echo "[6/10] Verify certificate Sigsum proof..."
sigsum-verify -p "$SIGSUM_POLICY_FILE" -k "$SSH_PUB" "$CERT_PROOF" < "$CERT_DER" \
  || fail "sigsum-verify failed for certificate"

echo "[7/10] Verify artefact Sigsum proof..."
sigsum-verify -p "$SIGSUM_POLICY_FILE" -k "$SSH_PUB" "$ARTEFACT_PROOF" < "$PREPARED_ARTEFACT" \
  || fail "sigsum-verify failed for artefact"

echo "[8/10] Cross-check metadata consistency..."

python3 - "$META_JSON" "$SSH_PUB" "$CERT_PEM" "$ARTEFACT_PATH" "$PREPARED_ARTEFACT" "$SIG_BIN" "$MODE" "$EXPECTED_MANUFACTURER_SAN" "$EXPECTED_PERSISTENCE_SAN" <<'PY'
import sys, json, hashlib, base64
from cryptography import x509
from cryptography.hazmat.primitives import hashes

(
    meta_path,
    ssh_pub_path,
    cert_path,
    artefact_path,
    prepared_path,
    sig_path,
    mode,
    expected_manufacturer_san,
    expected_persistence_san,
) = sys.argv[1:10]

with open(meta_path, "r", encoding="utf-8") as f:
    meta = json.load(f)

with open(ssh_pub_path, "r", encoding="utf-8") as f:
    ssh_pub_text = f.read().strip()

with open(cert_path, "rb") as f:
    cert = x509.load_pem_x509_certificate(f.read())

with open(artefact_path, "rb") as f:
    artefact = f.read()

with open(prepared_path, "rb") as f:
    prepared = f.read()

with open(sig_path, "rb") as f:
    sig = f.read()

pubkey_fp = hashlib.sha256(base64.b64decode(ssh_pub_text.split()[1])).hexdigest().lower()
cert_fp = cert.fingerprint(hashes.SHA256()).hex().lower()

if meta.get("signing_mode") != mode:
    raise SystemExit(f"metadata signing_mode mismatch: expected {mode}, got {meta.get('signing_mode')}")

if meta.get("public_key_fingerprint_sha256") != pubkey_fp:
    raise SystemExit("metadata public key fingerprint mismatch")

if meta.get("certificate_fingerprint_sha256") != cert_fp:
    raise SystemExit("metadata certificate fingerprint mismatch")

meta_manufacturer = meta.get("manufacturer_san_dns", meta.get("dns_name"))
meta_persistence = meta.get("persistence_san_dns") or ""

if meta_manufacturer != expected_manufacturer_san:
    raise SystemExit("metadata manufacturer SAN mismatch")

if meta_persistence != expected_persistence_san:
    raise SystemExit("metadata persistence SAN mismatch")

if meta.get("artefact_raw_sha256") != hashlib.sha256(artefact).hexdigest().lower():
    raise SystemExit("metadata raw artefact SHA-256 mismatch")

if meta.get("prepared_artefact_sha256") != hashlib.sha256(prepared).hexdigest().lower():
    raise SystemExit("metadata prepared artefact SHA-256 mismatch")

if meta.get("signature_sha256") != hashlib.sha256(sig).hexdigest().lower():
    raise SystemExit("metadata signature SHA-256 mismatch")

print("ok")
PY

echo "[9/10] Print verification summary..."

RAW_SHA256="$(shasum -a 256 "$ARTEFACT_PATH" | awk '{print $1}')"
PREP_SHA256="$(shasum -a 256 "$PREPARED_ARTEFACT" | awk '{print $1}')"
SIG_SHA256="$(shasum -a 256 "$SIG_BIN" | awk '{print $1}')"

echo "      Artefact file                  : $ARTEFACT_PATH"
echo "      Verification mode             : $MODE"
echo "      Raw artefact SHA-256          : $RAW_SHA256"
echo "      Prepared artefact SHA-256     : $PREP_SHA256"
echo "      Signature SHA-256             : $SIG_SHA256"
echo "      Manufacturer SAN              : $EXPECTED_MANUFACTURER_SAN"
if [ -n "$EXPECTED_PERSISTENCE_SAN" ]; then
  echo "      Persistence SAN               : $EXPECTED_PERSISTENCE_SAN"
fi
echo "      OpenSSL binary                : $OPENSSL_BIN"
echo "      OpenSSL version               : $OPENSSL_VERSION"
echo "      Max cert validity policy      : ${MAX_CERT_VALIDITY_HOURS}h"

if [ -n "$VERIFY_TIME" ]; then
  echo "      Verification time             : $VERIFY_TIME"
else
  echo "      Verification time             : not checked"
fi

echo "[10/10] Final result..."

echo
echo "SUCCESS"
echo "  Certificate profile valid"
echo "  SAN DNS matches fingerprint-derived identity"
echo "  Certificate public key matches OpenSSH public key"
echo "  Certificate validity duration satisfies policy"
echo "  Packaged DNS publication snippet is consistent"
echo "  Detached artefact signature is valid"
echo "  Certificate Sigsum proof is valid"
echo "  Artefact Sigsum proof is valid"
echo "  Metadata is consistent"
echo
echo "Trust conclusion:"
echo "  The signing key fingerprint is $EXPECTED_PUBKEY_FP"
echo "  The certificate wrapper is bound to the fingerprint-derived SAN identity"
echo "  The artefact signature is valid for the prepared artefact bytes"
echo "  Certificate and artefact are transparently logged in Sigsum"
echo
echo "Note:"
echo "  This script verifies a local TEA-native detached-signature bundle."
echo "  It does not yet perform live DNS resolution or TSA timestamp validation."
