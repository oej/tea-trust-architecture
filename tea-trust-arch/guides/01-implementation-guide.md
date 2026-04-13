# 📘 TEA Implementation Guide

Publisher Workflow (Discovery + Artefact Signing + CLE Signing)

## 1. Overview

This guide describes how a publisher:

1. signs the discovery document (`.well-known/tea`)
2. signs TEA collections and artefacts
3. signs lifecycle (CLE) documents
4. produces timestamps and transparency proofs
5. publishes trust anchors and artefacts correctly

⸻

## 2. Different Signing Contexts

TEA defines independent signing operations.

⸻

### 2.1 Discovery Signing

Purpose:
* authorize API endpoints

Scope:
* `.well-known/tea` only

Trust impact:
* limited to endpoint selection
* part of trust bootstrap

⸻

### 2.2 Artefact Signing

Purpose:
* establish trust in SBOMs, attestations, and releases

Scope:
* TEA collection
* SBOM
* in-toto attestations

Trust impact:
* full trust decision for artefacts and release composition

⸻

### 2.3 Lifecycle (CLE) Signing

Purpose:
* establish trust in lifecycle statements and future lifecycle events

Scope:
* versioned CLE documents for:
  * product
  * product release
  * component
  * component release

Trust impact:
* lifecycle trust and auditability
* compliance and operational decision support

⸻

## 3. Key Differences

| Property | Discovery Signing | Artefact Signing | CLE Signing |
|----------|-------------------|------------------|-------------|
| Purpose | Endpoint authorization | Data trust | Lifecycle trust |
| Lifetime | short-lived (≤24h) | very short-lived (hours) | very short-lived (hours) |
| DNS anchoring | optional | REQUIRED (TEA-native) | REQUIRED (TEA-native) |
| Transparency | optional | REQUIRED (policy-driven) | REQUIRED (policy-driven) |
| Timestamp | REQUIRED | REQUIRED | REQUIRED |
| Security impact | medium (bootstrap) | critical | critical |

⸻

## 4. Shared Foundations

All signing contexts use:

* Ed25519 keys
* X.509 as metadata wrapper
* RFC 8785 canonical JSON (JCS)
* detached or inline signatures

⸻

## 5. Discovery Signing Workflow

⸻

### Step 1 — Generate Ephemeral Key

```bash
openssl genpkey -algorithm ED25519 -out discovery.key
```

⸻

### Step 2 — Create Certificate

Requirements:
* self-signed
* short-lived (≤24h)
* MUST NOT include CN

Subject:
* O = legal_name (required for registered entities) or known_name
* OU OPTIONAL
* C SHOULD be present

SAN:

```text
DNS.1 = example.com
```

⸻

### Step 3 — Canonicalize Discovery JSON
* remove signature field
* apply RFC 8785

⸻

### Step 4 — Sign
* sign canonical JSON using Ed25519

⸻

### Step 5 — Timestamp (REQUIRED)

Obtain TSA timestamp over:
* canonical discovery JSON
or
* signature

MUST:
* validate timestamp before publication

⸻

### Step 6 — Optional Transparency
* MAY submit to:
  * Sigsum
  * SCITT

⸻

### Step 7 — Publish

```text
https://example.com/.well-known/tea
```

⸻

### Step 8 — Delete Key

```bash
rm discovery.key
```

⸻

## 6. Artefact Signing Workflow

⸻

### Step 1 — Generate Ephemeral Key

```bash
openssl genpkey -algorithm ED25519 -out artefact.key
```

⸻

### Step 2 — Create Certificate (CRITICAL)

Certificate MUST:
* be self-signed
* be short-lived (~hours)
* use Ed25519
* NOT include CN

⸻

#### Subject Requirements
* O MUST contain legal_name (if registered) or known_name
* OU OPTIONAL
* C SHOULD be present

⸻

#### Fingerprint Derivation

```text
fingerprint = SHA-256(public key)
```

⸻

#### SAN Construction

Required:

```text
<fingerprint>.<trust-domain>
```

Optional persistence SAN:

```text
<fingerprint>.<persistence-domain>
```

Constraints:
* fingerprint MUST match public key
* MUST be identical across SAN entries
* no unrelated SAN values allowed

