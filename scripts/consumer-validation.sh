#!/usr/bin/env bash
#
# consumer-validation.sh
#
# Technical demonstration script for the TEA Trust Architecture.
#
# Purpose
# -------
# This script demonstrates offline validation of a local TEA-native
# artefact bundle produced by the companion signing script.
#
# It is intended to help implementers and reviewers understand how to:
#
# - reconstruct the signed artefact bytes for raw or JCS mode
# - validate the detached Ed25519 signature
# - validate the signing certificate profile and SAN binding
# - recompute the TEA-native identity fingerprint from SPKI DER
# - verify RFC 3161 timestamp request/response files
# - verify Sigsum proofs for certificate and artefact
# - validate metadata consistency
# - validate the evidence-bundle manifest
# - validate packaged DNS publication candidates for consistency
#
# Important
# ---------
# This script is a technical demonstration and reference implementation aid.
# It is NOT production-ready software.
#
# In particular:
#
# - it validates a local bundle, not a live TEA service
# - it does not perform live DNS resolution
# - it does not retrieve discovery documents
# - it does not implement full consumer policy logic
# - it does not replace the normative TEA specifications
# - it should be reviewed, adapted, and hardened before any operational use
#
# Dependencies
# ------------
# The script expects the following tools to be installed and available:
#
# - bash
# - python3
# - shasum
# - sigsum-verify
# - an OpenSSL binary with support for:
#   - Ed25519
#   - X.509 certificate parsing
#   - RFC 3161 timestamp verification
#
# Python packages:
#
# - cryptography >= 41.0.0
# - jcs   (required when --mode jcs is used)
#
# Notes
# -----
# - This script validates packaged RFC 3161 timestamp files produced for the
#   detached signature.
# - DNS files are treated as publication candidates only.
# - This script validates local consistency, not authoritative DNS state.
#
# BSD 2-Clause License
# --------------------
#
# Copyright (c) 2026, the TEA contributors
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

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
        echo "WARNING: it may not display or verify all Ed25519 X.509 details consistently." >&2
        echo "WARNING: use OpenSSL 3.x where possible." >&2
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
      python3 - "$infile" "$outfile" <<'PY' || fail "invalid JSON input for JCS canonicalization: $infile"
import json
import sys
import jcs

infile = sys.argv[1]
outfile = sys.argv[2]

try:
    with open(infile, "rb") as f:
        data = json.load(f)
except json.JSONDecodeError as e:
    raise SystemExit(f"JSON parse error: {e}")

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
  consumer-validation.sh --mode raw|jcs [--verify-time RFC3339] <artefact-file> <output-dir>

Environment:
  OPENSSL_BIN=/path/to/openssl
  MAX_CERT_VALIDITY_HOURS=24
  TSA_CA_FILE=/path/to/cacert.pem
  TSA_UNTRUSTED_FILE=/path/to/tsa.crt

Arguments:
  artefact-file   Original artefact file
  output-dir      Output directory created by sign-objects.sh

Modes:
  raw  - verify exact artefact bytes
  jcs  - canonicalize JSON with RFC 8785 before verification

Examples:
  consumer-validation.sh --mode jcs sbom.json tea-output
  consumer-validation.sh --mode raw firmware.bin tea-output
  consumer-validation.sh --mode jcs --verify-time 2026-03-30T12:00:00+00:00 sbom.json tea-output

macOS with Homebrew OpenSSL:
  OPENSSL_BIN=/opt/homebrew/opt/openssl@3/bin/openssl \
  consumer-validation.sh --mode jcs sbom.json tea-output
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
EVIDENCE_JSON="$OUTDIR/evidence-bundle.json"

ARTEFACT_BASENAME="$(basename "$ARTEFACT_PATH")"
SIG_BIN="$OUTDIR/${ARTEFACT_BASENAME}.sig"
SIG_B64="$OUTDIR/${ARTEFACT_BASENAME}.sig.b64"
PREPARED_ARTEFACT="$OUTDIR/${ARTEFACT_BASENAME}.verify-input"
ARTEFACT_PROOF="$OUTDIR/${ARTEFACT_BASENAME}.to-be-signed.proof"
CERT_PROOF="$CERT_DER.proof"
TSQ_FILE="$OUTDIR/${ARTEFACT_BASENAME}.sig.tsq"
TSR_FILE="$OUTDIR/${ARTEFACT_BASENAME}.sig.tsr"

