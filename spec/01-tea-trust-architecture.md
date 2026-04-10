
📘 TEA Trust Architecture Specification

File: spec/tea-trust-architecture.md

⸻

1. Purpose

This specification defines the TEA Trust Architecture, an overlay to the Transparency Exchange API (TEA) that provides:
* cryptographic authenticity
* verifiable integrity
* explicit trust models
* long-term validation (≥10 years)
* decentralized trust anchor distribution

The architecture ensures that a consumer can determine:

whether a given artifact belongs to a manufacturer-approved release,
and that this statement remains verifiable over time.

⸻

2. Scope

This specification applies to:
* TEA discovery (.well-known/tea)
* TEA collections (release definitions)
* artifacts referenced by collections (SBOM, VEX, attestations, CLE)

It defines:
* trust domains
* trust models
* validation rules
* evidence requirements

It does not redefine the TEA core API or collection schema.

⸻

3. Design Principles

3.1 Separation of Trust Domains

TEA defines three independent trust domains:

Domain	Question Answered
Publisher Signing Trust	Was this release intentionally published by the manufacturer?
Consumer Discovery Trust	Am I talking to the correct TEA service?
Consumer Artifact Trust	Am I receiving correct and unmodified artifacts from the correct publisher?

These domains:
* MUST be evaluated independently
* MUST NOT share implicit trust assumptions
* MUST NOT be merged into a single validation step

⸻

3.2 Evidence-Based Trust

Trust MUST NOT rely on signatures alone.

Trust is established through combined evidence:
* signature
* timestamp (TSA)
* transparency log inclusion
* identity binding (DNS or PKI)

Validation MUST consider:

whether the signature was valid at the time it was produced

⸻

3.3 Key-as-Identity
* the public key is the identity
* X.509 certificates are validity wrappers
* trust is derived externally (DNS or PKI), not from certificate semantics

⸻

3.4 Short-Lived Keys
* signing certificates SHOULD be short-lived (≤ 24h)
* long-term trust MUST rely on evidence, not key persistence
* revocation MUST NOT be a primary validation mechanism

⸻

3.5 No Hybrid Trust Models
* trustModel MUST be explicit
* consumers MUST NOT infer trust models
* hybrid combinations (e.g., WebPKI + TEA-native evidence) are NOT allowed

⸻

4. Trust Domains

⸻

4.1 Publisher Signing Trust

Question:

Was this release intentionally published by the manufacturer?

Scope:
* collection signature
* authorization of release
* publication process integrity

Mechanisms:
* signing key under manufacturer control
* short-lived signing certificate
* TSA timestamp (REQUIRED)
* transparency log inclusion (RECOMMENDED)

Security Goal:

Prevent unauthorized publication of valid-looking collections.

⸻

4.2 Consumer Discovery Trust

Question:

Am I talking to the correct TEA service?

Scope:
* .well-known/tea
* mapping manufacturer → TEA endpoint

Mechanisms:
* TLS (baseline)
* signed discovery document (REQUIRED)
* timestamp (REQUIRED, NOT optional)
* optional DNS anchoring (TEA-native)
* optional transparency

Key Requirement:

Timestamp for discovery signing MUST be present.

Security Goal:

Prevent redirection to attacker-controlled services.

⸻

4.3 Consumer Artifact Trust

Question:

Am I receiving correct and unmodified artifacts from the correct publisher?

Scope:
* collection integrity
* artifact binding
* publisher identity

Mechanisms:
* collection signature
* artifact hashes
* optional artifact signatures
* timestamp + transparency + anchor validation

Security Goal:

Ensure integrity and publisher attribution of artifacts.

⸻

5. Trust Models

TEA defines two mutually exclusive trust models.

⸻

5.1 WebPKI Model

Description:
* uses existing CA ecosystem
* validation via PKIX

Rules:
* certificate MUST chain to trusted CA
* TLS validation REQUIRED
* signature MUST be validated

