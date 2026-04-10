# 📘 TEA Implementation Guide

Publisher Workflow (Discovery + Artefact Signing)

## 1. Overview

This guide describes how a publisher:

	1.	Signs the discovery document (.well-known/tea)
	2.	Signs TEA collections and artefacts
	3.	Produces timestamps and transparency proofs
	4.	Publishes trust anchors and artefacts correctly

⸻

##  2. Two Different Signing Contexts

TEA defines two independent signing operations.

⸻

2.1 Discovery Signing

Purpose:
* authorize API endpoints

Scope:
* .well-known/tea only

Trust impact:
* limited to endpoint selection
* part of trust bootstrap

⸻

2.2 Artefact Signing

Purpose:
* establish trust in SBOMs, attestations, and releases

Scope:
* TEA collection
* SBOM
* in-toto attestations

Trust impact:
* full trust decision

⸻

## 3. Key Differences

Property	Discovery Signing	Artefact Signing
Purpose	Endpoint authorization	Data trust
Lifetime	short-lived (≤24h)	very short-lived (hours)
DNS anchoring	optional	REQUIRED (TEA-native)
Transparency	optional	REQUIRED (policy-driven)
Timestamp	REQUIRED	REQUIRED
Security impact	medium (bootstrap)	critical


⸻

## 4. Shared Foundations

Both use:

* Ed25519 keys
* X.509 as metadata wrapper
* RFC 8785 canonical JSON (JCS)
* Detached or inline signatures

⸻

## 5. Discovery Signing Workflow

⸻

Step 1 — Generate Ephemeral Key

openssl genpkey -algorithm ED25519 -out discovery.key


⸻

Step 2 — Create Certificate

Requirements:
* self-signed
* short-lived (≤24h)
* MUST NOT include CN

Subject:
* O = legal_name (required for registered entities) or known_name
* OU OPTIONAL
* C SHOULD be present

SAN:

DNS.1 = example.com


⸻

Step 3 — Canonicalize Discovery JSON
* remove signature field
* apply RFC 8785

⸻

Step 4 — Sign
* sign canonical JSON using Ed25519

⸻

Step 5 — Timestamp (REQUIRED)

Obtain TSA timestamp over:
* canonical discovery JSON
or
* signature

MUST:
* validate timestamp before publication

⸻

Step 6 — Optional Transparency
* MAY submit to:
* Sigsum
* SCITT

⸻

Step 7 — Publish

https://example.com/.well-known/tea


⸻

Step 8 — Delete Key

rm discovery.key


⸻

## 6. Artefact Signing Workflow

⸻

Step 1 — Generate Ephemeral Key

openssl genpkey -algorithm ED25519 -out artefact.key


⸻

Step 2 — Create Certificate (CRITICAL)

Certificate MUST:
* be self-signed
* be short-lived (~hours)
* use Ed25519
* NOT include CN

⸻

Subject Requirements
* O MUST contain legal_name (if registered) or known_name
* OU OPTIONAL
* C SHOULD be present

⸻

Fingerprint Derivation

fingerprint = SHA-256(public key)


⸻

SAN Construction

Required:

<fingerprint>.<trust-domain>

Optional persistence SAN:

<fingerprint>.<persistence-domain>

Constraints:
* fingerprint MUST match public key
* MUST be identical across SAN entries
* no unrelated SAN values allowed

⸻

Step 3 — Canonicalize Collection
* remove signature
* apply JCS

⸻

Step 4 — Sign
* detached OR inline (e.g., CycloneDX)
* Ed25519

⸻

Step 5 — Transparency (REQUIRED / policy-driven)

Submit:
* certificate
* artefact

To:
* Sigsum
* or SCITT

MUST:
* verify receipt before continuing

⸻

Step 6 — Timestamp (REQUIRED)

Obtain TSA timestamp over:
* artefact or signature

MUST:
* validate timestamp

SHOULD:
* obtain timestamps from multiple TSAs

⸻

Step 7 — Build Signed Object

Include:
* collection
* signature
* certificate
* timestamp(s)
* transparency receipt(s)

⸻

Step 8 — Publish

Upload via TEA API

⸻

Step 9 — DNS Anchor (TEA-Native)

Publish certificate in DNS:

<fingerprint>.<domain>. IN CERT PKIX 0 0 <base64-cert>

Rules:
* REQUIRED for TEA-native
* DNSSEC OPTIONAL
* persistence domain RECOMMENDED

⸻

Step 10 — Delete Key

rm artefact.key


⸻

