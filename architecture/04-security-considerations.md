Here is the fully updated, consolidated, RFC-style “TEA Security Considerations” document, aligned with the current architecture:
* TEA-native and WebPKI only
* no two-layer TEA-native model
* fingerprint-in-SAN identity
* DNS publication required, DNSSEC optional
* WebPKI may use DNS for CAA policy
* timestamps are mandatory trust anchors
* transparency is via Sigsum or SCITT
* dual-level signing model
* ephemeral key model
* resilience against DNS and organizational change

⸻

📘 TEA Security Considerations

Threat Model, Trust Boundaries, and Risk Analysis

⸻

1. Scope

This document analyzes the security properties of the TEA architecture, covering:
* discovery
* artefact signing and validation
* timestamping
* transparency logging
* DNS-based trust anchor publication
* WebPKI policy constraints
* long-term validation

The goal is to define:
* what threats are mitigated
* what threats remain
* how failures are contained

⸻

2. System Trust Boundaries

The TEA architecture explicitly separates trust across multiple independent components.

2.1 Trust Boundaries

The following boundaries MUST be considered independent:
	1.	Manufacturer domain
	2.	TEA API service, which may be third-party hosted
	3.	DNS infrastructure
	4.	Transparency log
	5.	Timestamp authority
	6.	Consumer environment

No single component is trusted to provide end-to-end integrity.

2.2 Trust Anchors

Trust is derived from a combination of independent anchors:
* certificate
* signature
* timestamp
* transparency log
* DNS publication
* optionally DNSSEC
* or WebPKI, depending on trust model

The system does not assume:
* trusted infrastructure
* trusted cloud hosting
* trusted TEA service operators

2.3 Compositional Trust

TEA does not rely on a single hierarchical chain of trust.

Instead, trust is established by combining multiple independent signals. This reduces dependence on any single infrastructure component and improves resilience against partial compromise.

⸻

3. STRIDE Threat Analysis

3.1 Spoofing

Threat:

An attacker impersonates:
* a manufacturer
* a TEA service endpoint
* a discovery endpoint
* a timestamp authority
* a transparency service

Mitigation:
* TLS validation for transport authenticity
* discovery signatures for endpoint authorization
* certificate and signature validation for artefact authenticity
* fingerprint-in-SAN validation for TEA-native identity binding
* DNSSEC, when present, for authenticated DNS publication
* WebPKI certificate path validation for WebPKI mode
* CAA validation for WebPKI policy enforcement

Residual risk:
* compromise of a trusted CA in WebPKI mode
* compromise of a TSA trust anchor
* first-contact bootstrap risk for discovery transport

⸻

3.2 Tampering

Threat:

An attacker modifies:
* discovery document
* TEA collection
* SBOMs
* attestations
* timestamps
* transparency proofs
* DNS records in transit

Mitigation:
* digital signatures protect discovery, collections, and artefacts
* canonicalization ensures deterministic verification
* detached or inline signature validation protects payload integrity
* timestamps bind data to time
* transparency logs provide evidence of historical publication
* DNSSEC, when present, protects DNS responses against in-transit tampering

Residual risk:
* implementation errors in canonicalization
* acceptance of malformed structured artefacts due to parser mismatch
* failure to validate all anchors consistently

⸻

3.3 Repudiation

Threat:

A publisher denies having:
* published a discovery document
* published a collection
* signed an artefact

Mitigation:
* signatures provide attribution to the signing key
* timestamps provide signing-time evidence
* transparency logs provide external evidence of publication
* DNS publication provides externally observable anchor publication
* subject O and discovery publisher metadata support accountability, though not trust

Residual risk:
* malicious use of a compromised short-lived key during its validity window
* disputes about organizational authority despite technical attribution

⸻

3.4 Information Disclosure

Threat:

Sensitive information is exposed during:
* discovery retrieval
* artefact retrieval
* log submission
* timestamp requests

Mitigation:
* TLS protects transport confidentiality where used
* publishers may minimize metadata exposed in discovery and collections

Residual risk:
* TEA is not designed as a confidentiality system
* transparency services may reveal publication metadata
* timestamp services may reveal request timing or document hashes, depending on protocol and deployment

⸻

3.5 Denial of Service

Threat:

The following become unavailable:
* discovery endpoint
* TEA service
* DNS resolver or authoritative DNS
* timestamp authority
* transparency log

