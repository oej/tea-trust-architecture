This draft needs a substantial update to match the current TEA architecture.

The biggest issues are:
* it still includes the removed TEA-native two-layer model
* it says DNSSEC is required, but current TEA says DNS publication is required, DNSSEC is optional
* it says discovery signing is partly optional, but current TEA has required discovery signature and required discovery timestamp
* it uses the wrong SAN model for TEA-native discovery; current model is fingerprint-derived SAN DNS names
* it reintroduces EKU/codeSigning, which you previously chose to avoid as a requirement
* it says TEA-native discovery may use DNS:example.com, which no longer matches the current TAPS identity model
* it underplays the role of timestamps as a core trust anchor

So the document is conceptually useful, but it is not aligned with the current design.

Below is a reviewed and corrected version.

⸻

TEA Discovery Security Architecture

1. Purpose

This document defines the security architecture for TEA discovery, including:
* endpoint authorization
* trust model signaling
* cryptographic protection of discovery data

The discovery mechanism ensures that a consumer connects to API endpoints authorized by the manufacturer.

It does not establish trust in artefacts. Artefact trust is handled separately by collection validation, artefact validation, timestamps, transparency evidence, and trust-anchor validation.

⸻

2. Design Principles

2.1 Separation of Concerns

TEA separates:
* Discovery → endpoint authorization
* Transport → TLS protection
* Artefact trust → signatures, timestamps, transparency, and binding validation

These functions MUST remain separate.

2.2 Identity Model
* public key = identity
* certificate = wrapper
* DNS publishes the TEA-native certificate
* fingerprint-derived SAN binds the certificate name to the key

2.3 Manufacturer Domain as Root of Discovery Control

The manufacturer domain:
* hosts /.well-known/tea
* defines the advertised TEA endpoints
* controls discovery authorization
* may anchor TEA-native discovery certificates through DNS publication

⸻

3. Discovery Endpoint

Consumers retrieve:

https://<manufacturer-domain>/.well-known/tea

TLS validation is required for retrieval.

The discovery document itself MUST also be cryptographically validated.

⸻

4. Trust Layers

4.1 Discovery Trust

Discovery trust establishes:
* which endpoint or endpoints are authorized by the manufacturer

It is based on:
* discovery signature
* discovery timestamp
* trust-model-specific certificate validation
* optional transparency evidence

4.2 Transport Trust

TLS is required for transport protection when retrieving discovery.

TLS alone is not sufficient to authorize discovery content.

4.3 Artefact Trust

Artefact trust is handled separately using:
* collection signatures
* artefact signatures, where used
* timestamps
* transparency logs
* collection-to-artefact binding
* trust-model-specific certificate validation

⸻

5. Trust Models for Discovery

TEA discovery supports two trust models:

5.1 WebPKI
* discovery is signed using a certificate validated through PKIX
* standard WebPKI validation applies
* DNS is not used as a TEA trust anchor
* DNS may still strengthen security via CAA policy

5.2 TEA-Native
* discovery is signed using a short-lived self-signed certificate
* the certificate is published in DNS
* DNS publication is required
* DNSSEC is optional
* certificate SAN DNS names are fingerprint-derived

5.3 Removed Model

TEA-native two-layer discovery using a private CA is not part of the current architecture.

It was removed because it reintroduced:
* long-lived private key protection
* CA lifecycle complexity
* additional PKI semantics contrary to the ephemeral-key design

⸻

6. DNS Trust Model for TEA-Native Discovery

6.1 Publication Model

For TEA-native discovery, the self-signed discovery certificate is published in DNS using a CERT record.

6.2 Namespace

The certificate is published under a fingerprint-derived DNS name:

<fingerprint>.<trust-domain>

Optional persistence publication may also be used:

<fingerprint>.<persistence-domain>

6.3 Record Type

Certificates MUST be published using:
* DNS CERT records, PKIX type

TLSA MUST NOT be used.

6.4 DNSSEC

DNS publication is required.

DNSSEC is optional.

If DNSSEC is present:
* consumers SHOULD validate it
* it provides authenticated DNS distribution

If DNSSEC is absent:
* DNS still provides the required publication location
* consumers MUST treat DNS as unauthenticated publication and rely on the broader trust model

⸻

7. Certificate Profile for Discovery

7.1 Identity Rules
* public key is the identity
* subject is not the trust identity
* SAN DNS names carry the fingerprint-derived publication identity

7.2 Subject

The subject:
* MUST NOT contain CN
* SHOULD contain:
* O
* optional OU
* C

If a legal entity exists, O SHOULD contain its legal name.

7.3 SAN

For TEA-native discovery, the certificate MUST contain:
* one required manufacturer SAN DNS name in fingerprint-derived form
* optionally one persistence SAN DNS name in fingerprint-derived form

Example manufacturer SAN:

<fingerprint>.teatrust.example.com

Example persistence SAN:

<fingerprint>.teatrust.archive.example.net

It is no longer correct to use plain DNS:example.com as the TEA-native discovery identity.

7.4 Key Usage
* digitalSignature is required
* KeyUsage SHOULD be critical

7.5 Extended Key Usage

No EKU is required for the TEA-native discovery model.

Consumers and publishers MUST NOT depend on a TEA-specific or codeSigning EKU for discovery validation.

7.6 Basic Constraints

For TEA-native discovery certificates:
* CA:FALSE
* SHOULD be critical

