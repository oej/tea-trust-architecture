#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

OPENSSL_BIN="${OPENSSL_BIN:-openssl}"

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
        echo "WARNING: use OpenSSL 3.x for inspection if needed." >&2
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
import sys
import base64

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
VALIDITY_HOURS="5"

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
    --help|-h)
      cat <<'EOF'
Usage:
  script.sh --trust-domain DOMAIN
            [--persistence-trust-domain DOMAIN]
            [--mode raw|jcs]
            [--output-dir DIR]
            [--sigsum-policy-name NAME]
            [--subject-o ORG]
            [--subject-ou ORGUNIT]
            [--subject-c COUNTRY]
            [--validity-hours HOURS]
            <artefact-file>

Environment:
  OPENSSL_BIN=/path/to/openssl

Modes:
  raw  - sign exact artefact bytes
  jcs  - canonicalize JSON with RFC 8785 before signing

Description:
  The manufacturer SAN DNS name is derived automatically as:
    <public-key-fingerprint>.<trust-domain>

  The optional persistence SAN DNS name is derived automatically as:
    <public-key-fingerprint>.<persistence-trust-domain>

  The artefact signature is emitted as a detached Ed25519 signature.

Examples:
  script.sh --mode jcs \
    --trust-domain teatrust.acme.example.com \
    sbom.json

  script.sh --mode raw \
    --trust-domain teatrust.acme.example.com \
    --persistence-trust-domain teatrust.archive.example.net \
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

CERT_PROOF="$CERT_DER.proof"
ARTEFACT_PROOF="$PREPARED_ARTEFACT.proof"

DNS_ZONE_TXT="$OUTDIR/dns-cert-record.txt"
NSUPDATE_TXT="$OUTDIR/nsupdate-cert.txt"
META_JSON="$OUTDIR/signing-metadata.json"

SIGSUM_POLICY_FILE="$OUTDIR/sigsum-policy.txt"

if [ -e "$SSH_KEY" ] || [ -e "$SSH_PUB" ] || [ -e "$OPENSSL_KEY_PEM" ] || [ -e "$CERT_PEM" ] || [ -e "$CERT_DER" ]; then
  fail "output files already exist in $OUTDIR; remove them or choose another directory"
fi

echo "[1/12] Generate Ed25519 key in OpenSSH format..."
ssh-keygen -q -t ed25519 -N "" -f "$SSH_KEY" -C "TEA publisher signing key" \
  || fail "ssh-keygen failed"

[ -s "$SSH_KEY" ] || fail "OpenSSH private key not created"
[ -s "${SSH_KEY}.pub" ] || fail "OpenSSH public key not created"

mv "${SSH_KEY}.pub" "$SSH_PUB" \
  || fail "failed to rename public key to $SSH_PUB"

[ -s "$SSH_PUB" ] || fail "renamed OpenSSH public key not found"

echo "[2/12] Derive public key fingerprint and SAN DNS names..."

read -r FINGERPRINT MANUFACTURER_SAN PERSISTENCE_SAN <<EOF
$(python3 - "$SSH_PUB" "$TRUST_DOMAIN" "$PERSISTENCE_TRUST_DOMAIN" <<'PY'
import sys
import base64
import hashlib

ssh_pub_path = sys.argv[1]
trust_domain = sys.argv[2].rstrip(".")
persistence_trust_domain = sys.argv[3].rstrip(".")

with open(ssh_pub_path, "r", encoding="utf-8") as f:
    parts = f.read().strip().split()

if len(parts) < 2:
    raise SystemExit("invalid OpenSSH public key format")

key_blob = base64.b64decode(parts[1])
fingerprint = hashlib.sha256(key_blob).hexdigest().lower()
manufacturer_san = f"{fingerprint}.{trust_domain}"
persistence_san = f"{fingerprint}.{persistence_trust_domain}" if persistence_trust_domain else ""

print(fingerprint, manufacturer_san, persistence_san)
PY
)
EOF

[ -n "$FINGERPRINT" ] || fail "failed to derive key fingerprint"
[ -n "$MANUFACTURER_SAN" ] || fail "failed to derive manufacturer SAN"

echo "      Public key fingerprint (SHA-256): $FINGERPRINT"
echo "      Manufacturer SAN DNS            : $MANUFACTURER_SAN"
if [ -n "$PERSISTENCE_SAN" ]; then
  echo "      Persistence SAN DNS             : $PERSISTENCE_SAN"
fi

echo "[3/12] Export key to PKCS#8 PEM and create short-lived X.509 wrapper..."

