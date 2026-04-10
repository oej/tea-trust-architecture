Here is the full, copy-ready README.md, reconstructed at proper depth (not abbreviated), aligned with everything we built earlier.

⸻
"“CycloneDX tells you what is inside
TEA tells you where to get it
TEA Trust tells you why you can believe it”"

:::writing{variant=“standard” id=“84321”}

Transparency Exchange API (TEA)

Version: 1.0.0
Status: Draft
Intended audience: Security architects, PKI operators, software publishers, regulators, and implementers

⸻

1. Introduction

The Transparency Exchange API (TEA) defines a framework for publishing, distributing, and validating software metadata with cryptographic integrity, verifiable time anchoring, and long-term auditability.

TEA is designed to address a fundamental limitation in traditional digital signature systems:

A signature alone proves integrity at a point in time, but does not provide sufficient evidence for long-term trust.

TEA extends the trust model by combining:
* Cryptographic signatures (integrity and identity)
* Trusted timestamps (time anchoring)
* Transparency logs (public verifiability)

This combination enables validation of software metadata years after publication, even when certificates have expired or trust relationships have evolved.

⸻

2. Motivation

Modern software supply chains rely on metadata such as:
* Software Bills of Materials (SBOMs)
* Vulnerability disclosures
* Build provenance
* Release manifests

These artifacts must remain verifiable over long periods of time, particularly in regulatory contexts such as the EU Cyber Resilience Act (CRA), which requires:
* Retention of security-relevant artifacts for up to 10 years
* The ability to assess historical risk and exposure
* Evidence of publication and integrity

Traditional approaches based solely on PKI are insufficient because:
* Certificates expire
* Revocation information is not reliably preserved
* Trust anchors may change or disappear
* Time of signing cannot be independently verified

TEA addresses these limitations by introducing evidence-based validation.

⸻

3. Design Goals

TEA is built around the following core principles:

3.1 Verifiability Over Trust

Systems SHOULD rely on cryptographic evidence rather than implicit trust in infrastructure.

3.2 Time-Independent Validation

Validation MUST remain possible after:
* Certificate expiration
* Trust anchor rotation
* Algorithm deprecation (within reasonable bounds)

3.3 Decentralized Trust Discovery

Trust anchors MUST be discoverable without reliance on a single centralized authority.

3.4 Short-Lived Keys, Long-Lived Evidence
* Signing keys SHOULD be short-lived
* Evidence (timestamps, transparency proofs) MUST provide long-term assurance

3.5 Append-Only Evidence

Evidence MUST be:
* Append-only
* Independently verifiable
* Resistant to retroactive modification

⸻

4. Core Concepts

4.1 Collection

A collection is the primary TEA object. It represents a set of related artifacts (e.g. SBOMs, metadata, documents) that are:
* Immutable once finalized
* Cryptographically signed
* Associated with verifiable evidence

4.2 Evidence

Evidence provides proof about the collection, including:
* When it existed (timestamp)
* That it was publicly recorded (transparency)

Evidence is:
* Cryptographically verifiable
* Append-only
* Independent of the original signer

4.3 Trust Anchor

A trust anchor is the root of trust used to validate signatures.

TEA supports:
* X.509-based trust anchors
* Raw public keys
* DNS-based discovery mechanisms

4.4 Transparency

Transparency logs provide:
* Public, append-only records
* Inclusion proofs
* Protection against equivocation

⸻

5. System Overview

TEA defines interactions between four primary roles:

Role	Description
Publisher	Creates and signs collections
Transparency Service	Records collections in append-only logs
Time Stamping Authority (TSA)	Issues trusted timestamps
Consumer	Retrieves and validates collections


⸻

6. High-Level Workflow
	1.	A publisher creates a collection in a mutable state
	2.	The collection is finalized and signed
	3.	The publisher obtains:
* A trusted timestamp
* A transparency inclusion proof
	4.	The collection is published
	5.	A consumer retrieves the collection and:
* Resolves trust anchors
* Verifies signatures
* Validates timestamp and transparency evidence

⸻

7. Trust Model

TEA introduces a layered trust model:

7.1 Signature Layer

Provides:
* Integrity
* Publisher identity

7.2 Time Layer

Provides:
* Proof of existence at a specific time
* Protection against backdating

7.3 Transparency Layer

Provides:
* Public auditability
* Detection of hidden or conflicting states

⸻

8. Relationship to Existing Technologies

TEA is designed to interoperate with existing ecosystems:
* X.509 / WebPKI — for identity and trust anchors
* RFC 3161 — for timestamping
* Transparency systems (e.g. Sigsum, SCITT)
* Sigstore-compatible tooling — for signing workflows

TEA does not replace these technologies; it binds them together into a coherent validation model.

⸻

9. Scope

TEA defines:
* Data structures for collections and evidence
* Validation procedures
* Trust discovery mechanisms
* API interactions between publishers and consumers

TEA does NOT define:
* A specific transparency log implementation
* A specific TSA implementation
* A single mandatory PKI hierarchy

⸻

10. Non-Goals

TEA explicitly does not attempt to:
* Replace all existing PKI systems
* Mandate a single global trust anchor
* Provide real-time revocation guarantees
* Eliminate the need for operational security practices

⸻

11. Compliance Considerations

TEA supports regulatory frameworks requiring:
* Long-term retention of security artifacts
* Verifiable publication timelines
* Independent validation capabilities

This includes alignment with:
* EU Cyber Resilience Act (CRA)
* Emerging supply chain security frameworks

⸻

12. Document Structure

The TEA specification is organized as follows:

Core Specification
* /spec/architecture.md — system architecture and threat model
* /spec/data-model.md — collection and evidence structures
* /spec/collection.md — lifecycle and state transitions
* /spec/evidence.md — evidence formats and requirements
* /spec/signatures.md — signature handling and rules
* /spec/trust-discovery.md — trust anchor discovery mechanisms
* /spec/validation.md — validation algorithms
* /spec/error-model.md — error handling and reporting

API Definitions
* /spec/openapi/publisher.yaml — publisher interface
* /spec/openapi/consumer.yaml — consumer interface

Profiles
* /profiles/long-term-validation.md — long-term validation requirements
* /profiles/x509-profile.md — X.509 usage profile

Operational Guidance
* /operations/key-management.md
* /operations/logging.md
* /operations/incident-response.md

Interoperability
* /interop/sigstore.md
* /interop/sigsum.md
* /interop/scitt.md

Examples
* /examples/collection.json
* /examples/evidence.json
* /examples/dns-trust-anchor.md
* /examples/validation-walkthrough.md

⸻

13. Terminology

The key words MUST, SHOULD, and MAY are to be interpreted as described in RFC 2119.

⸻

14. Summary

TEA establishes a model where:
* Signatures provide integrity
* Timestamps provide temporal anchoring
* Transparency provides public accountability

Together, these enable durable, verifiable trust in software metadata over long time horizons.

⸻

