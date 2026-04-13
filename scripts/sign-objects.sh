#!/usr/bin/env bash
#
# sign-objects.sh
#
# Technical demonstration script for the TEA Trust Architecture.
#
# Purpose
# -------
# This script demonstrates a TEA-native signing flow for a single object.
# It is intended to help implementers and reviewers understand how to:
#
# - generate an ephemeral Ed25519 signing key
# - derive fingerprint-based SAN DNS names
# - create a short-lived self-signed X.509 certificate
# - sign an object with a detached signature
# - obtain and verify an RFC 3161 timestamp over the signature
# - submit the certificate and object to Sigsum
# - produce DNS CERT publication candidates
# - emit signing metadata and an evidence-bundle manifest
#
# Important
# ---------
# This script is a technical demonstration and reference implementation aid.
# It is NOT production-ready software.
#
# In particular:
#
# - it does not implement a full publisher workflow
# - it does not perform gated commit or approval handling
# - it does not publish to DNS or TEA services directly
# - it does not replace the normative TEA specifications
# - it should be reviewed, adapted, and hardened before any operational use
#
# Dependencies
# ------------
# The script expects the following tools to be installed and available:
#
# - bash
# - python3
# - ssh-keygen
# - shasum
# - curl
# - sigsum-submit
# - sigsum-verify
# - sigsum-policy
# - an OpenSSL binary with support for:
#   - Ed25519
#   - X.509 certificate generation
#   - RFC 3161 timestamp requests and verification
#
# Python packages:
#
# - cryptography >= 41.0.0
# - jcs   (required when --mode jcs is used)
#
# Notes
# -----
# - The script uses RFC 3161 timestamping over the detached signature.
# - DNS output files are publication candidates only.
# - Authoritative publication must occur only through a controlled commit workflow.
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

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "missing required command: $1"
}

# Minimal internal compatibility shim for RFC 3161 HTTP submission.
# Usage:
#   tsget -h <tsa-url> -o <output-file> <request.tsq>
tsget() {
  local url=""
  local outfile=""

  while [ "$#" -gt 0 ]; do
    case "$1" in
      -h)
        [ "$#" -ge 2 ] || fail "tsget: missing value for -h"
        url="$2"
        shift 2
        ;;
      -o)
        [ "$#" -ge 2 ] || fail "tsget: missing value for -o"
        outfile="$2"
        shift 2
        ;;
      *)
        break
        ;;
    esac
  done

  local req_file="${1:-}"

  [ -n "$url" ] || fail "tsget: missing -h <tsa-url>"
  [ -n "$outfile" ] || fail "tsget: missing -o <output-file>"
  [ -n "$req_file" ] || fail "tsget: missing request file"
  [ -f "$req_file" ] || fail "tsget: request file not found: $req_file"

  need_cmd curl

  curl -sS --fail --location \
    -H "Content-Type: application/timestamp-query" \
    --data-binary @"$req_file" \
    "$url" > "$outfile" \
    || fail "tsget: HTTP request to TSA failed"

  [ -s "$outfile" ] || fail "tsget: empty timestamp response"
}