python3 - "$SSH_KEY" "$OPENSSL_KEY_PEM" "$MANUFACTURER_SAN" "$PERSISTENCE_SAN" "$CERT_PEM" "$CERT_DER" "$SUBJECT_O" "$SUBJECT_OU" "$SUBJECT_C" "$VALIDITY_HOURS" <<'PY'
import sys
from datetime import datetime, timedelta, timezone
from cryptography import x509
from cryptography.x509.oid import NameOID
from cryptography.hazmat.primitives import serialization

(
    ssh_key_path,
    openssl_key_out,
    manufacturer_san,
    persistence_san,
    pem_out,
    der_out,
    subject_o,
    subject_ou,
    subject_c,
    validity_hours,
) = sys.argv[1:11]

with open(ssh_key_path, "rb") as f:
    key = serialization.load_ssh_private_key(f.read(), password=None)

with open(openssl_key_out, "wb") as f:
    f.write(
        key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption(),
        )
    )

now = datetime.now(timezone.utc)

subject = issuer = x509.Name([
    x509.NameAttribute(NameOID.ORGANIZATION_NAME, subject_o),
    x509.NameAttribute(NameOID.ORGANIZATIONAL_UNIT_NAME, subject_ou),
    x509.NameAttribute(NameOID.COUNTRY_NAME, subject_c),
])

san_values = [x509.DNSName(manufacturer_san)]
if persistence_san:
    san_values.append(x509.DNSName(persistence_san))

cert = (
    x509.CertificateBuilder()
    .subject_name(subject)
    .issuer_name(issuer)
    .public_key(key.public_key())
    .serial_number(x509.random_serial_number())
    .not_valid_before(now - timedelta(minutes=1))
    .not_valid_after(now + timedelta(hours=int(validity_hours)))
    .add_extension(x509.BasicConstraints(ca=False, path_length=None), critical=True)
    .add_extension(
        x509.KeyUsage(
            digital_signature=True,
            content_commitment=False,
            key_encipherment=False,
            data_encipherment=False,
            key_agreement=False,
            key_cert_sign=False,
            crl_sign=False,
            encipher_only=False,
            decipher_only=False
        ),
        critical=True
    )
    .add_extension(
        x509.SubjectAlternativeName(san_values),
        critical=False
    )
    .sign(private_key=key, algorithm=None)
)

with open(pem_out, "wb") as f:
    f.write(cert.public_bytes(serialization.Encoding.PEM))

with open(der_out, "wb") as f:
    f.write(cert.public_bytes(serialization.Encoding.DER))
PY

[ -s "$OPENSSL_KEY_PEM" ] || fail "PKCS#8 PEM private key not created"
[ -s "$CERT_PEM" ] || fail "X.509 PEM certificate not created"
[ -s "$CERT_DER" ] || fail "X.509 DER certificate not created"

echo "[4/12] Validate certificate profile and compute certificate fingerprint..."

read -r CERT_FINGERPRINT CERT_NOT_BEFORE CERT_NOT_AFTER <<EOF
$(python3 - "$CERT_PEM" "$MANUFACTURER_SAN" "$PERSISTENCE_SAN" <<'PY'
import sys
from cryptography import x509
from cryptography.x509.oid import NameOID
from cryptography.hazmat.primitives import hashes

cert_path, manufacturer_san, persistence_san = sys.argv[1:4]

with open(cert_path, "rb") as f:
    cert = x509.load_pem_x509_certificate(f.read())

san = cert.extensions.get_extension_for_class(x509.SubjectAlternativeName).value
dns_names = san.get_values_for_type(x509.DNSName)

expected = [manufacturer_san]
if persistence_san:
    expected.append(persistence_san)

if dns_names != expected:
    raise SystemExit(f"SAN DNS mismatch: expected {expected}, got {dns_names}")

if len(dns_names) < 1 or len(dns_names) > 2:
    raise SystemExit("certificate must contain one required manufacturer SAN and at most one optional persistence SAN")

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
)
EOF

[ -n "$CERT_FINGERPRINT" ] || fail "failed to compute certificate fingerprint"

echo "      Certificate fingerprint (SHA-256): $CERT_FINGERPRINT"
echo "      Valid from                        : $CERT_NOT_BEFORE"
echo "      Valid until                       : $CERT_NOT_AFTER"

echo "[5/12] Create or reuse Sigsum policy file..."

if [ -s "$SIGSUM_POLICY_FILE" ]; then
  echo "      Using existing policy file: $SIGSUM_POLICY_FILE"