Constraints:
* evidence MUST NOT be present
* transparency MAY be used externally but not embedded
* DNS MUST NOT be used as trust anchor

Use Case:
* enterprises using existing PKI infrastructure

⸻

5.2 TAPS Model (TEA-Native)

Description:

Trust Anchor Publication Service (TAPS) uses DNSSEC to distribute trust anchors.

⸻

5.2.1 Trust Anchoring
* certificates MUST be published using DNS CERT records
* DNSSEC validation REQUIRED
* TLSA MUST NOT be used

⸻

5.2.2 Certificate Model
* public key = identity
* exactly one manufacturer SAN REQUIRED
* optional second SAN (persistence domain)
* maximum 2 SANs
* only dNSName allowed

⸻

5.2.3 Evidence Model
Evidence MAY include:
* TSA timestamp
* transparency log receipt

Evidence MUST:
* bind signature to time
* enable long-term validation

⸻

5.2.4 Persistence Model
Optional second SAN enables:
* vendor exit scenarios
* long-term availability independent of manufacturer domain

⸻

6. Evidence Model

⸻

6.1 Timestamp (TSA)

Timestamp MUST:
* be issued by a trusted TSA
* bind signature to a point in time
* prove certificate validity at signing time

Key Property:

A signature remains valid if it was valid at the timestamp moment, even if the certificate expires later.

⸻

6.2 Transparency Log

Transparency logs provide:
* append-only audit trail
* detection of mis-issuance
* proof of existence

Logs MUST:
* be publicly verifiable
* support inclusion proofs

⸻

6.3 Combined Validation

Validation MUST confirm:
	1.	signature correctness
	2.	timestamp validity
	3.	certificate validity at timestamp
	4.	transparency inclusion (if present)
	5.	trust anchor validity

⸻

7. Long-Term Validation Model

TEA supports validation over extended periods (≥10 years).

This is achieved through:
* timestamped signatures
* transparency logs
* stable trust anchors (DNS or PKI)

Validation MUST NOT require:
* live OCSP
* CRL access
* active CA availability

⸻

8. Upstream Supply Chain Integration

Manufacturers:
* MUST consume SBOM, VEX, and related artifacts from upstream suppliers
* SHOULD use TEA for upstream retrieval

TEA enables:

continuous, automated propagation of trust across the supply chain

⸻

9. Lifecycle Integration (CLE)

Lifecycle states MUST be treated as part of validation context.

Examples:
* supported
* end-of-support
* end-of-life
* superseded

Lifecycle data:
* MUST be machine-readable
* SHOULD be distributed via TEA
* MUST align with CRA lifecycle requirements

⸻

10. Validation Flow

⸻

10.1 Discovery
	1.	fetch .well-known/tea
	2.	validate TLS
	3.	verify signature
	4.	verify timestamp (REQUIRED)
	5.	resolve trust model

⸻

10.2 Collection
	1.	fetch collection wrapper
	2.	read trustModel
	3.	validate signature
	4.	validate timestamp
	5.	validate evidence (if TAPS)

⸻

10.3 Artifacts
	1.	verify checksums
	2.	validate signatures (if present)
	3.	correlate with collection

⸻

10.4 Final Decision

Consumer MUST confirm:
* publisher authenticity
* artifact integrity
* trust model compliance

⸻

11. Security Considerations

⸻

11.1 Threats Mitigated
* service spoofing
* artifact tampering
* unauthorized publication
* long-term trust degradation

⸻

11.2 Residual Risks
* denial of service
* DNS availability
* compromised endpoints without signing keys

⸻

12. CRA Alignment

TEA Trust Architecture supports:
* integrity → signatures + hashes
* authenticity → trust anchors
* traceability → transparency logs
* long-term availability → timestamps + persistence

⸻

13. Final Statement

TEA Trust Architecture ensures that:

artifacts are not only authentic, but verifiably correct, time-bound, and traceable—across the entire software supply chain, even years after publication.