check_cryptography_version() {
  python3 - <<'PY' || exit 1
import cryptography

def parse(v: str):
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
        echo "WARNING: it may not handle all Ed25519 X.509 operations correctly." >&2
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

b64_file_single_line() {
  python3 - "$1" <<'PY'
import sys, base64
with open(sys.argv[1], "rb") as f:
    print(base64.b64encode(f.read()).decode("ascii"), end="")
PY
}

canonicalize_if_needed() {
  local mode="$1"
  local infile="$2"
  local outfile="$3"

  case "$mode" in
    raw)
      cp "$infile" "$outfile" || fail "failed to copy raw artefact for signing"
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

MODE="raw"
TRUST_DOMAIN=""
PERSISTENCE_TRUST_DOMAIN=""
OUTDIR="tea-output"
SIGSUM_POLICY_NAME="${SIGSUM_POLICY_NAME:-sigsum-test1-2025}"
SUBJECT_O="Example Publisher"
SUBJECT_OU="TEA Signing"
SUBJECT_C="SE"
VALIDITY_HOURS="1"
OPENSSL_BIN="${OPENSSL_BIN:-openssl}"
TSA_URL="${TSA_URL:-}"
TSA_CA_FILE="${TSA_CA_FILE:-}"
TSA_UNTRUSTED_FILE="${TSA_UNTRUSTED_FILE:-}"
DESTROY_KEYS="${DESTROY_KEYS:-0}"

POSITIONAL=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    --mode)
      [ "$#" -ge 2 ] || fail "--mode requires a value"
      MODE="$2"
      shift 2
      ;;
    --trust-domain)
      [ "$#" -ge 2 ] || fail "--trust-domain requires a value"
      TRUST_DOMAIN="$2"
      shift 2
      ;;
    --persistence-trust-domain)
      [ "$#" -ge 2 ] || fail "--persistence-trust-domain requires a value"
      PERSISTENCE_TRUST_DOMAIN="$2"
      shift 2
      ;;
    --subject-o)
      [ "$#" -ge 2 ] || fail "--subject-o requires a value"
      SUBJECT_O="$2"
      shift 2
      ;;
    --subject-ou)
      [ "$#" -ge 2 ] || fail "--subject-ou requires a value"
      SUBJECT_OU="$2"
      shift 2
      ;;
    --subject-c)
      [ "$#" -ge 2 ] || fail "--subject-c requires a value"
      SUBJECT_C="$2"
      shift 2
      ;;
    --validity-hours)
      [ "$#" -ge 2 ] || fail "--validity-hours requires a value"
      VALIDITY_HOURS="$2"
      shift 2
      ;;
    --output-dir)
      [ "$#" -ge 2 ] || fail "--output-dir requires a value"
      OUTDIR="$2"
      shift 2
      ;;
    --sigsum-policy-name)
      [ "$#" -ge 2 ] || fail "--sigsum-policy-name requires a value"
      SIGSUM_POLICY_NAME="$2"
      shift 2
      ;;
    --tsa-url)
      [ "$#" -ge 2 ] || fail "--tsa-url requires a value"
      TSA_URL="$2"
      shift 2
      ;;
    --tsa-ca-file)
      [ "$#" -ge 2 ] || fail "--tsa-ca-file requires a value"
      TSA_CA_FILE="$2"
      shift 2
      ;;
    --tsa-untrusted-file)
      [ "$#" -ge 2 ] || fail "--tsa-untrusted-file requires a value"
      TSA_UNTRUSTED_FILE="$2"
      shift 2
      ;;
    --destroy-keys)
      DESTROY_KEYS="1"
      shift
      ;;
    --help|-h)
      cat <<'EOF'
Usage:
  sign-objects.sh --trust-domain DOMAIN [options] ARTEFACT

Options:
  --mode raw|jcs                 Sign exact artefact bytes or JCS-canonicalized JSON
  --trust-domain DOMAIN          Required manufacturer trust domain
  --persistence-trust-domain D   Optional persistence trust domain
  --subject-o ORG                Subject O field
  --subject-ou UNIT              Subject OU field
  --subject-c COUNTRY            Subject C field
  --validity-hours HOURS         Certificate validity in hours (default: 1)
  --output-dir DIR               Output directory (default: tea-output)
  --sigsum-policy-name NAME      Sigsum policy name
  --tsa-url URL                  RFC 3161 TSA URL (required for timestamping)
  --tsa-ca-file FILE             Optional CA file for TSA verification
  --tsa-untrusted-file FILE      Optional intermediate certs for TSA verification
  --destroy-keys                 Destroy private keys after successful run

Environment:
  OPENSSL_BIN=/path/to/openssl

Modes:
  raw  - sign exact artefact bytes
  jcs  - canonicalize JSON with RFC 8785 before signing

Description:
  The manufacturer SAN DNS name is derived automatically as:
    <sha256(public-key)>.<trust-domain>

  The optional persistence SAN DNS name is derived automatically as:
    <sha256(public-key)>.<persistence-trust-domain>

  The artefact signature is emitted as a detached Ed25519 signature.
  DNS output files are publication candidates only. Authoritative publication
  must happen in a controlled commit workflow.

Examples:
  sign-objects.sh --mode jcs \
    --trust-domain teatrust.acme.example.com \
    --tsa-url https://tsa.example.org/tsa \
    sbom.json

  sign-objects.sh --mode raw \
    --trust-domain teatrust.acme.example.com \
    --persistence-trust-domain teatrust.archive.example.net \
    --tsa-url https://tsa.example.org/tsa \
    firmware.bin
