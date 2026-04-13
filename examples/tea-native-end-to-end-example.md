# 📘 TEA Trust Architecture — End-to-End Example

## Status

This document is informative.

It provides a worked example of a TEA Trust Architecture publication and validation flow using:

- short-lived self-signed signing certificates
- DNS-published trust anchors
- timestamps
- transparency evidence
- controlled publication and commit

This example does not define normative protocol behavior, but illustrates how the TEA Trust Architecture can be implemented in practice.

---

## 1. What this example proves

This example shows how a publisher can:

1. create short-lived self-signed certificates for:
   - discovery signing
   - collection signing
   - artefact signing
2. derive certificate SAN names from the public key fingerprint
3. publish TEA-native trust anchors in DNS
4. sign the discovery document
5. sign artefacts
6. create and sign a TEA collection
7. create a draft release
8. require human approval for commit
9. let consumers validate:
   - discovery
   - artefacts
   - release binding
   - timestamp
   - transparency
   - DNS publication

---

## 1.1 Trusted Delivery vs Trusted Content

This example demonstrates **trusted delivery**.

It proves:

- who signed the artefact
- when it existed
- that it has not been modified

It does **not** prove:

- that the SBOM is complete
- that vulnerability data is correct
- that the release is secure

---

## 2. Example deployment profile

This worked example uses:

- manufacturer domain: `example.com`
- discovery endpoint on manufacturer domain
- TEA API on third-party host: `https://tea-host.example.net/api`
- TEA-native trust anchor publication in DNS under:
  - manufacturer trust domain: `teatrust.example.com`
  - optional persistence domain: `teatrust.archive.example.net`

This is a strong TEA-native profile, not the only valid deployment.

---

## 3. Example directory layout

Use a working directory like this:

```text
tea-demo/
  discovery/
  artefacts/
  collection/
  draft/
  publish/
  consumer/
```

---

## 4. Variables used in the example

```bash
export MANUFACTURER_DOMAIN="example.com"
export TRUST_DOMAIN="teatrust.example.com"
export PERSISTENCE_TRUST_DOMAIN="teatrust.archive.example.net"

export DISCOVERY_URL="https://example.com/.well-known/tea"
export TEA_API_BASE="https://tea-host.example.net/api"

export RELEASE_ID="release-2026-03-29"
export VERSION="1.0.0"
```

---

# PART A — Publisher Side

## 5. Generate short-lived discovery signing material

Discovery signing in the current architecture uses a short-lived self-signed certificate, not a CA-issued leaf certificate.

### 5.1 Generate discovery key

```bash
mkdir -p discovery

openssl genpkey -algorithm ED25519 -out discovery/discovery.key
```

### 5.2 Derive discovery public key fingerprint

Example conceptually:

```text
fingerprint = SHA-256(public key)
```

This fingerprint is used in the TEA-native SAN DNS name.

### 5.3 Construct discovery SAN DNS name

For discovery in TEA-native, use a fingerprint-derived SAN under the trust domain:

```text
<fingerprint>.teatrust.example.com
```

Optional persistence SAN:

```text
<fingerprint>.teatrust.archive.example.net
```

### 5.4 Create discovery certificate config

Create `discovery/discovery.cnf`:

```ini
[ req ]
distinguished_name = dn
prompt = no
x509_extensions = v3_req

[ dn ]
O = Example Corp
OU = TEA Discovery Signing
C = SE

[ v3_req ]
basicConstraints = critical, CA:FALSE
keyUsage = critical, digitalSignature
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = <fingerprint>.teatrust.example.com
DNS.2 = <fingerprint>.teatrust.archive.example.net
```

If you do not use a persistence domain, omit `DNS.2`.

### 5.5 Create short-lived self-signed discovery certificate

```bash
openssl req -new -x509 \
  -key discovery/discovery.key \
  -out discovery/discovery.crt \
  -days 1 \
  -config discovery/discovery.cnf
```

### 5.6 Validate discovery certificate profile

Check that:

- subject contains `O`, optionally `OU`, and `C`
- `CN` is absent
- key usage is `digitalSignature`
- SAN contains fingerprint-derived DNS name(s)
- certificate is short-lived

---

## 6. Prepare discovery document

Create `discovery/tea.json` without signature first:

