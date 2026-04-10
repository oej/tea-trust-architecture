Here is the fully updated, consolidated, and architecture-aligned version of:

📘 TEA Trust Architecture Design Decisions

Rationale and Architectural Tradeoffs

⸻

1. Purpose

This document explains the key design decisions in the TEA trust architecture, including:
* why specific mechanisms were chosen
* what alternatives were considered
* what tradeoffs were accepted

This document is non-normative, but authoritative for understanding the architecture and its intended security properties.

⸻

2. Design Philosophy

TEA is built on the following guiding principles:
	1.	Trust must be verifiable, not assumed
	2.	No single component should be trusted completely
	3.	Operational simplicity is a security feature
	4.	Long-term validation must not depend on long-term private key protection
	5.	Trust should survive infrastructure and organizational change

⸻

3. Separation of Discovery and Artefact Trust

Decision

Discovery authorization and artefact trust are explicitly separated.

Rationale

Discovery answers:
* “Where should I connect?”

Artefact validation answers:
* “Can I trust this data?”

These are different security questions.

Discovery is part of trust bootstrap. Artefact validation is part of trust establishment.

If these were combined, compromise of:
* hosting infrastructure
* an API endpoint
* a service provider

could incorrectly become compromise of artefact trust.

Tradeoff
* additional implementation complexity
* two separate validation paths

Rejected Alternative

A single-layer model in which the service endpoint is implicitly trusted for artefact authenticity.

Reason for Rejection

This would make infrastructure compromise equivalent to trust compromise.

⸻

4. Public Key as Identity

Decision

The public key is the identity.

Certificates are metadata wrappers, not the identity source.

Rationale

This:
* avoids dependence on CA naming semantics
* avoids dependence on certificate subject interpretation
* simplifies trust reasoning
* supports multiple representation formats over time

Tradeoff
* requires explicit trust anchor handling
* requires explicit identity derivation rules

Rejected Alternative

Identity derived from:
* certificate subject
* issuer hierarchy
* CA semantics

Reason for Rejection

These approaches mix human-readable naming with cryptographic trust and create ambiguity.

⸻

5. Fingerprint-Derived SAN Names

Decision

For TEA-native, certificate SAN DNS names include the SHA-256 fingerprint of the public key.

Required form:

<fingerprint>.<trust-domain>

Optional persistence form:

<fingerprint>.<persistence-domain>

Rationale

This provides:
* deterministic identity binding
* a direct relationship between key and publication name
* simple consumer verification
* reduced ambiguity in DNS publication

The DNS name is not an independent identity. It is a structured expression of the key identity.

Tradeoff
* less human-friendly names
* requires fingerprint recomputation during validation

Rejected Alternative

Arbitrary SAN names chosen independently of key material.

Reason for Rejection

That would reintroduce ambiguity and weaken the binding between key and DNS publication.

⸻

6. Use of X.509 as Wrapper

Decision

X.509 is used as a widely supported wrapper format, not as the primary identity model.

Rationale

X.509 provides:
* widespread tooling support
* a defined validity interval
* standardized transport and encoding
* compatibility with timestamp and transparency workflows

Tradeoff
* inherits some PKI-related complexity
* requires careful clarification that subject naming is not the identity source

Rejected Alternative

Raw public keys only.

Reason for Rejection

Raw keys do not provide:
* validity metadata
* a widely interoperable transport object
* a convenient container for accountability metadata

⸻

7. Subject Naming and Accountability

Decision

Certificate subject fields are used for accountability metadata, not for trust identity.

Rationale

This separates:
* cryptographic identity → public key fingerprint
* legal accountability → subject O
* user-facing naming → discovery publisher metadata

This reduces trust confusion while still supporting:
* auditability
* regulatory context
* legal traceability

Specific Rule

If a legal entity exists:
* subject O is required to contain the legal name of that entity

If no registered legal entity exists:
* a stable known name may be used

Tradeoff
* consumers must distinguish between trust identity and human-readable naming
* implementations must not misuse subject names for trust decisions

Rejected Alternative

Using subject O or CN as the trust identity.

Reason for Rejection

This would create name-based trust ambiguity and make validation more brittle.

⸻

8. Ephemeral Keys Instead of Long-Term Key Protection

Decision

TEA-native uses ephemeral or very short-lived private keys instead of long-lived signing keys.

Rationale

This eliminates the need to protect a private key for longer than the signing process and certificate validity window.

This is one of the core advantages of the architecture.

Benefits include:
* reduced attack window
* no long-term signing key storage requirement
* no HSM dependency for basic deployments
* no revocation dependency in normal operation
* simpler CI/CD integration

