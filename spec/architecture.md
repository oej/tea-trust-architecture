Got it — thank you, that clarifies the intent precisely.

This document is not about TEA as a general exchange model, but specifically the TEA Trust Architecture: the overlay that introduces verifiable trust, long-term validation, and evidence binding.

Below is a fully rewritten, copy-ready spec/architecture.md focused strictly on the TEA Trust Architecture.

⸻

:::writing{variant=“standard” id=“77294”}

TEA Trust Architecture

Status: Draft
Applies to: TEA Trusted Architecture Profile
Extends: Core TEA data model and exchange model

⸻

1. Introduction

This document defines the TEA Trust Architecture, an overlay on the base TEA model that introduces a verifiable, evidence-based trust system.

The base TEA model defines how collections are structured and exchanged. It does not, by itself, guarantee:
* authenticity of the publisher,
* integrity over time,
* verifiable time of publication,
* or resistance to retroactive manipulation.

The TEA Trust Architecture addresses these gaps by introducing:
* cryptographic signatures,
* trusted timestamps,
* transparency log inclusion proofs,
* and explicit trust anchor discovery.

The result is a system where trust is derived from verifiable evidence, not implicit assumptions about infrastructure.

⸻

2. Architectural Goals

The TEA Trust Architecture is designed to satisfy the following goals:

2.1 Verifiable Authenticity

Consumers MUST be able to verify that a collection originates from a specific publisher.

2.2 Integrity Over Time

Collections MUST remain verifiable after:
* certificate expiration,
* key rotation,
* infrastructure changes.

2.3 Proof of Existence in Time

It MUST be possible to prove that a collection existed at or before a given point in time.

2.4 Public Verifiability

Consumers SHOULD be able to verify that a collection was published in a publicly auditable system.

2.5 Independence of Trust Components

The architecture SHOULD avoid reliance on a single trust provider by separating:
* signing authority,
* time authority,
* transparency infrastructure.

⸻

3. Trust Model Overview

The TEA Trust Architecture is composed of four independent but complementary layers:

Layer	Purpose
Signature	Integrity and publisher identity
Timestamp	Time anchoring
Transparency	Public auditability
Trust Discovery	Resolution of trust anchors

No single layer is sufficient on its own. Trust is established through the combination of all layers.

⸻

4. Architectural Components

The TEA Trust Architecture introduces the following components.

⸻

4.1 Signed Collection

A signed collection is a TEA collection that includes one or more cryptographic signatures.

Properties
* Signatures MUST cover the entire collection excluding the evidence field
* Multiple signatures MAY be present
* Signatures MAY represent different trust domains

⸻

4.2 Evidence

Evidence binds the collection to external trust systems.

Evidence Types
* Timestamp (time authority)
* Transparency proof (public log)

Properties
* Evidence MUST be append-only
* Evidence MUST be independently verifiable
* Evidence MUST reference the signed collection

⸻

4.3 Trust Anchors

Trust anchors provide the root of trust for signature validation.

Properties
* Trust anchors MUST be discoverable independently of the collection
* Trust anchors MAY be:
* X.509 certificates
* Raw public keys

⸻

4.4 External Trust Services

The architecture depends on external services:

Time Stamping Authority (TSA)
* Provides cryptographic timestamps
* MUST be independently verifiable

Transparency Log
* Provides append-only publication records
* MUST support inclusion proofs

⸻

5. Trust Relationships

The TEA Trust Architecture explicitly separates trust domains.

⸻

5.1 Publisher Trust

Consumers establish trust in the publisher via:
* trust anchors,
* signature validation.

⸻

5.2 Time Trust

Consumers establish trust in timestamps via:
* TSA trust anchors,
* verification of timestamp tokens.

⸻

5.3 Transparency Trust

Consumers establish trust in transparency logs via:
* log public keys,
* inclusion proofs.

⸻

5.4 Independence Requirement

Implementations SHOULD ensure that:
* TSA trust anchors are not identical to publisher trust anchors,
* transparency logs are operated independently of publishers where possible.