```json
{
  "schemaVersion": 2,
  "trustModelsSupported": ["tea-native"],
  "defaultTrustModel": "tea-native",
  "publisher": {
    "legal_name": "Example Corp"
  },
  "endpoints": [
    {
      "url": "https://tea-host.example.net/api",
      "versions": ["1.0.0"],
      "priority": 1,
      "role": "primary",
      "operatorType": "thirdParty"
    }
  ]
}
```

This is illustrative. The exact schema must match the adopted discovery specification.

---

## 7. Canonicalize and sign discovery document

Use RFC 8785 canonicalization.

### 7.1 Canonicalize

Assume a canonicalizer tool named `jcs`:

```bash
jcs discovery/tea.json > discovery/tea.canonical.json
```

### 7.2 Sign discovery JSON

Conceptually:

```bash
openssl pkeyutl -sign \
  -inkey discovery/discovery.key \
  -rawin \
  -in discovery/tea.canonical.json \
  -out discovery/tea.sig
```

### 7.3 Encode certificate and signature

On macOS, prefer stdin form or Python-based encoding rather than `base64 file`.

Example:

```bash
base64 < discovery/discovery.crt | tr -d '\n' > discovery/discovery.crt.b64
base64 < discovery/tea.sig | tr -d '\n' > discovery/tea.sig.b64
```

### 7.4 Obtain discovery timestamp (required)

The earlier name `tsa-client` is best treated as an **illustrative placeholder**, not a standardized TEA tool name.

With OpenSSL, RFC 3161 timestamping is handled using the `openssl ts` command family, and `tsget` can send requests over HTTP/HTTPS where that utility is available in the OpenSSL toolset. A practical flow is:

```bash
openssl ts -query -data discovery/tea.canonical.json -sha256 -cert -out discovery/tea.tsq

tsget -h https://tsa.example.org/tsa \
  -o discovery/tea.tsr \
  discovery/tea.tsq
```

Validation of the timestamp MUST succeed before publication.

### 7.5 Optional discovery transparency

Example:

```bash
sigsum-submit discovery/tea.canonical.json > discovery/tea.receipt
```

### 7.6 Build final signed discovery document

Create `discovery/tea.signed.json`:

```json
{
  "schemaVersion": 2,
  "trustModelsSupported": ["tea-native"],
  "defaultTrustModel": "tea-native",
  "publisher": {
    "legal_name": "Example Corp"
  },
  "endpoints": [
    {
      "url": "https://tea-host.example.net/api",
      "versions": ["1.0.0"],
      "priority": 1,
      "role": "primary",
      "operatorType": "thirdParty"
    }
  ],
  "signature": {
    "wrapperType": "x509",
    "wrapper": "<base64 of discovery/discovery.crt>",
    "algorithm": "Ed25519",
    "value": "<base64 of discovery/tea.sig>"
  },
  "timestamp": {
    "format": "rfc3161",
    "value": "<timestamp token>"
  }
}
```

---

## 8. Publish discovery certificate in DNS

For TEA-native, the self-signed certificate is the trust anchor and MUST be published in DNS under the SAN DNS name.

### 8.1 Convert certificate to base64

```bash
base64 < discovery/discovery.crt | tr -d '\n' > discovery/discovery.crt.b64
```

### 8.2 DNS CERT record

```text
<fingerprint>.teatrust.example.com. IN CERT PKIX 0 0 ( <base64 of discovery/discovery.crt> )
```

Optional persistence publication:

```text
<fingerprint>.teatrust.archive.example.net. IN CERT PKIX 0 0 ( <base64 of discovery/discovery.crt> )
```

### 8.3 Operational rule

These records MUST be:

- published in DNS
- changed only through controlled approval

DNSSEC is optional, but if deployed it strengthens authenticated publication.

---

## 9. Prepare SBOM artefact

Create `artefacts/sbom.json`:

```json
{
  "bomFormat": "CycloneDX",
  "specVersion": "1.6",
  "serialNumber": "urn:uuid:11111111-2222-3333-4444-555555555555",
  "version": 1,
  "metadata": {
    "component": {
      "type": "application",
      "name": "example-product",
      "version": "1.0.0"
    }
  },
  "components": [
    {
      "type": "library",
      "name": "libalpha",
      "version": "2.1.0"
    }
  ]
}
```

---

## 10. Generate short-lived artefact signing material