[ -f "$CERT_PEM" ] || fail "missing certificate: $CERT_PEM"
[ -f "$CERT_DER" ] || fail "missing certificate DER: $CERT_DER"
[ -f "$SSH_PUB" ] || fail "missing OpenSSH public key: $SSH_PUB"
[ -f "$DNS_ZONE_TXT" ] || fail "missing DNS zone snippet: $DNS_ZONE_TXT"
[ -f "$META_JSON" ] || fail "missing metadata JSON: $META_JSON"
[ -f "$SIGSUM_POLICY_FILE" ] || fail "missing Sigsum policy file: $SIGSUM_POLICY_FILE"
[ -f "$SIG_BIN" ] || fail "missing detached signature: $SIG_BIN"
[ -f "$SIG_B64" ] || fail "missing base64 signature: $SIG_B64"
[ -f "$CERT_PROOF" ] || fail "missing certificate Sigsum proof: $CERT_PROOF"
[ -f "$ARTEFACT_PROOF" ] || fail "missing artefact Sigsum proof: $ARTEFACT_PROOF"
[ -f "$TSQ_FILE" ] || fail "missing timestamp request: $TSQ_FILE"
[ -f "$TSR_FILE" ] || fail "missing timestamp response: $TSR_FILE"
[ -f "$EVIDENCE_JSON" ] || fail "missing evidence bundle manifest: $EVIDENCE_JSON"

echo "[1/12] Reconstruct artefact bytes to verify (mode: $MODE)..."
canonicalize_if_needed "$MODE" "$ARTEFACT_PATH" "$PREPARED_ARTEFACT"
[ -s "$PREPARED_ARTEFACT" ] || fail "failed to reconstruct verification input"

echo "[2/12] Recompute public key fingerprint and expected SAN identities..."

read -r EXPECTED_PUBKEY_FP <<EOF
$(python3 - "$SSH_PUB" <<'PY'
import hashlib
import sys
from cryptography.hazmat.primitives import serialization

ssh_pub_path = sys.argv[1]
with open(ssh_pub_path, "rb") as f:
    ssh_pub = f.read()

pub = serialization.load_ssh_public_key(ssh_pub)
spki_der = pub.public_bytes(
    encoding=serialization.Encoding.DER,
    format=serialization.PublicFormat.SubjectPublicKeyInfo,
)
fp = hashlib.sha256(spki_der).hexdigest().lower()
print(fp)
PY
)
EOF

IFS='|' read -r EXPECTED_MANUFACTURER_SAN EXPECTED_PERSISTENCE_SAN EXPECTED_MODE <<EOF
$(python3 - "$META_JSON" <<'PY'
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as f:
    meta = json.load(f)

manufacturer = meta.get("manufacturer_san") or ""
persistence = meta.get("persistence_san") or ""
mode = meta.get("mode") or ""

if not manufacturer:
    raise SystemExit("metadata does not contain manufacturer_san")
if not mode:
    raise SystemExit("metadata does not contain mode")

if "|" in manufacturer or "|" in persistence or "|" in mode:
    raise SystemExit("metadata contains unexpected '|' delimiter character")

print(f"{manufacturer}|{persistence}|{mode}")
PY
)
EOF

[ -n "$EXPECTED_PUBKEY_FP" ] || fail "failed to compute public key fingerprint"
[ -n "$EXPECTED_MANUFACTURER_SAN" ] || fail "failed to read manufacturer SAN from metadata"
[ -n "$EXPECTED_MODE" ] || fail "failed to read mode from metadata"

if [ "$EXPECTED_MODE" != "$MODE" ]; then
  fail "metadata mode mismatch: metadata=$EXPECTED_MODE, requested=$MODE"
fi

echo "      Public key fingerprint        : $EXPECTED_PUBKEY_FP"
echo "      Expected manufacturer SAN     : $EXPECTED_MANUFACTURER_SAN"
if [ -n "$EXPECTED_PERSISTENCE_SAN" ]; then
  echo "      Expected persistence SAN      : $EXPECTED_PERSISTENCE_SAN"
fi