Mitigation:
* consumers MAY cache discovery, trust anchors, timestamps, and proofs
* multiple endpoints MAY be defined in discovery
* persistence publication points MAY be used
* multiple TSAs SHOULD be used
* transparency validation MAY use cached proofs for historical data

Residual risk:
* availability cannot be guaranteed
* validation of new data may be delayed when supporting services are unavailable

⸻

3.6 Elevation of Privilege

Threat:

An attacker gains the ability to:
* publish trusted artefacts
* publish unauthorized discovery data
* inject malicious endpoints
* publish malicious DNS trust anchors
* abuse CA issuance in WebPKI mode

Mitigation:
* signing requires possession of valid private keys
* ephemeral key model limits key lifetime
* DNS publication is externalized and policy-controlled
* timestamps and transparency create external evidence
* CAA restricts CA issuance in WebPKI mode
* discovery and artefact trust are separated, limiting blast radius

Residual risk:
* compromise of active signing keys during release generation
* compromise of DNS publication credentials
* malicious authorized publisher behavior

⸻

4. Attacker Capability Matrix

Capability	Impact	Mitigation
Control TEA service	Serve malicious data	Signature validation, binding validation
Modify discovery document	Redirect endpoint selection	Discovery signature and timestamp validation
DNS spoofing	Fake or suppress trust anchor publication	DNSSEC when present, fingerprint validation, transparency, local policy
DNS update compromise	Publish malicious trust anchor	Publication controls, timestamp and transparency validation, operational controls
Key compromise, short-lived	Limited signing misuse	Ephemeral keys, short validity, timestamps, transparency
WebPKI CA compromise	Fraudulent certificate issuance	PKIX validation plus CAA policy checks
TSA compromise	False time assertions	Multi-TSA strategy, time health checks, policy enforcement
Transparency log compromise	Hide entries or misreport history	Inclusion proofs, consistency proofs, independent verification, multiple logs by policy
Consumer implementation flaw	Validation bypass	Fail-closed design, explicit validation policy, testing
Malicious publisher	Validly signed but deceptive data	Transparency, auditing, policy, legal accountability


⸻

5. Key Security Properties

5.1 Service Independence

Compromise of:
* API hosting
* cloud provider
* CDN
* storage backend

MUST NOT allow an attacker to forge valid artefacts without access to the relevant signing key.

5.2 Ephemeral Key Model

Short-lived keys ensure:
* no long-term key exposure
* no revocation dependency for normal operation
* limited compromise window
* reduced operational burden for key protection

5.3 Transparency Enforcement

Transparency logs ensure:
* publication events are externally visible
* tampering or suppression can be detected
* historical validation has independent evidence

Transparency is provided by a transparency log, such as:
* Sigsum
* an IETF SCITT-based system

5.4 Time Integrity

TEA relies on timestamps as an independent trust anchor.

Timestamps provide:
* evidence that a signature existed at a particular time
* support for long-term validation after signer certificate expiry
* resistance to backdating claims

The architecture relies primarily on trustworthy ordering and bounded time integrity, not on perfect absolute global time.

5.5 DNS and Organizational Resilience

The architecture is designed so that trust does not depend exclusively on the continued control of a single original DNS domain.

This improves resilience in cases such as:
* bankruptcy
* acquisition
* merger
* shutdown of services
* loss of the original domain

An optional persistence publication name supports continuity across such events.

⸻

6. Discovery-Specific Risks

6.1 Discovery Manipulation

If discovery is altered, a consumer may connect to an incorrect endpoint.

Mitigation:
* signature validation
* required timestamp validation
* schema validation
* TLS validation for retrieval

Impact:
* limited primarily to endpoint selection
* does not by itself establish artefact trust

6.2 First-Contact Bootstrap Risk

Initial discovery retrieval relies on:
* TLS trust
* the manufacturer domain name
* availability of the correct .well-known resource

Risk:
* first connection could be intercepted or redirected
* a consumer might retrieve false discovery data before applying signature checks

Mitigation:
* fail closed on signature or timestamp failure
* no artefact trust is established from discovery alone
* subsequent trust decisions rely on independent cryptographic validation

6.3 Discovery Timestamp Requirement

If discovery signatures are not timestamped, an attacker may replay stale but otherwise valid endpoint authorization statements.

Mitigation:
* discovery timestamps are mandatory
* consumers MUST validate timestamp integrity and time applicability