Tradeoff
* more frequent key generation
* greater reliance on timestamps and transparency for long-term verification

Rejected Alternative

Long-lived signing keys protected via traditional PKI controls.

Reason for Rejection

Long-lived keys are:
* high-value targets
* operationally difficult to protect
* costly for smaller organizations
* a major source of persistent compromise risk

⸻

9. Short-Lived Certificates Instead of Revocation

Decision

Use short-lived signing certificates instead of CRL- or OCSP-based revocation as the primary lifecycle control.

Rationale

Revocation systems are:
* operationally complex
* frequently unreliable
* difficult to enforce at Internet scale
* often ignored or inconsistently implemented

Short-lived certificates reduce the need for revocation by constraining exposure in time.

Tradeoff
* requires issuers to generate certificates frequently
* requires timestamps to support validation after expiry

Rejected Alternative

Revocation-centric trust lifecycle using CRL or OCSP.

Reason for Rejection

This creates complexity without sufficiently improving reliability.

⸻

10. DNS Publication for TEA-Native Trust Anchors

Decision

TEA-native trust anchors are required to be published in DNS using CERT records.

Rationale

DNS provides:
* a globally resolvable publication channel
* stable, domain-associated trust anchor locations
* a natural binding to manufacturer-controlled namespaces
* support for continuity through persistence domains

Tradeoff
* introduces DNS availability dependency
* requires explicit consumer handling of authenticated vs unauthenticated DNS

Rejected Alternative

No DNS publication at all.

Reason for Rejection

That would remove a common publication and discovery mechanism for trust anchors and weaken interoperability.

⸻

11. DNSSEC as Optional Strengthening, Not a Hard Requirement

Decision

DNSSEC is optional.

DNS publication is required for TEA-native, but DNSSEC protection is not mandatory.

Rationale

DNSSEC provides authenticated distribution when available, but mandatory DNSSEC would exclude valid deployment scenarios and create adoption barriers.

This design allows:
* broad deployability
* policy-based strengthening where DNSSEC is available
* use of DNS as publication even where DNSSEC is absent

Tradeoff
* when DNSSEC is absent, DNS is publication only, not authenticated publication
* consumers need policy-aware handling of unauthenticated DNS

Rejected Alternative

Mandatory DNSSEC for all TEA-native deployments.

Reason for Rejection

That would increase deployment friction and unnecessarily block otherwise valid trust models.

⸻

12. Persistence Publication for Continuity

Decision

An optional second SAN and DNS publication point may be used for persistence under an independent third-party domain.

Rationale

This supports continuity across:
* bankruptcy
* acquisition
* organizational shutdown
* loss of control over the original domain

It is a direct response to long-term validation and CRA-style retention requirements.

Tradeoff
* introduces additional publication coordination
* creates another externally operated dependency

Rejected Alternative

Single-domain dependence on the original manufacturer namespace only.

Reason for Rejection

That creates avoidable fragility in long-term verification.

⸻

13. Canonical JSON (RFC 8785)

Decision

Use RFC 8785 JSON Canonicalization Scheme where JSON canonicalization is required.

Rationale

This provides:
* deterministic signing input
* interoperability across implementations
* reduced ambiguity in validation

Tradeoff
* requires strict implementation
* structured formats must clearly define when canonicalization applies

Rejected Alternative

Ad hoc or implementation-specific JSON serialization.

Reason for Rejection

This causes signature failures and inconsistent validation.

⸻

14. Support for Detached and Inline Signatures

Decision

Support both:
* detached signatures
* inline signatures

Rationale

Detached signatures are:
* simple
* format-agnostic
* well-suited for binary artefacts

Inline signatures are:
* useful for structured formats such as CycloneDX
* convenient for self-contained artefacts

Tradeoff
* consumers must support two validation patterns
* structured formats need canonicalization discipline

Rejected Alternative

Supporting only one signature style.

Reason for Rejection

That would unnecessarily reduce interoperability and deployment flexibility.

⸻

15. Transparency Logs as a Required Security Function

Decision

Transparency is provided by a transparency log, such as:
* Sigsum
* an IETF SCITT-based system

Rationale

Transparency logs provide:
* external publication evidence
* tamper detection
* auditability
* support for long-term validation

Tradeoff
* reliance on external services or ecosystems
* added operational and validation complexity

Rejected Alternative

No transparency layer.

Reason for Rejection

Without transparency, malicious or silent post-publication changes become much harder to detect.

⸻

16. Timestamping as a Mandatory Trust Anchor

Decision

Timestamps from a TSA are mandatory trust anchors for both discovery and artefact signing.

Rationale