### 10.1 Generate SBOM signing key

```bash
mkdir -p artefacts

openssl genpkey -algorithm ED25519 -out artefacts/sbom.key
```

### 10.2 Derive artefact signing fingerprint

Conceptually:

```text
fingerprint = SHA-256(public key)
```

### 10.3 Construct SAN DNS names

Required manufacturer SAN:

```text
<fingerprint>.teatrust.example.com
```

Optional persistence SAN:

```text
<fingerprint>.teatrust.archive.example.net
```

### 10.4 Create artefact signing certificate config

Create `artefacts/sbom.cnf`:

```ini
[ req ]
distinguished_name = dn
prompt = no
x509_extensions = v3_req

[ dn ]
O = Example Corp
OU = TEA Artefact Signing
C = SE

[ v3_req ]
basicConstraints = critical, CA:FALSE
keyUsage = critical, digitalSignature
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = <fingerprint>.teatrust.example.com
DNS.2 = <fingerprint>.teatrust.archive.example.net
```

If you do not use a persistence domain, omit `DNS.2`.

### 10.5 Generate self-signed artefact signing certificate

```bash
openssl req -new -x509 \
  -key artefacts/sbom.key \
  -out artefacts/sbom.crt \
  -days 1 \
  -config artefacts/sbom.cnf
```

---

## 11. Canonicalize and sign SBOM

```bash
jcs artefacts/sbom.json > artefacts/sbom.canonical.json

openssl pkeyutl -sign \
  -inkey artefacts/sbom.key \
  -rawin \
  -in artefacts/sbom.canonical.json \
  -out artefacts/sbom.sig
```

Encode outputs:

```bash
base64 < artefacts/sbom.crt | tr -d '\n' > artefacts/sbom.crt.b64
base64 < artefacts/sbom.sig | tr -d '\n' > artefacts/sbom.sig.b64
```

Obtain required timestamp:

```bash
openssl ts -query -data artefacts/sbom.canonical.json -sha256 -cert -out artefacts/sbom.tsq

tsget -h https://tsa.example.org/tsa \
  -o artefacts/sbom.tsr \
  artefacts/sbom.tsq
```

Optional transparency:

```bash
sigsum-submit artefacts/sbom.canonical.json > artefacts/sbom.receipt
```

Conceptual signed artefact envelope:

```json
{
  "payload": { "...": "original SBOM JSON" },
  "signature": {
    "wrapperType": "x509",
    "wrapper": "<base64 sbom cert>",
    "algorithm": "Ed25519",
    "value": "<base64 sbom signature>"
  },
  "timestamp": {
    "format": "rfc3161",
    "value": "<timestamp token>"
  }
}
```

---

## 12. Create short-lived collection signing material

### 12.1 Generate collection signing key

```bash
mkdir -p collection

openssl genpkey -algorithm ED25519 -out collection/collection.key
```

### 12.2 Derive collection fingerprint and SAN names

Required:

```text
<fingerprint>.teatrust.example.com
```

Optional:

```text
<fingerprint>.teatrust.archive.example.net
```

### 12.3 Create collection certificate config

Create `collection/collection.cnf`:

```ini
[ req ]
distinguished_name = dn
prompt = no
x509_extensions = v3_req

[ dn ]
O = Example Corp
OU = TEA Collection Signing
C = SE

[ v3_req ]
basicConstraints = critical, CA:FALSE
keyUsage = critical, digitalSignature
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = <fingerprint>.teatrust.example.com
DNS.2 = <fingerprint>.teatrust.archive.example.net
```

If you do not use a persistence domain, omit `DNS.2`.

### 12.4 Generate self-signed collection certificate

```bash
openssl req -new -x509 \
  -key collection/collection.key \
  -out collection/collection.crt \
  -days 1 \
  -config collection/collection.cnf
```

---

## 13. Create TEA collection

First compute SBOM digest:

```bash
sha256sum artefacts/sbom.json | awk '{print $1}' > artefacts/sbom.sha256
```

Create `collection/collection.json`:

```json
{
  "releaseId": "release-2026-03-29",
  "version": "1.0.0",
  "publisher": {
    "legal_name": "Example Corp"
  },
  "artefacts": [
    {
      "name": "sbom.json",
      "mediaType": "application/vnd.cyclonedx+json",
      "digest": {
        "algorithm": "SHA-256",
        "value": "<sha256 of sbom.json>"
      }
    }
  ]
}
```