⸻

7. Artefact Validation Risks

7.1 Signature Bypass

If signature verification is skipped or weakened, the trust model collapses.

Mitigation:
* consumers MUST validate signatures
* consumers MUST fail closed on verification error
* validation policy MUST distinguish mandatory vs optional checks explicitly

7.2 Canonicalization Mismatch

If canonicalization differs between publisher and consumer:
* valid signatures may fail
* invalid artefacts may be incorrectly accepted if implementation is flawed

Mitigation:
* strict use of RFC 8785 where JCS is defined
* explicit handling of raw versus canonicalized content
* format-specific inline-signature rules

7.3 Partial Validation

If a consumer validates only artefact signatures or only collection signatures:
* release composition or artefact authenticity can be misrepresented

Mitigation:
* both artefact validation and collection validation are required
* digest binding checks are required

⸻

8. Timestamp Risks

8.1 Untrusted or Dishonest TSA

A TSA signature may be valid but dishonest.

Mitigation:
* use multiple independent TSAs where possible
* enforce timestamp consistency and policy checks
* validate TSA certificate chain
* retain timestamp evidence for later review

8.2 Time Drift

A consumer or publisher system clock may drift significantly.

Mitigation:
* periodic time health validation
* bounded drift policies
* cross-check against independent time sources and additional TSAs

8.3 Long-Term Validation Dependency

Long-term validation depends on preserving:
* timestamp token
* TSA certificate chain
* relevant CA certificate chain

Risk:
* loss of this evidence can weaken historical validation

Mitigation:
* retain timestamp and chain material as archival evidence
* preserve transparency receipts and signing certificates

8.4 Timestamp Outside Certificate Validity

If a timestamp falls outside the signing certificate validity window, later validation cannot reliably prove the signature was produced while the certificate was valid.

Mitigation:
* consumers MUST reject such cases
* publishers MUST validate timestamp before publication

⸻

9. Transparency Log Risks

9.1 Log Misbehavior

A transparency log may:
* hide entries
* equivocate
* rewrite visible history
* produce inconsistent responses

Mitigation:
* inclusion proofs
* consistency proofs
* independent verification
* policy permitting more than one log in higher-assurance profiles

9.2 Log Availability

A log may be unavailable during validation.

Mitigation:
* cached proofs
* deferred validation
* archival evidence storage

Residual risk:
* new submissions or fresh validation may be delayed

⸻

10. DNS Trust Model Risks

10.1 DNS Publication Requirement

For TEA-native, trust anchors are required to be published in DNS.

This creates:
* a stable publication point
* a common resolution mechanism
* a dependency on DNS availability

10.2 DNSSEC Optionality

DNSSEC is optional.

If DNSSEC is present:
* it authenticates the DNS response and provides stronger assurance

If DNSSEC is absent:
* DNS provides publication location, not authenticated publication
* trust must rely more heavily on certificate, timestamp, transparency, and policy

10.3 DNS Update Compromise

If an attacker can publish malicious trust anchors in DNS, consumers may be directed to attacker-controlled anchors.

Mitigation:
* validate fingerprint-to-key consistency
* validate signature and certificate profile
* require timestamp and transparency evidence by policy before publication
* restrict DNS update permissions operationally
* use persistence publication to support continuity, not replace verification

10.4 Resilience Against DNS and Organizational Change

Because trust is anchored in a combination of certificate, timestamp, DNS publication, and transparency evidence, previously published artefacts may remain verifiable even after:
* bankruptcy
* acquisition
* domain migration
* shutdown of original infrastructure

This is strengthened when a persistence publication name is used.

⸻

11. WebPKI Model Risks

11.1 CA Compromise or Mis-Issuance

A malicious or compromised CA may issue a certificate improperly.

Mitigation:
* PKIX validation
* CAA validation
* certificate transparency and related ecosystem controls where applicable
* timestamps and transparency for TEA publication history

Residual risk:
* inherent to WebPKI trust model

11.2 DNS Role in WebPKI

In WebPKI mode, DNS MUST NOT be used as a trust anchor for certificate validation.

However, DNS remains security-relevant because:
* CAA records constrain permitted CA issuance
* DNSSEC, when available, strengthens confidence in CAA

Risk:
* ignoring DNS entirely in WebPKI mode weakens mis-issuance protections