## 7. Multi-Anchor Trust Model

Trust is derived from:

* certificate (identity + validity)
* signature (integrity)
* timestamp (time anchor)
* transparency log (inclusion proof)
* DNS (TEA-native anchor distribution)

No single anchor is sufficient.

⸻

## 8. Transparency Policy

* Context: Requirement
* Discovery:	optional
* Artefacts:	REQUIRED (policy-driven)


⸻

## 9. Timestamp Policy

Context	Requirement
* Discovery	REQUIRED
* Artefacts	REQUIRED


⸻

### 9.1 Timestamp Authority (TSA)

A TSA:

* signs a binding between:
* data hash
* time

Output:
* RFC 3161 timestamp token

⸻

### 9.2 What MUST Be Timestamped

Discovery:
* canonical JSON or signature

Artefacts:
* artefact or signature

⸻

### 9.3 Timestamp Validation

Consumers MUST verify:
* TSA signature
* TSA certificate chain
* hash match
* timestamp within signing certificate validity

⸻

### 9.4 Critical Rule

timestamp_time MUST be within certificate validity


⸻

### 9.5 Multi-TSA Strategy

Publishers SHOULD:
* use at least two independent TSAs

⸻

### 9.6 Time Health Validation

Systems SHOULD:
* validate time sources periodically
* reject excessive drift

⸻

### 9.7 Long-Term Validation via TSA and CA

A valid timestamp proves:

the signature existed at a time when the certificate was valid

⸻

Long-Term Validation Conditions

Validation remains possible after certificate expiry if:
* timestamp valid
* timestamp within certificate validity
* TSA signature valid
* TSA chain trusted

⸻

### 9.8 Trust Lifetimes

Component	Lifetime
Signing key	minutes / hours
Signing certificate	hours
Timestamp token	long-term
TSA certificate	years
CA certificate	years


⸻

### 9.9 Archival Validation

Consumers SHOULD retain:
* timestamp tokens
* TSA certificates
* CA certificates
* transparency receipts

⸻

### 9.10 Failure Conditions

If timestamp:
* missing
* invalid
* outside validity

→ MUST reject

⸻

## 10. DNS Policy

Context	Requirement
Discovery	optional
TEA-native	REQUIRED
WebPKI	MUST NOT use DNS as trust anchor; SHOULD use DNS (CAA)


⸻

### 10.1 WebPKI DNS Policy

DNS MUST NOT:
* publish trust anchors

DNS SHOULD:
* provide CAA policy

⸻

CAA Example

```example.com. IN CAA 0 issue "letsencrypt.org"```


⸻

Consumer Requirements

Consumers SHOULD:
* validate CAA
* reject unauthorized CA issuance

⸻

DNSSEC
* OPTIONAL
* strengthens trust

⸻

## 11. CI/CD Integration

Pipeline:
	1.	generate key
	2.	create certificate
	3.	sign
	4.	timestamp
	5.	transparency
	6.	upload draft
	7.	human approval
	8.	DNS publication (if applicable)
	9.	delete key

⸻

## 12. DNS Update Security

Before DNS publication:
* verify fingerprint
* verify certificate
* verify timestamp
* verify transparency

WebPKI:
* MUST NOT publish anchors
* MAY update CAA

⸻

## 13. Time Validation Strategy
* dual TSA
* periodic validation
* drift detection

⸻

## 14. Error Handling
* DISCOVERY_SIGNATURE_INVALID
* DISCOVERY_TIMESTAMP_INVALID
* ARTEFACT_SIGNATURE_INVALID
* SAN_FINGERPRINT_MISMATCH
* TRANSPARENCY_INVALID
* TIMESTAMP_OUT_OF_RANGE

⸻

## 15. Logging

TEA_DISCOVERY_SIGNED domain=example.com
TEA_ARTEFACT_SIGNED collection=release123

Failures:

TEA_TIMESTAMP_FAILED
TEA_TRANSPARENCY_FAILED


⸻

## 16. Security Summary

This model ensures:

* no long-lived private keys
* no revocation dependency
* strong auditability
* time-based trust anchoring
* resilience against DNS and organizational change

DNS role:

* TEA-native → trust anchor distribution
* WebPKI → policy enforcement (CAA)

⸻

🎯 Final Takeaway

TEA signing consists of two independent but aligned systems:
	1.	Discovery → “Where do I go?” (timestamp REQUIRED)
	2.	Artefact → “What can I trust?”

⸻

🔐 Core Architectural Insight

Private keys only need to exist for minutes or hours

Trust can be validated for years