EOF
      exit 0
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done

[ "${#POSITIONAL[@]}" -eq 1 ] || fail "exactly one artefact file must be provided"
[ -n "$TRUST_DOMAIN" ] || fail "--trust-domain is required"
[ -n "$TSA_URL" ] || fail "--tsa-url is required"

ARTEFACT_PATH="${POSITIONAL[0]}"
[ -f "$ARTEFACT_PATH" ] || fail "artefact file not found: $ARTEFACT_PATH"

case "$MODE" in
  raw|jcs) ;;
  *) fail "mode must be 'raw' or 'jcs'" ;;
esac

case "$VALIDITY_HOURS" in
  ''|*[!0-9]*)
    fail "--validity-hours must be a positive integer"
    ;;
esac

need_cmd ssh-keygen
need_cmd python3
need_cmd shasum
need_cmd sigsum-submit
need_cmd sigsum-verify
need_cmd sigsum-policy
need_cmd cmp
need_cmd mv

check_cryptography_version
check_jcs_module_if_needed "$MODE" || fail "python package 'jcs' is not installed. Run: pip3 install jcs"
warn_if_libressl

OPENSSL_VERSION="$(get_openssl_version_if_available)"

mkdir -p "$OUTDIR"

ARTEFACT_BASENAME="$(basename "$ARTEFACT_PATH")"
SSH_KEY="$OUTDIR/private_key"
SSH_PUB="$OUTDIR/public_key.pub"
OPENSSL_KEY_PEM="$OUTDIR/private_key.pk8.pem"
CERT_PEM="$OUTDIR/cert.pem"
CERT_DER="$OUTDIR/cert.der"
PREPARED_ARTEFACT="$OUTDIR/${ARTEFACT_BASENAME}.to-be-signed"
SIG_BIN="$OUTDIR/${ARTEFACT_BASENAME}.sig"
SIG_B64="$OUTDIR/${ARTEFACT_BASENAME}.sig.b64"
TSQ_FILE="$OUTDIR/${ARTEFACT_BASENAME}.sig.tsq"
TSR_FILE="$OUTDIR/${ARTEFACT_BASENAME}.sig.tsr"
CERT_PROOF="$CERT_DER.proof"
ARTEFACT_PROOF="$PREPARED_ARTEFACT.proof"
DNS_ZONE_TXT="$OUTDIR/dns-cert-record.txt"
NSUPDATE_TXT="$OUTDIR/nsupdate-cert.txt"
META_JSON="$OUTDIR/signing-metadata.json"
SIGSUM_POLICY_FILE="$OUTDIR/sigsum-policy.txt"
EVIDENCE_JSON="$OUTDIR/evidence-bundle.json"
CERT_CONFIG="$OUTDIR/cert.cnf"

for path in \
  "$SSH_KEY" "$SSH_PUB" "$OPENSSL_KEY_PEM" "$CERT_PEM" "$CERT_DER" \
  "$PREPARED_ARTEFACT" "$SIG_BIN" "$SIG_B64" "$TSQ_FILE" "$TSR_FILE" \
  "$CERT_PROOF" "$ARTEFACT_PROOF" "$DNS_ZONE_TXT" "$NSUPDATE_TXT" \
  "$META_JSON" "$SIGSUM_POLICY_FILE" "$EVIDENCE_JSON" "$CERT_CONFIG"
do
  [ ! -e "$path" ] || fail "output file already exists: $path"
done

echo "[1/15] Generate Ed25519 key in OpenSSH format..."
ssh-keygen -q -t ed25519 -N "" -f "$SSH_KEY" -C "TEA publisher signing key" \
  || fail "ssh-keygen failed"
[ -s "$SSH_KEY" ] || fail "OpenSSH private key not created"
[ -s "${SSH_KEY}.pub" ] || fail "OpenSSH public key not created"
mv "${SSH_KEY}.pub" "$SSH_PUB" || fail "failed to rename public key to $SSH_PUB"
[ -s "$SSH_PUB" ] || fail "renamed OpenSSH public key not found"