Mitigation:
* consumers SHOULD validate CAA
* higher-assurance profiles MAY require CAA enforcement

⸻

12. Failure Containment

TEA is designed so that failures remain localized.

Failure	Impact
Service compromise	No trust compromise if validation is enforced
DNS failure	Publication unavailable or trust anchor unavailable
DNSSEC failure	Loss of DNS authentication, not automatic trust collapse
Key compromise	Limited to validity window of active key
TSA failure	Time validation degraded or blocked
Transparency failure	Visibility and historical evidence reduced
Consumer parser failure	Local validation failure only

No single service failure should be sufficient to allow forged artefacts to pass full validation.

⸻

13. Residual Risks

The following risks remain:
* compromise of a short-lived key during active use
* compromise of DNS update credentials
* compromise of WebPKI or DNSSEC roots
* coordinated failure of TSA and transparency infrastructure
* malicious but authorized publisher behavior
* incorrect implementation of canonicalization or validation logic
* consumer operators selecting weak validation policy levels

These risks are considered acceptable within the architecture because successful attacks should still be limited in time, scope, or detectability.

⸻

14. Security Requirements Summary

14.1 Consumer Requirements

Consumers MUST:
* validate required signatures
* validate required timestamps
* validate certificate profile
* validate artefact-to-collection binding
* fail closed on mandatory validation errors

Consumers SHOULD:
* validate transparency proofs
* validate DNS publication where applicable
* validate CAA in WebPKI mode
* validate DNSSEC when available

14.2 Publisher Requirements

Publishers MUST:
* use short-lived keys for TEA-native signing
* ensure deterministic canonicalization
* provide timestamps
* publish TEA-native trust anchors in DNS
* keep discovery and artefact signing roles separated

Publishers SHOULD:
* provide transparency evidence
* use multiple TSAs
* publish persistence anchor locations when continuity matters
* use CAA in WebPKI mode

⸻

15. Dual-Level Signing Security Model

TEA uses a dual-level signing architecture:
* artefact-level signatures
* collection-level signatures

These serve different security purposes and MUST be evaluated separately.

15.1 Threat Separation

Artefact-level threats include:
* tampering with SBOM or attestation
* substitution of artefact content

Mitigation:
* artefact signature

Collection-level threats include:
* unauthorized grouping of artefacts
* misleading release composition
* injection of unintended artefacts

Mitigation:
* collection signature
* binding validation

15.2 Attack Scenarios

Scenario 1 — Artefact reuse attack

An attacker reuses a valid SBOM in a different release context.
* artefact signature remains valid

Mitigation:
* collection binding validation

Scenario 2 — Collection injection attack

An attacker creates a fake release referencing valid artefacts.

Mitigation:
* collection signature validation

Scenario 3 — Artefact substitution attack

An attacker replaces an artefact with a modified version.

Mitigation:
* artefact signature failure
* digest mismatch against collection

Scenario 4 — Partial validation attack

A consumer validates only one layer.

Impact:
* trust model collapses partially or completely

Mitigation:
* require artefact validation
* require collection validation
* require digest binding checks

15.3 Critical Requirement

Implementations MUST enforce:
* artefact validation
* collection validation
* binding validation

Failure to enforce all three results in incomplete trust guarantees.

15.4 Residual Risk

The dual-level model does not prevent:
* compromise of a signing key during its active validity window
* malicious publisher behavior

However, it ensures:
* tampering is detectable
* release composition is explicit
* cross-context artefact reuse cannot silently alter release meaning

15.5 Security Outcome

The dual-level model ensures:
* artefacts cannot be modified undetected
* artefacts cannot be misattributed to releases without detection
* release definitions cannot be forged without the relevant signing keys

⸻

16. Final Security Statement

TEA achieves security by:
* removing implicit trust in infrastructure
* minimizing reliance on long-lived private secrets
* requiring independent verification steps
* separating endpoint authorization from artefact trust
* combining certificate, time, DNS, and transparency into a compositional trust model

⸻

Final Conclusion

TEA does not prevent all attacks.

Instead, it is designed so that:
* compromise of infrastructure does not automatically produce trusted artefacts
* successful attacks are limited in scope or time
* forged artefacts should not pass full validation
* historical verification can survive certificate expiry and organizational change

If you want, I can next produce a tightened RFC-style “Normative Requirements Summary” document that extracts all MUST/SHOULD/MAY language from the full TEA security document set into one place.