⸻

### Step 3 — Canonicalize Collection
* remove signature
* apply JCS

⸻

### Step 4 — Sign
* detached OR inline (e.g., CycloneDX)
* Ed25519

⸻

### Step 5 — Transparency (REQUIRED / policy-driven)

Submit:
* certificate
* artefact

To:
* Sigsum
* or SCITT

MUST:
* verify receipt before continuing

⸻

### Step 6 — Timestamp (REQUIRED)

Obtain TSA timestamp over:
* artefact or signature

MUST:
* validate timestamp

SHOULD:
* obtain timestamps from multiple TSAs

⸻

### Step 7 — Build Signed Object

Include:
* collection
* signature
* certificate
* timestamp(s)
* transparency receipt(s)

⸻

### Step 8 — Publish

Upload via TEA API

⸻

### Step 9 — DNS Anchor (TEA-Native)

Publish certificate in DNS:

```text
<fingerprint>.<domain>. IN CERT PKIX 0 0 <base64-cert>
```

Rules:
* REQUIRED for TEA-native
* DNSSEC OPTIONAL
* persistence domain RECOMMENDED

⸻

### Step 10 — Delete Key

```bash
rm artefact.key
```

⸻

## 7. CLE Signing Workflow

⸻

### Step 1 — Generate Ephemeral Key

```bash
openssl genpkey -algorithm ED25519 -out cle.key
```

⸻

### Step 2 — Create Certificate

Certificate requirements are the same as for artefact signing:

* self-signed
* short-lived (~hours)
* Ed25519
* no CN
* fingerprint-derived SAN
* optional persistence SAN

⸻

### Step 3 — Prepare CLE Document

Example structure:

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

Key properties:
* CLE MUST be versioned
* previous versions MUST remain accessible
* updates MUST NOT overwrite historical lifecycle state

⸻

### Step 4 — Canonicalize
* apply JCS
* sign canonical JSON

⸻

### Step 5 — Transparency (REQUIRED / policy-driven)

Submit:
* CLE document
* or signature

To:
* Sigsum
* or SCITT

MUST:
* verify receipt before continuing

⸻

### Step 6 — Timestamp (REQUIRED)

Obtain TSA timestamp over:
* CLE document or signature

MUST:
* validate timestamp

⸻

### Step 7 — Build Signed CLE Object

Include:
* CLE payload
* signature
* certificate
* timestamp(s)
* transparency receipt(s)

CLE uses an embedded evidence model and does not rely on external evidence bundles.

⸻

### Step 8 — Upload Draft

Upload the new CLE version to the publisher service as a draft.

⸻

### Step 9 — Human Approval and Commit

CLE publication MUST follow the same authorization model as collection publication:

* CI/CD MAY prepare
* human approver MUST authorize commit
* lifecycle publication MUST be auditable

⸻

### Step 10 — DNS Anchor (TEA-Native)

Publish the CLE signing certificate in DNS using the same rules as artefact signing.

⸻

### Step 11 — Delete Key

```bash
rm cle.key
```

⸻

## 8. Multi-Anchor Trust Model

Trust is derived from:

* certificate (identity + validity)
* signature (integrity)
* timestamp (time anchor)
* transparency log (inclusion proof)
* DNS (TEA-native anchor distribution)

No single anchor is sufficient.

⸻

## 9. Transparency Policy

| Context | Requirement |
|---------|-------------|
| Discovery | optional |
| Artefacts | REQUIRED (policy-driven) |
| CLE | REQUIRED (policy-driven) |

⸻

## 10. Timestamp Policy

| Context | Requirement |
|---------|-------------|
| Discovery | REQUIRED |
| Artefacts | REQUIRED |
| CLE | REQUIRED |

⸻

### 10.1 Timestamp Authority (TSA)

A TSA:

* signs a binding between:
  * data hash
  * time

Output:
* RFC 3161 timestamp token

⸻

### 10.2 What MUST Be Timestamped

Discovery:
* canonical JSON or signature

Artefacts:
* artefact or signature

CLE:
* CLE document or signature

⸻

### 10.3 Timestamp Validation

Consumers MUST verify:
* TSA signature
* TSA certificate chain
* hash match
* timestamp within signing certificate validity