echo "[2/15] Derive public key fingerprint and SAN DNS names..."
read -r FINGERPRINT MANUFACTURER_SAN PERSISTENCE_SAN < <(
  python3 - "$SSH_PUB" "$TRUST_DOMAIN" "$PERSISTENCE_TRUST_DOMAIN" <<'PY'
import hashlib
import sys
from cryptography.hazmat.primitives import serialization

pub_path, trust_domain, persistence_domain = sys.argv[1:4]

with open(pub_path, "rb") as f:
    ssh_pub = f.read()

pub = serialization.load_ssh_public_key(ssh_pub)

spki_der = pub.public_bytes(
    encoding=serialization.Encoding.DER,
    format=serialization.PublicFormat.SubjectPublicKeyInfo,
)

fp = hashlib.sha256(spki_der).hexdigest().lower()
manufacturer = f"{fp}.{trust_domain}"
persistence = f"{fp}.{persistence_domain}" if persistence_domain else ""

print(fp, manufacturer, persistence)
PY
) || fail "failed to derive fingerprint and SANs"

[ -n "$FINGERPRINT" ] || fail "failed to derive fingerprint"
[ -n "$MANUFACTURER_SAN" ] || fail "failed to derive manufacturer SAN"

echo " Fingerprint      : $FINGERPRINT"
echo " Manufacturer SAN : $MANUFACTURER_SAN"
if [ -n "$PERSISTENCE_SAN" ]; then
  echo " Persistence SAN  : $PERSISTENCE_SAN"
fi

echo "[3/15] Convert OpenSSH private key to PKCS#8 PEM..."
python3 - "$SSH_KEY" "$OPENSSL_KEY_PEM" <<'PY'
import sys
from cryptography.hazmat.primitives import serialization

src, dst = sys.argv[1:3]
with open(src, "rb") as f:
    key = serialization.load_ssh_private_key(f.read(), password=None)

pem = key.private_bytes(
    encoding=serialization.Encoding.PEM,
    format=serialization.PrivateFormat.PKCS8,
    encryption_algorithm=serialization.NoEncryption(),
)

with open(dst, "wb") as f:
    f.write(pem)
PY
[ -s "$OPENSSL_KEY_PEM" ] || fail "PKCS#8 PEM private key not created"

echo "[4/15] Create self-signed X.509 certificate..."
cat > "$CERT_CONFIG" <<EOF
[ req ]
distinguished_name = dn
prompt = no
x509_extensions = v3_req

[ dn ]
O = ${SUBJECT_O}
EOF

if [ -n "$SUBJECT_OU" ]; then
  echo "OU = ${SUBJECT_OU}" >> "$CERT_CONFIG"
fi

if [ -n "$SUBJECT_C" ]; then
  echo "C = ${SUBJECT_C}" >> "$CERT_CONFIG"
fi

cat >> "$CERT_CONFIG" <<EOF

[ v3_req ]
basicConstraints = critical, CA:FALSE
keyUsage = critical, digitalSignature
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = ${MANUFACTURER_SAN}
EOF

if [ -n "$PERSISTENCE_SAN" ]; then
  echo "DNS.2 = ${PERSISTENCE_SAN}" >> "$CERT_CONFIG"
fi

"$OPENSSL_BIN" req -new -x509 \
  -key "$OPENSSL_KEY_PEM" \
  -out "$CERT_PEM" \
  -outform PEM \
  -days 1 \
  -config "$CERT_CONFIG" \
  || fail "failed to create self-signed certificate"

[ -s "$CERT_PEM" ] || fail "PEM certificate not created"

"$OPENSSL_BIN" x509 -in "$CERT_PEM" -outform DER -out "$CERT_DER" \
  || fail "failed to convert certificate to DER"
[ -s "$CERT_DER" ] || fail "DER certificate not created"