echo "[3/12] Validate certificate profile, SAN binding, key identity, and validity policy..."

python3 - "$CERT_PEM" "$SSH_PUB" "$EXPECTED_PUBKEY_FP" "$EXPECTED_MANUFACTURER_SAN" "$EXPECTED_PERSISTENCE_SAN" "$VERIFY_TIME" "$MAX_CERT_VALIDITY_HOURS" <<'PY'
import sys
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

with open(ssh_pub_path, "rb") as f:
    ssh_pub = f.read()

pub = serialization.load_ssh_public_key(ssh_pub)
spki_der = pub.public_bytes(
    encoding=serialization.Encoding.DER,
    format=serialization.PublicFormat.SubjectPublicKeyInfo,
)

import hashlib
pubkey_fp = hashlib.sha256(spki_der).hexdigest().lower()
if pubkey_fp != expected_pubkey_fp:
    raise SystemExit("recomputed public key fingerprint mismatch")

san = cert.extensions.get_extension_for_class(x509.SubjectAlternativeName).value
dns_names = list(san.get_values_for_type(x509.DNSName))

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

cert_spki_der = cert.public_key().public_bytes(
    encoding=serialization.Encoding.DER,
    format=serialization.PublicFormat.SubjectPublicKeyInfo,
)

if cert_spki_der != spki_der:
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

echo "[4/12] Verify packaged DNS publication snippet consistency..."

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

echo "[5/12] Verify detached artefact signature..."

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

echo "[6/12] Verify RFC 3161 timestamp over detached signature..."

VERIFY_ARGS=(ts -verify -in "$TSR_FILE" -queryfile "$TSQ_FILE")
if [ -n "${TSA_CA_FILE:-}" ]; then
  VERIFY_ARGS+=(-CAfile "$TSA_CA_FILE")
fi
if [ -n "${TSA_UNTRUSTED_FILE:-}" ]; then
  VERIFY_ARGS+=(-untrusted "$TSA_UNTRUSTED_FILE")
fi
"$OPENSSL_BIN" "${VERIFY_ARGS[@]}" >/dev/null \
  || fail "OpenSSL timestamp verification failed"

echo "[7/12] Verify certificate Sigsum proof..."
sigsum-verify -p "$SIGSUM_POLICY_FILE" -k "$SSH_PUB" "$CERT_PROOF" < "$CERT_DER" \
  || fail "sigsum-verify failed for certificate"

echo "[8/12] Verify artefact Sigsum proof..."
sigsum-verify -p "$SIGSUM_POLICY_FILE" -k "$SSH_PUB" "$ARTEFACT_PROOF" < "$PREPARED_ARTEFACT" \
  || fail "sigsum-verify failed for artefact"

echo "[9/12] Cross-check metadata consistency..."

python3 - "$META_JSON" "$SSH_PUB" "$CERT_PEM" "$ARTEFACT_PATH" "$PREPARED_ARTEFACT" "$SIG_BIN" "$MODE" "$EXPECTED_MANUFACTURER_SAN" "$EXPECTED_PERSISTENCE_SAN" <<'PY'
import sys, json, hashlib
from cryptography import x509
from cryptography.hazmat.primitives import serialization, hashes

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

with open(ssh_pub_path, "rb") as f:
    ssh_pub = f.read()

pub = serialization.load_ssh_public_key(ssh_pub)
spki_der = pub.public_bytes(
    encoding=serialization.Encoding.DER,
    format=serialization.PublicFormat.SubjectPublicKeyInfo,
)
pubkey_fp = hashlib.sha256(spki_der).hexdigest().lower()

with open(cert_path, "rb") as f:
    cert = x509.load_pem_x509_certificate(f.read())

with open(sig_path, "rb") as f:
    sig = f.read()

cert_fp = cert.fingerprint(hashes.SHA256()).hex().lower()

if meta.get("mode") != mode:
    raise SystemExit(f"metadata mode mismatch: expected {mode}, got {meta.get('mode')}")

if meta.get("public_key_fingerprint_sha256") != pubkey_fp:
    raise SystemExit("metadata public key fingerprint mismatch")

if meta.get("certificate_fingerprint_sha256") != cert_fp:
    raise SystemExit("metadata certificate fingerprint mismatch")