Timestamps provide:
* signing-time evidence
* protection against backdating
* ordering of events
* support for long-term validation after short-lived certificate expiry

A valid timestamp proves that a signature existed at a time when the certificate was valid.

Tradeoff
* introduces dependence on TSA services and trust configuration
* requires validation of timestamp tokens and TSA certificate chains

Additional Decision

Use multiple TSAs or multiple time sources where feasible.

Rationale

This reduces risk from:
* a dishonest TSA
* clock drift
* TSA outage
* single-service dependency

Rejected Alternative

No timestamping, or timestamping treated as optional.

Reason for Rejection

That would weaken long-term validation and make short-lived signer certificates much less useful.

⸻

17. Long-Term Validation Through TSA and CA Lifetimes

Decision

Long-term validation is based on preserving timestamp evidence and the trust chains needed to validate it.

Rationale

A key architectural benefit is that private keys only need to exist briefly, while verification can remain possible for much longer.

This is possible because:
* signing keys are short-lived
* signing certificates are short-lived
* timestamp tokens remain verifiable over long periods
* TSA and CA certificate chains typically live much longer

Tradeoff
* archival evidence must be retained carefully
* long-term validation depends on preserving timestamp and trust-chain material

Rejected Alternative

Making long-term validation depend on the continued validity of the original signing certificate alone.

Reason for Rejection

That would defeat the purpose of short-lived certificates and ephemeral keys.

⸻

18. Separation of Discovery and Artefact Timestamping Roles

Decision

Discovery and artefact signing both require timestamps, but for different reasons.

Rationale

Discovery timestamps:
* protect trust bootstrap from replay and stale authorization

Artefact timestamps:
* support long-term validation and signing-time proof

This separation preserves clarity while using a common temporal trust mechanism.

Tradeoff
* more validation steps for consumers
* more evidence to retain

⸻

19. No Mandatory Central Trust Authority

Decision

No central trust registry or mandatory global authority is required.

Rationale

This:
* avoids a single point of failure
* preserves decentralization
* supports independent deployment
* avoids ecosystem-wide lock-in

Tradeoff
* trust resolution must be explicit
* consumers must handle multiple trust models and evidence sources

Rejected Alternative

A mandatory central trust registry for TEA publishers.

Reason for Rejection

This would contradict decentralization goals and create concentration risk.

⸻

20. Support for Multiple Trust Models, But Only Where Necessary

Decision

Support:
* TEA-native (TAPS)
* WebPKI

Do not support a TEA-native two-layer CA hierarchy.

Rationale

These two models cover the needed deployment spectrum:
* TEA-native for compositional, DNS-published, ephemeral trust
* WebPKI for environments that must integrate with existing CA ecosystems

Removing TEA-native two-layer keeps the architecture aligned with:
* ephemeral keys
* operational simplicity
* avoidance of long-lived private key protection

Tradeoff
* fewer migration patterns for organizations wanting internal CA hierarchies
* some enterprises may need separate operational adaptation

Rejected Alternative

TEA-native two-layer model with long-lived CA and short-lived leaf certificates.

Reason for Rejection

That reintroduces long-lived key protection and PKI complexity that the architecture intentionally avoids.

⸻

21. WebPKI as a Separate Trust Model

Decision

WebPKI remains separate from TEA-native.

Rationale

WebPKI already has:
* a different trust anchor model
* different certificate semantics
* different issuance processes

Mixing WebPKI and TEA-native semantics would create ambiguity.

Tradeoff
* consumers must implement separate validation paths
* producers must declare trust model clearly

Rejected Alternative

Attempting to infer trust model from certificate contents alone.

Reason for Rejection

This is brittle and unsafe, especially when different models may use similar certificate structures.

⸻

22. DNS in WebPKI Is Policy, Not Trust Anchoring

Decision

In WebPKI mode, DNS is not used as a trust anchor, but remains relevant for policy via CAA.

Rationale

CAA records:
* constrain permitted certificate issuance
* reduce mis-issuance risk
* strengthen WebPKI validation when present
* become stronger still when protected by DNSSEC

This preserves the contextual value of DNS without confusing it with TEA-native anchor publication.

Tradeoff
* additional DNS checks in WebPKI mode
* policy complexity for consumers and publishers

Rejected Alternative

Ignoring DNS entirely in WebPKI mode.

Reason for Rejection

That would miss an important policy control and weaken issuer constraint.

⸻

23. Service Provider Independence

Decision

TEA services may be hosted by third parties, but service providers are not trust anchors.

Rationale

This allows:
* scalable deployment
* outsourcing of API operation
* operational flexibility

without requiring consumers to trust the service operator itself.