read -r CERT_FINGERPRINT CERT_NOT_BEFORE CERT_NOT_AFTER < <(
  python3 - "$CERT_PEM" "$MANUFACTURER_SAN" "$PERSISTENCE_SAN" <<'PY'
import sys
from cryptography import x509
from cryptography.hazmat.primitives import hashes
from cryptography.x509.oid import NameOID

cert_path, manufacturer_san, persistence_san = sys.argv[1:4]

with open(cert_path, "rb") as f:
    cert = x509.load_pem_x509_certificate(f.read())

sans = cert.extensions.get_extension_for_class(x509.SubjectAlternativeName).value
dns_names = list(sans.get_values_for_type(x509.DNSName))
expected = [manufacturer_san]
if persistence_san:
    expected.append(persistence_san)

if dns_names != expected:
    raise SystemExit(f"certificate SAN mismatch: expected {expected}, got {dns_names}")

for attr in cert.subject:
    if attr.oid == NameOID.COMMON_NAME:
        raise SystemExit("certificate subject MUST NOT contain CN")

ku = cert.extensions.get_extension_for_class(x509.KeyUsage).value
if not ku.digital_signature:
    raise SystemExit("certificate KeyUsage must include digitalSignature")

not_before = getattr(cert, "not_valid_before_utc", cert.not_valid_before)
not_after = getattr(cert, "not_valid_after_utc", cert.not_valid_after)
fp = cert.fingerprint(hashes.SHA256()).hex().lower()
print(fp, not_before.isoformat(), not_after.isoformat())
PY
) || fail "certificate profile validation failed"

[ -n "$CERT_FINGERPRINT" ] || fail "failed to compute certificate fingerprint"
echo " Certificate fingerprint (SHA-256): $CERT_FINGERPRINT"
echo " Valid from : $CERT_NOT_BEFORE"
echo " Valid until: $CERT_NOT_AFTER"

echo "[5/15] Create or reuse Sigsum policy file..."
if [ -s "$SIGSUM_POLICY_FILE" ]; then
  echo " Using existing policy file: $SIGSUM_POLICY_FILE"
else
  sigsum-policy show "$SIGSUM_POLICY_NAME" > "$SIGSUM_POLICY_FILE" \
    || fail "failed to create Sigsum policy file from policy name: $SIGSUM_POLICY_NAME"
  [ -s "$SIGSUM_POLICY_FILE" ] || fail "Sigsum policy file was not created"
  echo " Created policy file: $SIGSUM_POLICY_FILE"
fi

echo "[6/15] Prepare artefact bytes to sign (mode: $MODE)..."
canonicalize_if_needed "$MODE" "$ARTEFACT_PATH" "$PREPARED_ARTEFACT" \
  || fail "artefact preparation failed"
[ -s "$PREPARED_ARTEFACT" ] || fail "prepared artefact not created"
ARTEFACT_SIGNED_SHA256="$(shasum -a 256 "$PREPARED_ARTEFACT" | awk '{print $1}')"
echo " Prepared artefact SHA-256: $ARTEFACT_SIGNED_SHA256"

echo "[7/15] Create detached Ed25519 signature..."
python3 - "$SSH_KEY" "$PREPARED_ARTEFACT" "$SIG_BIN" "$SIG_B64" <<'PY'
import sys
import base64
from cryptography.hazmat.primitives import serialization

key_path, artefact_path, sig_bin_path, sig_b64_path = sys.argv[1:5]

with open(key_path, "rb") as f:
    key = serialization.load_ssh_private_key(f.read(), password=None)

with open(artefact_path, "rb") as f:
    data = f.read()

sig = key.sign(data)

with open(sig_bin_path, "wb") as f:
    f.write(sig)

with open(sig_b64_path, "w", encoding="ascii") as f:
    f.write(base64.b64encode(sig).decode("ascii"))
PY

[ -s "$SIG_BIN" ] || fail "binary signature not created"
[ -s "$SIG_B64" ] || fail "base64 signature not created"

echo "[8/15] Verify detached signature locally against prepared artefact..."
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
PY

echo "[9/15] Create RFC 3161 timestamp request over detached signature..."
"$OPENSSL_BIN" ts -query -data "$SIG_BIN" -sha256 -cert -out "$TSQ_FILE" \
  || fail "failed to create timestamp request"
[ -s "$TSQ_FILE" ] || fail "timestamp request not created"

echo "[10/15] Obtain timestamp response from TSA..."
tsget -h "$TSA_URL" -o "$TSR_FILE" "$TSQ_FILE" \
  || fail "tsget failed"
[ -s "$TSR_FILE" ] || fail "timestamp response not created"

echo "[11/15] Verify timestamp response..."
VERIFY_ARGS=(ts -verify -in "$TSR_FILE" -queryfile "$TSQ_FILE")
if [ -n "$TSA_CA_FILE" ]; then
  VERIFY_ARGS+=(-CAfile "$TSA_CA_FILE")