else
  sigsum-policy show "$SIGSUM_POLICY_NAME" > "$SIGSUM_POLICY_FILE" \
    || fail "failed to create Sigsum policy file from policy name: $SIGSUM_POLICY_NAME"
  [ -s "$SIGSUM_POLICY_FILE" ] || fail "Sigsum policy file was not created"
  echo "      Created policy file: $SIGSUM_POLICY_FILE"
fi

echo "[6/12] Prepare artefact bytes to sign (mode: $MODE)..."
canonicalize_if_needed "$MODE" "$ARTEFACT_PATH" "$PREPARED_ARTEFACT" || fail "artefact preparation failed"
[ -s "$PREPARED_ARTEFACT" ] || fail "prepared artefact not created"

ARTEFACT_SIGNED_SHA256="$(shasum -a 256 "$PREPARED_ARTEFACT" | awk '{print $1}')"
echo "      Prepared artefact SHA-256         : $ARTEFACT_SIGNED_SHA256"

echo "[7/12] Create detached Ed25519 signature..."

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

echo "[8/12] Verify detached signature locally against prepared artefact..."

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

echo "[9/12] Submit certificate to Sigsum and verify proof..."
sigsum-submit -p "$SIGSUM_POLICY_FILE" -k "$SSH_KEY" "$CERT_DER" \
  || fail "sigsum-submit failed for certificate"
[ -s "$CERT_PROOF" ] || fail "certificate proof not created: $CERT_PROOF"

sigsum-verify -p "$SIGSUM_POLICY_FILE" -k "$SSH_PUB" "$CERT_PROOF" < "$CERT_DER" \
  || fail "sigsum-verify failed for certificate"

echo "[10/12] Submit prepared artefact to Sigsum and verify proof..."
sigsum-submit -p "$SIGSUM_POLICY_FILE" -k "$SSH_KEY" "$PREPARED_ARTEFACT" \
  || fail "sigsum-submit failed for prepared artefact"
[ -s "$ARTEFACT_PROOF" ] || fail "artefact proof not created: $ARTEFACT_PROOF"

sigsum-verify -p "$SIGSUM_POLICY_FILE" -k "$SSH_PUB" "$ARTEFACT_PROOF" < "$PREPARED_ARTEFACT" \
  || fail "sigsum-verify failed for prepared artefact"

echo "[11/12] Generate DNS CERT zone record and nsupdate script..."

CERT_B64="$(b64_file_single_line "$CERT_DER")"
[ -n "$CERT_B64" ] || fail "failed to base64-encode certificate"

{
  echo "; DNS CERT publication records for TAPS"
  echo "${MANUFACTURER_SAN}. IN CERT PKIX 0 0 ("
  echo "  ${CERT_B64}"
  echo ")"
  if [ -n "$PERSISTENCE_SAN" ]; then
    echo
    echo "${PERSISTENCE_SAN}. IN CERT PKIX 0 0 ("
    echo "  ${CERT_B64}"
    echo ")"
  fi
} > "$DNS_ZONE_TXT"