⸻

6. Data Binding Model

The trust architecture defines how data is cryptographically bound.

⸻

6.1 Signature Binding

The signature binds:
* all collection fields except evidence

This ensures:
* integrity of content,
* immutability of the collection after signing.

⸻

6.2 Timestamp Binding

The timestamp binds:
* the hash of the signed collection

This ensures:
* the collection existed at or before the timestamp.

⸻

6.3 Transparency Binding

The transparency log binds:
* either the collection or its hash

This ensures:
* the collection was externally recorded.

⸻

6.4 Combined Binding

Together, these bindings ensure:
* the collection was created by a known entity,
* it existed at a provable time,
* it was publicly recorded,
* and it has not been modified since.

⸻

7. Lifecycle in the Trust Architecture

The TEA Trust Architecture extends the base collection lifecycle.

⸻

7.1 Finalization

A collection becomes finalized when:
* it is signed,
* its content becomes immutable.

⸻

7.2 Evidence Attachment

After finalization, the publisher:
* obtains timestamp(s),
* obtains transparency proof(s),
* attaches evidence to the collection.

⸻

7.3 Publication

A collection is considered trusted-published when:
* it includes required evidence,
* it is made available to consumers.

⸻

8. Time Model

The TEA Trust Architecture does not assume perfect global time.

Instead, it relies on:
* trusted timestamps,
* consistency between independent time sources.

⸻

8.1 Time Anchoring

A timestamp provides:
* a cryptographic assertion that the collection existed before a given time.

⸻

8.2 Time Health Validation

Implementations SHOULD:
* periodically compare multiple time sources,
* detect unacceptable drift.

If time sources diverge beyond acceptable limits:
* validation SHOULD fail or require additional verification.

⸻

8.3 Event Ordering

The architecture prioritizes:

Correct ordering of events over exact absolute time.

⸻

9. Key Management Model

⸻

9.1 Short-Lived Signing Keys

Signing keys SHOULD be:
* short-lived,
* frequently rotated.

⸻

9.2 Trust Anchors

Trust anchors:
* MAY be longer-lived,
* MUST be replaceable.

⸻

9.3 Dual Anchor Strategy

Publishers SHOULD:
* maintain at least two active trust anchors,
* enable controlled rollover.

⸻

10. Threat Model

The TEA Trust Architecture is designed to mitigate the following threats.

⸻

10.1 Data Tampering

Mitigation:
* cryptographic signatures.

⸻

10.2 Backdating

Mitigation:
* trusted timestamps,
* transparency logs.

⸻

10.3 Key Compromise

Mitigation:
* short-lived keys,
* transparency visibility,
* anchor rotation.

⸻

10.4 Hidden Publication

Mitigation:
* transparency logs.

⸻

10.5 Time Manipulation

Mitigation:
* multiple time sources,
* time health validation.

⸻

11. Relationship to TEA Base Model

The TEA Trust Architecture is an overlay.

⸻

11.1 Optional in Base TEA

In the base TEA model:
* signatures MAY be absent,
* evidence MAY be absent.

⸻

11.2 Mandatory in Trusted Profile

In the TEA Trust Architecture:
* signatures are REQUIRED,
* timestamps are REQUIRED,
* transparency proofs are RECOMMENDED,
* trust anchor discovery is REQUIRED.

⸻

12. Architectural Constraints

Implementations conforming to the TEA Trust Architecture:

MUST
* treat finalized collections as immutable,
* treat evidence as append-only,
* validate all trust layers.

MUST NOT
* rely solely on certificate validity,
* modify signed data,
* remove evidence once attached.

⸻

13. Summary

The TEA Trust Architecture establishes a system where:
* identity is provided by signatures,
* time is anchored by timestamps,
* publication is proven by transparency,
* trust is rooted in independently discoverable anchors.

Together, these mechanisms enable durable, verifiable trust in software metadata over long time horizons, independent of any single infrastructure or authority.

⸻

:::