fi
if [ -n "$TSA_UNTRUSTED_FILE" ]; then
  VERIFY_ARGS+=(-untrusted "$TSA_UNTRUSTED_FILE")
fi
"$OPENSSL_BIN" "${VERIFY_ARGS[@]}" \
  || fail "timestamp verification failed"

echo "[12/15] Submit certificate to Sigsum and verify proof..."
sigsum-submit -p "$SIGSUM_POLICY_FILE" -k "$SSH_KEY" "$CERT_DER" \
  || fail "sigsum-submit failed for certificate"
[ -s "$CERT_PROOF" ] || fail "certificate proof not created: $CERT_PROOF"
sigsum-verify -p "$SIGSUM_POLICY_FILE" -k "$SSH_PUB" "$CERT_PROOF" < "$CERT_DER" \
  || fail "sigsum-verify failed for certificate"

echo "[13/15] Submit prepared artefact to Sigsum and verify proof..."
sigsum-submit -p "$SIGSUM_POLICY_FILE" -k "$SSH_KEY" "$PREPARED_ARTEFACT" \
  || fail "sigsum-submit failed for prepared artefact"
[ -s "$ARTEFACT_PROOF" ] || fail "artefact proof not created: $ARTEFACT_PROOF"
sigsum-verify -p "$SIGSUM_POLICY_FILE" -k "$SSH_PUB" "$ARTEFACT_PROOF" < "$PREPARED_ARTEFACT" \
  || fail "sigsum-verify failed for prepared artefact"

echo "[14/15] Generate DNS CERT publication candidate files..."
CERT_B64="$(b64_file_single_line "$CERT_DER")"
[ -n "$CERT_B64" ] || fail "failed to base64-encode certificate"

{
  echo "; DNS CERT publication candidate records for the TEA-native trust model"
  echo "; Publish only during a controlled commit workflow"
  echo "${MANUFACTURER_SAN}. IN CERT PKIX 0 0 ("
  echo " ${CERT_B64}"
  echo ")"
  if [ -n "$PERSISTENCE_SAN" ]; then
    echo
    echo "${PERSISTENCE_SAN}. IN CERT PKIX 0 0 ("
    echo " ${CERT_B64}"
    echo ")"
  fi
} > "$DNS_ZONE_TXT"

{
  echo "; nsupdate input for DNS CERT publication candidates"
  echo "; Publish only during a controlled commit workflow"
  echo "; replace server, zone, and TTL values as appropriate"
  echo "; if manufacturer and persistence names are in different zones,"
  echo "; split these updates into separate nsupdate runs"
  echo "server 127.0.0.1"
  echo "; manufacturer publication"
  echo "update add ${MANUFACTURER_SAN}. 300 IN CERT PKIX 0 0 ${CERT_B64}"
  if [ -n "$PERSISTENCE_SAN" ]; then
    echo "; persistence publication"
    echo "update add ${PERSISTENCE_SAN}. 300 IN CERT PKIX 0 0 ${CERT_B64}"
  fi
  echo "send"
} > "$NSUPDATE_TXT"

echo "[15/15] Write metadata and evidence bundle manifest..."
python3 - \
  "$ARTEFACT_PATH" "$PREPARED_ARTEFACT" "$SIG_BIN" "$SIG_B64" \
  "$CERT_PEM" "$CERT_DER" "$CERT_FINGERPRINT" \
  "$FINGERPRINT" "$MANUFACTURER_SAN" "$PERSISTENCE_SAN" \
  "$CERT_PROOF" "$ARTEFACT_PROOF" "$DNS_ZONE_TXT" "$NSUPDATE_TXT" \
  "$SIGSUM_POLICY_NAME" "$SIGSUM_POLICY_FILE" "$MODE" "$OPENSSL_VERSION" \
  "$CERT_NOT_BEFORE" "$CERT_NOT_AFTER" "$TSA_URL" "$TSQ_FILE" "$TSR_FILE" \
  "$META_JSON" "$EVIDENCE_JSON" <<'PY'
import json
import sys