{
  echo "; nsupdate input for DNS CERT publication"
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

[ -s "$DNS_ZONE_TXT" ] || fail "zone file snippet not created"
[ -s "$NSUPDATE_TXT" ] || fail "nsupdate script not created"

echo "[12/12] Write metadata..."

echo "[12/12] Write metadata..."

python3 - "$CERT_PEM" "$SSH_PUB" "$ARTEFACT_PATH" "$PREPARED_ARTEFACT" "$SIG_BIN" "$SIG_B64" "$TRUST_DOMAIN" "$PERSISTENCE_TRUST_DOMAIN" "$MANUFACTURER_SAN" "$PERSISTENCE_SAN" "$CERT_PROOF" "$ARTEFACT_PROOF" "$META_JSON" "$SIGSUM_POLICY_FILE" "$MODE" "$OPENSSL_VERSION" "$OPENSSL_BIN" <<'PY'
import sys
import json
import hashlib
import base64
from cryptography import x509
from cryptography.hazmat.primitives import hashes

(
    cert_path,
    ssh_pub_path,
    artefact_path,
    prepared_path,
    sig_path,
    sig_b64_path,
    trust_domain,
    persistence_trust_domain,
    manufacturer_san,
    persistence_san,
    cert_proof_path,
    artefact_proof_path,
    meta_path,
    sigsum_policy_file,
    mode,
    openssl_version,
    openssl_bin
) = sys.argv[1:18]

with open(cert_path, "rb") as f:
    cert = x509.load_pem_x509_certificate(f.read())

with open(ssh_pub_path, "r", encoding="utf-8") as f:
    ssh_pub_text = f.read().strip()

with open(artefact_path, "rb") as f:
    artefact = f.read()

with open(prepared_path, "rb") as f:
    prepared = f.read()

with open(sig_path, "rb") as f:
    sig = f.read()

not_before = getattr(cert, "not_valid_before_utc", cert.not_valid_before)
not_after = getattr(cert, "not_valid_after_utc", cert.not_valid_after)

pub_parts = ssh_pub_text.split()
if len(pub_parts) < 2:
    raise SystemExit("invalid OpenSSH public key format in public key file")

public_key_blob = base64.b64decode(pub_parts[1])
public_key_fingerprint = hashlib.sha256(public_key_blob).hexdigest().lower()

meta = {
    "trust_model": "taps",
    "identity_type": "public-key-fingerprint-dns",
    "sigsum_policy_file": sigsum_policy_file,
    "signing_mode": mode,
    "trust_domain": trust_domain,
    "persistence_trust_domain": persistence_trust_domain if persistence_trust_domain else None,
    "public_key_fingerprint_sha256": public_key_fingerprint,
    "manufacturer_san_dns": manufacturer_san,
    "persistence_san_dns": persistence_san if persistence_san else None,
    "certificate_fingerprint_sha256": cert.fingerprint(hashes.SHA256()).hex().lower(),
    "san_dns": cert.extensions.get_extension_for_class(x509.SubjectAlternativeName).value.get_values_for_type(x509.DNSName),
    "certificate_not_before": not_before.isoformat(),
    "certificate_not_after": not_after.isoformat(),
    "artefact_file": artefact_path,
    "artefact_raw_sha256": hashlib.sha256(artefact).hexdigest().lower(),
    "prepared_artefact_file": prepared_path,
    "prepared_artefact_sha256": hashlib.sha256(prepared).hexdigest().lower(),
    "signature_format": "detached-ed25519",
    "signature_file": sig_path,
    "signature_sha256": hashlib.sha256(sig).hexdigest().lower(),
    "signature_base64_file": sig_b64_path,
    "openssl_bin": openssl_bin,
    "openssl_version": openssl_version,
    "certificate_sigsum_proof_file": cert_proof_path,
    "artefact_sigsum_proof_file": artefact_proof_path,
    "note": "In mode 'raw', the signature covers exact artefact bytes. In mode 'jcs', the signature covers RFC 8785 canonicalized JSON bytes. SAN names are derived as <public-key-fingerprint>.<trust-domain> and, if configured, <public-key-fingerprint>.<persistence-trust-domain>. The artefact signature is a detached Ed25519 signature."
}

with open(meta_path, "w", encoding="utf-8") as f:
    json.dump(meta, f, indent=2)
PY

echo
echo "SUCCESS"
echo "  OpenSSH private key                  : $SSH_KEY"
echo "  OpenSSH public key                   : $SSH_PUB"
echo "  PKCS#8 PEM private key               : $OPENSSL_KEY_PEM"
echo "  X.509 PEM certificate                : $CERT_PEM"
echo "  X.509 DER certificate                : $CERT_DER"
echo "  Certificate fingerprint (SHA-256)    : $CERT_FINGERPRINT"
echo "  Public key fingerprint (SHA-256)     : $FINGERPRINT"
echo "  Trust domain                         : $TRUST_DOMAIN"
echo "  Manufacturer SAN DNS                 : $MANUFACTURER_SAN"
if [ -n "$PERSISTENCE_SAN" ]; then
  echo "  Persistence trust domain             : $PERSISTENCE_TRUST_DOMAIN"
  echo "  Persistence SAN DNS                  : $PERSISTENCE_SAN"
fi
echo "  OpenSSL binary                       : $OPENSSL_BIN"
echo "  OpenSSL version                      : $OPENSSL_VERSION"
echo "  Sigsum policy file                   : $SIGSUM_POLICY_FILE"
echo "  Artefact mode                        : $MODE"
echo "  Prepared artefact                    : $PREPARED_ARTEFACT"
echo "  Detached signature                   : $SIG_BIN"
echo "  Detached signature (base64)          : $SIG_B64"
echo "  Certificate Sigsum proof             : $CERT_PROOF"
echo "  Artefact Sigsum proof                : $ARTEFACT_PROOF"
echo "  DNS zone-file snippet                : $DNS_ZONE_TXT"
echo "  nsupdate script                      : $NSUPDATE_TXT"
echo "  Metadata                             : $META_JSON"
echo
echo "Zone-file snippet:"
cat "$DNS_ZONE_TXT"
echo
echo "nsupdate snippet:"
cat "$NSUPDATE_TXT"
echo
echo "Note: if manufacturer and persistence names are in different DNS zones, split the nsupdate operations per zone."