7.7 Algorithms

For TEA-native discovery:
* Ed25519 is the required algorithm family for the current profile

WebPKI discovery follows the certificate algorithms permitted by PKIX and policy.

7.8 Validity

Discovery signing certificates MUST be short-lived.

Recommended limit:
* 24 hours or less

Shorter lifetimes are preferred.

⸻

8. Signature Model

The discovery document MUST be signed over:
* the canonical JSON form of the document
* excluding the signature object
* excluding the timestamp object if the timestamp is carried separately from the signed payload structure

The signature envelope SHOULD include:
* wrapper type
* wrapper, usually certificate
* algorithm
* signature value

The overall discovery object MUST also carry:
* timestamp
* optional transparency evidence

⸻

9. Canonicalization

RFC 8785 JSON Canonicalization Scheme, JCS, MUST be used for signed discovery JSON.

This is required to ensure deterministic signing and verification.

⸻

10. Timestamp Requirements

Discovery timestamping is required.

The discovery timestamp provides:
* replay resistance against stale discovery data
* signing-time evidence
* a temporal anchor for later validation

Consumers MUST verify:
* TSA signature
* timestamp integrity
* that the timestamp applies to the signed discovery content or signature
* that the timestamp falls within the certificate validity window

⸻

11. Transparency

Transparency for discovery is optional but recommended.

If used, it provides:
* publication evidence
* auditability
* anomaly detection
* support for historical review

Transparency may be provided by:
* Sigsum
* an IETF SCITT-based system

⸻

12. Validation

12.1 WebPKI Discovery Validation

A consumer:
	1.	validates TLS for retrieval
	2.	validates the discovery signing certificate through PKIX
	3.	verifies the discovery signature
	4.	verifies the discovery timestamp
	5.	optionally validates transparency
	6.	optionally checks CAA policy for stronger assurance

12.2 TEA-Native Discovery Validation

A consumer:
	1.	validates TLS for retrieval
	2.	extracts the certificate from the discovery signature wrapper
	3.	computes the public key fingerprint
	4.	verifies that the SAN DNS name is fingerprint-derived
	5.	resolves the corresponding DNS CERT publication
	6.	compares the published certificate with the certificate being validated
	7.	validates DNSSEC if present or required by policy
	8.	verifies the discovery signature
	9.	verifies the discovery timestamp
	10.	optionally validates transparency

⸻

13. Validity Scope

Discovery certificates:
* are valid only for discovery authorization
* MUST NOT be treated as sufficient for artefact trust
* MUST NOT by themselves authorize release content
* SHOULD NOT be cached beyond their intended policy window without revalidation

⸻

14. Security Properties

14.1 Service Independence

API endpoints may be hosted on third-party domains.

Trust remains anchored in:
* manufacturer-controlled discovery
* cryptographic validation
* TEA-native DNS publication or WebPKI validation, depending on trust model

14.2 Compromise Resistance

If a service provider is compromised:
* the attacker may serve false data
* but cannot produce valid discovery signatures without the relevant signing key
* and cannot produce valid artefact trust evidence without satisfying the separate artefact trust model

14.3 Key Compromise

If a TEA-native discovery signing key is compromised:
* misuse is limited to the certificate validity window
* risk is reduced by required timestamps and optional transparency

This is one of the main benefits of the ephemeral-key model.

⸻

15. STRIDE Summary

Spoofing

Mitigated by:
* TLS
* discovery signature
* trust-model-specific certificate validation
* optional DNSSEC
* optional CAA in WebPKI

Tampering

Mitigated by:
* signature validation
* canonicalization
* timestamp validation

Repudiation

Mitigated by:
* signed discovery
* timestamp
* optional transparency

Information Disclosure

Mitigated primarily by:
* TLS in transit
* minimizing discovery metadata

Denial of Service

Mitigated partially by:
* redundancy
* multiple endpoints
* caching

Elevation of Privilege

Mitigated by:
* strict separation between discovery trust and artefact trust
* publication authorization controls
* trust-model-specific validation rules

⸻

16. Error Model

Examples:
* DISCOVERY_SIGNATURE_INVALID
* DISCOVERY_TIMESTAMP_INVALID
* DISCOVERY_CERT_PROFILE_INVALID
* DISCOVERY_DNS_PUBLICATION_MISMATCH
* DISCOVERY_DNSSEC_VALIDATION_FAILED
* DISCOVERY_PKIX_VALIDATION_FAILED

⸻

17. Consumer Flow

A consumer:
	1.	fetches discovery
	2.	validates TLS
	3.	validates discovery schema
	4.	verifies signature
	5.	verifies timestamp
	6.	resolves trust model
	7.	validates certificate according to trust model
	8.	extracts authorized endpoint set
	9.	fetches artefacts later using the independent artefact trust flow

⸻

18. Final Summary

This architecture ensures:
* manufacturer-controlled discovery authorization
* compatibility with both TEA-native and WebPKI trust models
* support for short-lived discovery signing keys
* no dependency on long-term discovery private key protection
* separation between endpoint authorization and artefact trust

Final Statement

TEA discovery binds manufacturer-controlled authorization to service endpoints.

TEA artefact validation separately binds release data and artefacts to cryptographic trust.

If you want, I can next turn this into a cleaned, fully structured file named spec/discovery-security-architecture.md with consistent heading levels and terminology aligned with your other documents.