(
    artefact_path, prepared_artefact, sig_bin, sig_b64,
    cert_pem, cert_der, cert_fingerprint,
    object_fingerprint, manufacturer_san, persistence_san,
    cert_proof, artefact_proof, dns_zone, nsupdate_file,
    sigsum_policy_name, sigsum_policy_file, mode, openssl_version,
    cert_not_before, cert_not_after, tsa_url, tsq_file, tsr_file,
    meta_json, evidence_json,
) = sys.argv[1:26]

meta = {
    "trust_model": "tea-native",
    "input_artefact_file": artefact_path,
    "prepared_artefact_file": prepared_artefact,
    "signature_file": sig_bin,
    "signature_base64_file": sig_b64,
    "certificate_pem_file": cert_pem,
    "certificate_der_file": cert_der,
    "certificate_fingerprint_sha256": cert_fingerprint,
    "public_key_fingerprint_sha256": object_fingerprint,
    "manufacturer_san": manufacturer_san,
    "persistence_san": persistence_san or None,
    "dns_zone_file": dns_zone,
    "dns_nsupdate_file": nsupdate_file,
    "sigsum_policy_name": sigsum_policy_name,
    "sigsum_policy_file": sigsum_policy_file,
    "sigsum_certificate_proof_file": cert_proof,
    "sigsum_artefact_proof_file": artefact_proof,
    "mode": mode,
    "openssl_version": openssl_version,
    "certificate_not_before": cert_not_before,
    "certificate_not_after": cert_not_after,
    "timestamp_format": "rfc3161",
    "timestamp_tsa_url": tsa_url,
    "timestamp_request_file": tsq_file,
    "timestamp_token_file": tsr_file,
}

with open(meta_json, "w", encoding="utf-8") as f:
    json.dump(meta, f, indent=2, sort_keys=True)

evidence = {
    "trust_model": "tea-native",
    "signature": {
        "algorithm": "Ed25519",
        "value_file": sig_bin,
        "value_base64_file": sig_b64,
    },
    "certificate": {
        "pem_file": cert_pem,
        "der_file": cert_der,
        "fingerprint_sha256": cert_fingerprint,
        "manufacturer_san": manufacturer_san,
        "persistence_san": persistence_san or None,
        "not_before": cert_not_before,
        "not_after": cert_not_after,
    },
    "timestamp": {
        "format": "rfc3161",
        "tsa_url": tsa_url,
        "request_file": tsq_file,
        "token_file": tsr_file,
    },
    "transparency": {
        "system": "sigsum",
        "policy_file": sigsum_policy_file,
        "policy_name": sigsum_policy_name,
        "certificate_proof_file": cert_proof,
        "artefact_proof_file": artefact_proof,
    },
    "dns_publication_candidates": {
        "zone_file": dns_zone,
        "nsupdate_file": nsupdate_file,
    },
    "input": {
        "artefact_file": artefact_path,
        "prepared_artefact_file": prepared_artefact,
    },
}

with open(evidence_json, "w", encoding="utf-8") as f:
    json.dump(evidence, f, indent=2, sort_keys=True)
PY

if [ "$DESTROY_KEYS" = "1" ]; then
  echo "Destroying ephemeral private keys..."
  rm -f "$SSH_KEY" "$OPENSSL_KEY_PEM" || fail "failed to destroy private keys"
fi

echo
echo "Done."
echo " Output directory           : $OUTDIR"
echo " Trust model               : tea-native"
echo " Input artefact            : $ARTEFACT_PATH"
echo " Prepared artefact         : $PREPARED_ARTEFACT"
echo " Detached signature        : $SIG_BIN"
echo " Signature (base64)        : $SIG_B64"
echo " Certificate (PEM)         : $CERT_PEM"
echo " Certificate (DER)         : $CERT_DER"
echo " Timestamp request         : $TSQ_FILE"
echo " Timestamp token           : $TSR_FILE"
echo " Certificate proof         : $CERT_PROOF"
echo " Artefact proof            : $ARTEFACT_PROOF"
echo " DNS zone candidate        : $DNS_ZONE_TXT"
echo " DNS nsupdate candidate    : $NSUPDATE_TXT"
echo " Metadata                  : $META_JSON"
echo " Evidence bundle manifest  : $EVIDENCE_JSON"
if [ "$DESTROY_KEYS" = "1" ]; then
  echo " Private keys              : destroyed"
else
  echo " Private keys              : retained in $OUTDIR"
fi