Tradeoff
* requires strict separation between transport, hosting, and artefact trust
* requires discovery authorization and artefact validation to remain independent

Key Rule

Service providers MUST NOT be treated as trust anchors solely because they host TEA content.

⸻

24. Dual-Level Signing Model

Decision

TEA requires independent validation of:
* artefact-level signatures
* collection-level signatures
* binding between artefacts and collection

Rationale

These layers answer different questions:

Artefact signature:
* “Is this artefact authentic?”

Collection signature:
* “Is this artefact included in this release?”

Binding validation:
* “Does the referenced artefact actually match what the collection declares?”

This prevents:
* artefact reuse in unintended contexts
* release forgery using valid standalone artefacts
* ambiguity about release composition

Tradeoff
* more validation work for consumers
* more evidence and logic to implement correctly

Rejected Alternative

Single-signature release model.

Reason for Rejection

A single signature cannot safely express both artefact authenticity and release inclusion semantics.

⸻

25. Discovery Signing Is Mandatory in Practice

Decision

Discovery signing is required in practice because it forms part of trust bootstrap.

Rationale

Unsigned or unstably authorized discovery introduces a weak point at the start of validation.

Signed and timestamped discovery provides:
* endpoint authorization
* replay resistance
* better separation between service location and service trust

Tradeoff
* extra implementation work for publishers
* more validation logic for consumers

Rejected Alternative

Optional unsigned discovery for small deployments.

Reason for Rejection

That weakens endpoint authorization and creates inconsistent security behavior.

⸻

26. Time Validation Strategy

Decision

Use periodic health checks and bounded-drift validation rather than assuming perfect time.

Rationale

The architecture depends on trustworthy ordering and bounded time correctness, not exact perfect time.

This reduces sensitivity to:
* local clock drift
* TSA drift
* short-term operational anomalies

Tradeoff
* requires policy thresholds
* requires periodic monitoring of time sources

Rejected Alternative

Assuming exact global time proof is available and necessary.

Reason for Rejection

This is infeasible and unnecessary for the security goals.

⸻

27. Avoidance of GPG

Decision

GPG is not used in TEA.

Rationale

GPG is a poor fit for:
* modern automated CI/CD workflows
* deterministic machine validation
* clear and narrowly scoped trust models

Tradeoff
* some existing user familiarity is not reused

Rejected Alternative

Using OpenPGP/GPG as the signing and trust foundation.

Reason for Rejection

The OpenPGP trust model is too complex and poorly aligned with the architecture’s goals.

⸻

28. Support for Future Wrappers

Decision

The architecture is designed so that future wrapper formats may be introduced, including:
* COSE
* CBOR
* JSON-based wrappers

Rationale

The core identity and trust model is not tied to one wrapper syntax.

This supports:
* future-proofing
* protocol evolution
* compatibility with emerging ecosystems such as SCITT

Tradeoff
* requires clear separation between trust semantics and serialization format

⸻

29. Operational Simplicity as a Security Property

Decision

Favor simple operational models where possible.

Rationale

Small and medium-sized organizations often lack:
* dedicated PKI expertise
* HSM operations teams
* mature revocation infrastructure
* specialized compliance staff

Simpler systems are more likely to be implemented correctly.

Tradeoff
* some advanced PKI features are intentionally omitted
* some edge-case flexibility is sacrificed

Rejected Alternative

A feature-rich but operationally heavy design optimized for large PKI operators.

Reason for Rejection

That would reduce deployability and increase misconfiguration risk.

⸻

30. CRA Alignment Philosophy

Decision

Design for lifecycle security and long-term verifiability, not checklist compliance.

Rationale

CRA-style requirements emphasize:
* durable evidence
* accountability
* long-term retention
* verifiability over time

The TEA trust architecture is therefore designed to support continuous validation rather than one-time publication.

Tradeoff
* more evidence objects must be generated and preserved
* validation becomes an ongoing process rather than a one-time event

⸻

31. Final Design Summary

The TEA trust architecture intentionally:
* minimizes long-lived secrets
* separates trust concerns
* makes public key identity explicit
* binds TEA-native identity to fingerprint-derived SAN names
* uses DNS for TEA-native trust anchor publication
* allows DNSSEC to strengthen, but not define, the baseline model
* uses DNS in WebPKI as policy support via CAA
* requires timestamps as independent trust anchors
* requires compatibility with transparency logs
* supports independent verification and long-term validation
* supports continuity across DNS and organizational change
* supports multiple operational models without mixing their trust semantics

⸻

Final Statement

The TEA trust architecture is designed so that:

trust does not depend on who operates the system, but on what can be verified independently over time.