Replace the digest value with the computed digest.

---

## 14. Canonicalize and sign collection

```bash
jcs collection/collection.json > collection/collection.canonical.json

openssl pkeyutl -sign \
  -inkey collection/collection.key \
  -rawin \
  -in collection/collection.canonical.json \
  -out collection/collection.sig
```

Encode outputs:

```bash
base64 < collection/collection.crt | tr -d '\n' > collection/collection.crt.b64
base64 < collection/collection.sig | tr -d '\n' > collection/collection.sig.b64
```

Obtain required timestamp:

```bash
openssl ts -query -data collection/collection.canonical.json -sha256 -cert -out collection/collection.tsq

tsget -h https://tsa.example.org/tsa \
  -o collection/collection.tsr \
  collection/collection.tsq
```

Transparency:

```bash
sigsum-submit collection/collection.canonical.json > collection/collection.receipt
```

Build `collection/collection.signed.json`:

```json
{
  "payload": { "...": "original collection JSON" },
  "signature": {
    "wrapperType": "x509",
    "wrapper": "<base64 collection cert>",
    "algorithm": "Ed25519",
    "value": "<base64 collection signature>"
  },
  "timestamp": {
    "format": "rfc3161",
    "value": "<timestamp token>"
  }
}
```

This collection signature means:

- the publisher binds the listed artefacts to this release definition

---

## 15. Publish collection and artefact certificates in DNS

For TEA-native, the signing certificates themselves are published in DNS.

Example records:

```text
<collection-fingerprint>.teatrust.example.com. IN CERT PKIX 0 0 ( <base64 of collection/collection.crt> )
<sbom-fingerprint>.teatrust.example.com.       IN CERT PKIX 0 0 ( <base64 of artefacts/sbom.crt> )
```

Optional persistence equivalents may also be published.

This is different from the earlier rejected two-layer model. There is no CA certificate published as a TEA-native trust anchor because there is no TEA-native CA layer.

---

## 16. Assemble draft release bundle

Create:

```text
draft/
  discovery/tea.signed.json
  discovery/tea.tsr
  discovery/tea.receipt
  artefacts/sbom.json
  artefacts/sbom.signed.json
  artefacts/sbom.tsr
  artefacts/sbom.receipt
  collection/collection.json
  collection/collection.signed.json
  collection/collection.tsr
  collection/collection.receipt
```

This is what CI/CD uploads to the TEA service.

---

## 17. Upload draft release to TEA service

Conceptual publisher flow:

```text
POST /publisher/releases
  -> returns draftReleaseId

POST /publisher/releases/{draftReleaseId}/artefacts
  -> upload sbom.json

POST /publisher/releases/{draftReleaseId}/collection
  -> upload collection.signed.json

POST /publisher/releases/{draftReleaseId}/discovery
  -> upload tea.signed.json

POST /publisher/releases/{draftReleaseId}/evidence
  -> upload timestamps and transparency receipts
```

At this point the release is a draft only.

Authentication may be performed using mechanisms such as OIDC tokens or mTLS, but authorization to commit or publish is separate and MUST be enforced by the publisher workflow.

---

## 18. Human approval and commit

The TEA service presents the draft to an authorized human.

The human must review:

- release ID
- collection digest
- artefact list
- certificate fingerprints
- SAN DNS values
- timestamp status
- transparency receipt status
- whether DNS publication is to occur

The human authenticates with MFA and approves commit.

Conceptual commit request:

```json
{
  "approveRelease": true,
  "approveDiscoveryPublication": true,
  "approveDnsPublication": true
}
```

---

## 19. Commit-time DNS publication rule

This example uses the current TEA-native single-layer DNS trust model.

Therefore, the TEA service publishes or validates the actual signing certificates in DNS, not CA certificates.

If the release used WebPKI:

- TEA-native DNS trust anchor publication must not occur

DNS in WebPKI may still be used for CAA policy, but not as a TEA trust anchor.

---

## 20. Delete short-lived keys

After draft upload or immediately after signing, CI/CD must destroy:

```bash
rm -f discovery/discovery.key
rm -f collection/collection.key
rm -f artefacts/sbom.key
```

Check deletion:

```bash
for f in discovery/discovery.key collection/collection.key artefacts/sbom.key; do
  if [ -f "$f" ]; then
    echo "ERROR: Key deletion failed for $f"
    exit 1
  fi
done
```

This is a core property of the architecture.

---

## 20.1 Example CLE publication

Lifecycle (CLE) documents follow the same publication and approval model as collections.

Example `draft/cle/product-release-1.0.0.json`:

```json
{
  "entityType": "productRelease",
  "entityId": "example-product@1.0.0",
  "version": 2,
  "previousVersion": 1,
  "reason": "Extended end-of-support by one year",
  "lifecycle": {
    "state": "active",
    "endOfSupport": "2030-01-01",
    "endOfLife": "2031-01-01"
  }
}
```

Rules:

- the CLE document MUST be signed
- the CLE document MUST be versioned
- previous CLE versions MUST remain accessible
- commit approval is REQUIRED before publication

---

# PART B — Consumer Side

## 21. Consumer fetches discovery document

```text
GET https://example.com/.well-known/tea
```

The consumer validates TLS.

If TLS fails:

- stop immediately

---

## 22. Consumer validates discovery signature and timestamp

Conceptual flow:

```text
doc = parse_json(tea.signed.json)
sig = doc.signature
ts  = doc.timestamp
payload = remove_fields(doc, "signature", "timestamp")
canonical = JCS(payload)

discovery_cert = parse_x509(sig.wrapper)

fingerprint = sha256(discovery_cert.public_key)
expected_san = "<fingerprint>.teatrust.example.com"

verify_san_matches(discovery_cert, expected_san)
verify_dns_cert_publication(expected_san, discovery_cert)
validate_dnssec_if_present_or_required()
verify_ed25519(discovery_cert.public_key, canonical, sig.value)
verify_timestamp(canonical or sig.value, ts)
```

If successful:

- the discovery endpoint is authorized

---

## 23. Consumer retrieves collection and artefacts

The consumer fetches:

- `collection.signed.json`
- `sbom.json`
- `sbom.signed.json`
- collection timestamp
- artefact timestamp
- transparency receipts

---

## 24. Consumer validates artefact signature

Conceptual flow:

```text
sbom_doc = parse_json(sbom.signed.json)
sbom_payload = sbom_doc.payload
sbom_sig = sbom_doc.signature
sbom_ts = sbom_doc.timestamp

canonical_sbom = JCS(sbom_payload)

sbom_cert = parse_x509(sbom_sig.wrapper)
fp = sha256(sbom_cert.public_key)
expected_san = "<fp>.teatrust.example.com"

verify_san_matches(sbom_cert, expected_san)
verify_dns_cert_publication(expected_san, sbom_cert)
validate_dnssec_if_present_or_required()
verify_ed25519(sbom_cert.public_key, canonical_sbom, sbom_sig.value)
verify_timestamp(canonical_sbom or sbom_sig.value, sbom_ts)
```

If successful:

- the SBOM is authentic

---

## 25. Consumer validates collection signature

Conceptual flow:

```text
collection_doc = parse_json(collection.signed.json)
collection_payload = collection_doc.payload
collection_sig = collection_doc.signature
collection_ts = collection_doc.timestamp

canonical_collection = JCS(collection_payload)

collection_cert = parse_x509(collection_sig.wrapper)
fp = sha256(collection_cert.public_key)
expected_san = "<fp>.teatrust.example.com"

verify_san_matches(collection_cert, expected_san)
verify_dns_cert_publication(expected_san, collection_cert)
validate_dnssec_if_present_or_required()
verify_ed25519(collection_cert.public_key, canonical_collection, collection_sig.value)
verify_timestamp(canonical_collection or collection_sig.value, collection_ts)
```

If successful:

- the release composition is authentic

---

## 26. Consumer validates binding between collection and SBOM

Conceptual flow:

```text
actual_digest = sha256(sbom.json)
expected_digest = collection_payload.artefacts["sbom.json"].digest.value

if actual_digest != expected_digest:
    fail("ARTEFACT_NOT_IN_COLLECTION")
```

Only if this passes can the consumer conclude:

- the authentic SBOM belongs to this release

---

## 27. Consumer validates transparency

Conceptual flow:

```text
verify_transparency_receipt(canonical_collection, collection.receipt)
verify_transparency_receipt(canonical_sbom, sbom.receipt)
```