if meta.get("manufacturer_san") != expected_manufacturer_san:
    raise SystemExit("metadata manufacturer SAN mismatch")

if (meta.get("persistence_san") or "") != expected_persistence_san:
    raise SystemExit("metadata persistence SAN mismatch")

print("ok")
PY

echo "[10/12] Validate evidence-bundle manifest..."

python3 - "$EVIDENCE_JSON" "$META_JSON" "$CERT_PEM" "$CERT_DER" "$SIG_BIN" "$SIG_B64" "$TSQ_FILE" "$TSR_FILE" "$CERT_PROOF" "$ARTEFACT_PROOF" "$DNS_ZONE_TXT" <<'PY'
import json
import sys

(
    evidence_path,
    meta_path,
    cert_pem,
    cert_der,
    sig_bin,
    sig_b64,
    tsq_file,
    tsr_file,
    cert_proof,
    artefact_proof,
    dns_zone,
) = sys.argv[1:12]

with open(evidence_path, "r", encoding="utf-8") as f:
    evidence = json.load(f)

with open(meta_path, "r", encoding="utf-8") as f:
    meta = json.load(f)

if evidence.get("trust_model") != "tea-native":
    raise SystemExit("evidence bundle trust_model must be tea-native")

sig = evidence.get("signature", {})
if sig.get("algorithm") != "Ed25519":
    raise SystemExit("evidence bundle signature.algorithm must be Ed25519")
if sig.get("value_file") != sig_bin:
    raise SystemExit("evidence bundle signature.value_file mismatch")
if sig.get("value_base64_file") != sig_b64:
    raise SystemExit("evidence bundle signature.value_base64_file mismatch")

cert = evidence.get("certificate", {})
if cert.get("pem_file") != cert_pem:
    raise SystemExit("evidence bundle certificate.pem_file mismatch")
if cert.get("der_file") != cert_der:
    raise SystemExit("evidence bundle certificate.der_file mismatch")
if cert.get("fingerprint_sha256") != meta.get("certificate_fingerprint_sha256"):
    raise SystemExit("evidence bundle certificate fingerprint mismatch")

ts = evidence.get("timestamp", {})
if ts.get("format") != "rfc3161":
    raise SystemExit("evidence bundle timestamp.format must be rfc3161")
if ts.get("request_file") != tsq_file:
    raise SystemExit("evidence bundle timestamp.request_file mismatch")
if ts.get("token_file") != tsr_file:
    raise SystemExit("evidence bundle timestamp.token_file mismatch")

tr = evidence.get("transparency", {})
if tr.get("certificate_proof_file") != cert_proof:
    raise SystemExit("evidence bundle transparency.certificate_proof_file mismatch")
if tr.get("artefact_proof_file") != artefact_proof:
    raise SystemExit("evidence bundle transparency.artefact_proof_file mismatch")

dns = evidence.get("dns_publication_candidates", {})
if dns.get("zone_file") != dns_zone:
    raise SystemExit("evidence bundle dns_publication_candidates.zone_file mismatch")

print("ok")
PY

echo "[11/12] Print verification summary..."

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

echo "[12/12] Final result..."

echo
echo "SUCCESS"
echo "  Certificate profile valid"
echo "  SAN DNS matches fingerprint-derived identity"
echo "  Certificate public key matches OpenSSH public key"
echo "  Certificate validity duration satisfies policy"
echo "  Packaged DNS publication snippet is consistent"
echo "  Detached artefact signature is valid"
echo "  RFC 3161 timestamp bundle is valid"
echo "  Certificate Sigsum proof is valid"
echo "  Artefact Sigsum proof is valid"
echo "  Metadata is consistent"
echo "  Evidence bundle manifest is consistent"
echo
echo "Trust conclusion:"
echo "  The signing key fingerprint is $EXPECTED_PUBKEY_FP"
echo "  The certificate wrapper is bound to the fingerprint-derived SAN identity"
echo "  The artefact signature is valid for the prepared artefact bytes"
echo "  The detached signature has a verifiable RFC 3161 timestamp"
echo "  Certificate and artefact are transparently logged in Sigsum"
echo
echo "Note:"
echo "  This script verifies a local TEA-native detached-signature bundle."
echo "  It does not perform live DNS resolution, discovery retrieval, or live TEA API validation."