⸻

### 10.4 Critical Rule

```text
timestamp_time MUST be within certificate validity
```

⸻

### 10.5 Multi-TSA Strategy

Publishers SHOULD:
* use at least two independent TSAs

⸻

### 10.6 Time Health Validation

Systems SHOULD:
* validate time sources periodically
* reject excessive drift

⸻

### 10.7 Long-Term Validation via TSA and CA

A valid timestamp proves:

```text
the signature existed at a time when the certificate was valid
```

⸻

#### Long-Term Validation Conditions

Validation remains possible after certificate expiry if:
* timestamp valid
* timestamp within certificate validity
* TSA signature valid
* TSA chain trusted

⸻

### 10.8 Trust Lifetimes

| Component | Lifetime |
|-----------|----------|
| Signing key | minutes / hours |
| Signing certificate | hours |
| Timestamp token | long-term |
| TSA certificate | years |
| CA certificate | years |

⸻

### 10.9 Archival Validation

Consumers SHOULD retain:
* timestamp tokens
* TSA certificates
* CA certificates
* transparency receipts

⸻

### 10.10 Failure Conditions

If timestamp is:
* missing
* invalid
* outside validity

→ MUST reject

⸻

## 11. DNS Policy

| Context | Requirement |
|---------|-------------|
| Discovery | optional |
| TEA-native | REQUIRED |
| WebPKI | MUST NOT use DNS as trust anchor; SHOULD use DNS (CAA) |

⸻

### 11.1 WebPKI DNS Policy

DNS MUST NOT:
* publish trust anchors

DNS SHOULD:
* provide CAA policy

⸻

#### CAA Example

```text
example.com. IN CAA 0 issue "letsencrypt.org"
```

⸻

#### Consumer Requirements

Consumers SHOULD:
* validate CAA
* reject unauthorized CA issuance

⸻

#### DNSSEC

* OPTIONAL
* strengthens trust

⸻

## 12. CI/CD Integration

Pipeline:

1. generate key
2. create certificate
3. sign
4. timestamp
5. transparency
6. upload draft
7. human approval
8. DNS publication (if applicable)
9. delete key

This applies to:
* discovery
* artefacts
* CLE documents

⸻

## 13. DNS Update Security

Before DNS publication:
* verify fingerprint
* verify certificate
* verify timestamp
* verify transparency

WebPKI:
* MUST NOT publish anchors
* MAY update CAA

⸻

## 14. Time Validation Strategy

* dual TSA
* periodic validation
* drift detection

⸻

## 15. Error Handling

* DISCOVERY_SIGNATURE_INVALID
* DISCOVERY_TIMESTAMP_INVALID
* ARTEFACT_SIGNATURE_INVALID
* SAN_FINGERPRINT_MISMATCH
* TRANSPARENCY_INVALID
* TIMESTAMP_OUT_OF_RANGE
* CLE_SIGNATURE_INVALID
* CLE_VERSION_INVALID
* CLE_COMMIT_UNAUTHORIZED

⸻

## 16. Logging

```text
TEA_DISCOVERY_SIGNED domain=example.com
TEA_ARTEFACT_SIGNED collection=release123
TEA_CLE_SIGNED entity=productRelease id=example-product@1.0.0 version=2
```

Failures:

```text
TEA_TIMESTAMP_FAILED
TEA_TRANSPARENCY_FAILED
TEA_CLE_COMMIT_REJECTED
```

⸻

## 17. Security Summary

This model ensures:

* no long-lived private keys
* no revocation dependency
* strong auditability
* time-based trust anchoring
* resilience against DNS and organizational change

DNS role:

* TEA-native → trust anchor distribution
* WebPKI → policy enforcement (CAA)

CLE role:

* lifecycle trust and historical accountability
* does not change artefact cryptographic validity
* supports operational and compliance decisions

⸻

🎯 Final Takeaway

TEA signing consists of three independent but aligned systems:

1. Discovery → “Where do I go?” (timestamp REQUIRED)
2. Artefact → “What can I trust?”
3. CLE → “What is the lifecycle commitment over time?”

⸻

🔐 Core Architectural Insight

Private keys only need to exist for minutes or hours.

Trust can be validated for years.