If required by policy and invalid:

- reject

---

## 28. Final consumer trust decision

The consumer accepts the release only if:

1. discovery is valid
2. discovery timestamp is valid
3. collection signature is valid
4. collection timestamp is valid
5. artefact signature is valid, if required by policy
6. artefact digest matches collection
7. transparency proof is valid, if required by policy
8. DNS publication checks pass for TEA-native

This gives the final statement:

- the manufacturer authorized this TEA endpoint
- this release definition is authentic
- this SBOM is authentic and part of that release

---

## 28.1 Consumer validation of CLE

The consumer may also fetch the current and previous CLE versions.

Conceptual flow:

```text
cle_v2 = fetch_current_cle()
validate_cle_signature(cle_v2)
validate_cle_timestamp(cle_v2)

cle_v1 = fetch_previous_cle()
validate_cle_signature(cle_v1)
validate_cle_timestamp(cle_v1)

compare(cle_v1, cle_v2)
```

This allows a consumer to detect lifecycle changes such as:

- support extension
- earlier-than-expected end-of-support
- end-of-life announcements

---

# PART C — Key Implementation Notes

## 29. What is signed, exactly?

There are three different trust statements:

### Discovery signing

“This manufacturer authorizes this endpoint.”

### Artefact signing

“This artefact is authentic.”

### Collection signing

“This set of artefacts is this release.”

All three matter, but they mean different things.

---

## 30. Why two signing layers for artefacts?

A collection signature alone does not establish independent artefact authenticity.

An artefact signature alone does not prove that the artefact belongs to a given release.

You need both for a complete high-assurance trust model.

---

## 31. Why timestamps and transparency?

They solve the long-term validation problem.

Without them, certificate expiry would weaken later validation.

With them, the consumer can prove:

- the signature existed then
- the signed object was timestamped then
- the object was logged then
- it is still reasonable to trust it now

---

## 32. How this helps against CI/CD compromise

A compromised CI system may upload a malicious draft, but if:

- commit requires MFA
- DNS publication requires commit approval
- consumers validate everything independently

then CI/CD compromise does not automatically become trusted release publication.

---

## 33. Minimal shell helper functions

Example fail-fast pattern:

```bash
fail() {
  echo "ERROR: $1" >&2
  exit 1
}

must() {
  "$@" || fail "command failed: $*"
}
```

Use it like:

```bash
must openssl genpkey -algorithm ED25519 -out artefacts/sbom.key
```

---

## 34. Minimal pseudocode for full publisher flow

```text
build_artefacts()

create_discovery_signing_material()
create_artefact_signing_material()
create_collection_signing_material()

sign_discovery()
timestamp_discovery()
optionally_log_discovery()

sign_artefacts()
timestamp_artefacts()
log_artefacts()

sign_collection()
timestamp_collection()
log_collection()

upload_draft(
  discovery,
  artefacts,
  collection,
  receipts,
  timestamps
)

await_human_commit_with_mfa()

if trust_model == tea_native:
    publish_signing_certs_in_dns()
elif trust_model == webpki:
    reject_dns_trust_anchor_publication()

commit_release()
destroy_short_lived_keys()
```

---

## 35. Minimal pseudocode for full consumer flow

```text
discovery = fetch_well_known()
validate_tls(discovery)
validate_discovery(discovery)

endpoint = choose_endpoint(discovery)

collection = fetch_collection(endpoint)
artefacts = fetch_artefacts(endpoint)

validate_collection_signature(collection)
validate_collection_timestamp(collection)

for artefact in artefacts:
    validate_artefact_signature(artefact)
    validate_binding(artefact, collection)
    validate_artefact_timestamp(artefact)

validate_transparency(collection, artefacts)

accept_release()
```

---

## 36. WebPKI note

If you implement the same workflow in WebPKI mode:

- replace TEA-native DNS trust anchor validation with PKIX validation
- do not publish DNS CERT trust anchors
- optionally publish and validate CAA for stronger issuance policy

---

## 37. Evidence bundle note

All signed objects, timestamps, and transparency receipts together form the **evidence bundle**.

Rules:

- evidence bundles are required for TEA-native trust
- evidence bundles are not used in WebPKI mode
- evidence MUST be verifiable independently of transport

---
