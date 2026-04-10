# TEA Conformance and Validation Specification

Version: 1.0
Status: Draft
Applies to: TEI, Discovery, TEA APIs, Trust Architecture

## Status

This document is normative.

It defines conformance requirements and validation behavior
across all components of the TEA architecture, including:

- TEI
- Discovery
- TEA APIs
- Trust Architecture

All conforming TEA implementations MUST satisfy the requirements
defined in this specification according to their declared profile.
⸻

1. Introduction

The Transparency Exchange API (TEA) defines a modular architecture for software transparency consisting of:
	•	TEI for identification
	•	Discovery for service location
	•	TEA APIs for artefact access
	•	Trust Architecture for validation

This document defines how these components are used together in practice.

Specifically, it provides:
	•	Conformance requirements for producers and consumers
	•	Validation behavior across the TEA lifecycle
	•	Minimum acceptable security and trust handling

The goal is to ensure that independent implementations behave consistently and can interoperate reliably.

⸻

2. Scope and Relationships

This specification builds on, but does not replace:

Area	Specification
Identifier	spec/tei.md
Discovery	spec/discovery/readme.md
APIs	spec/publisher/ and spec/consumer/
Trust	spec/trust-architecture.md

This document defines how these specifications are applied together, not their internal structure.

⸻

3. Conformance Roles

3.1 Producer

A TEA Producer:
	•	assigns TEIs
	•	publishes discovery documents
	•	exposes TEA endpoints
	•	provides artefacts

⸻

3.2 Consumer

A TEA Consumer:
	•	accepts TEIs
	•	performs discovery
	•	retrieves artefacts

⸻

3.3 Trust-Aware Consumer

A Trust-Aware Consumer additionally:
	•	validates signatures
	•	validates timestamps
	•	verifies transparency evidence
	•	resolves DNS trust anchors (TAPS)

⸻

4. Conformance Profiles

TEA defines three conformance profiles to support incremental adoption.

⸻

4.1 Profile L1 — Basic Interoperability

A conforming implementation:
	•	MUST accept syntactically valid TEIs
	•	MUST treat TEIs as opaque identifiers
	•	MUST perform discovery via .well-known/tea
	•	MUST select at least one valid endpoint
	•	MUST retrieve artefacts

This profile ensures basic interoperability.

⸻

4.2 Profile L2 — Secure Retrieval

In addition to L1:
	•	MUST use HTTPS for all communications
	•	MUST validate TLS using WebPKI
	•	MUST process discovery documents according to schema
	•	SHOULD support multiple endpoints and selection logic

This profile ensures secure transport and structured interaction.

⸻

4.3 Profile L3 — Trust-Aware Validation

In addition to L2:
	•	MUST validate artefact signatures
	•	MUST validate timestamps
	•	MUST validate trust anchors (TAPS) when applicable
	•	MUST process transparency evidence when present
	•	MUST fail closed on validation errors

This profile aligns with CRA-grade validation expectations.

⸻

5. TEI Handling Requirements

Consumers:
	•	MUST treat TEIs as opaque
	•	MUST NOT parse <encoded-id>
	•	MUST NOT depend on <type> semantics
	•	MUST NOT reject TEIs due to unknown <type>

Consumers MAY:
	•	decode identifiers for display
	•	interpret known types for enrichment

Such behavior MUST remain optional.

⸻

6. Discovery Processing

6.1 Retrieval

Consumers:
	•	MUST retrieve https://<authority>/.well-known/tea
	•	MUST use HTTPS
	•	MUST validate TLS

⸻

6.2 Interpretation

Consumers:
	•	MUST process required fields
	•	MUST ignore unknown fields
	•	MUST support schema evolution

⸻

6.3 Failure Handling

If discovery fails:
	•	MUST retry (configurable)
	•	MAY use cached discovery data
	•	MUST NOT assume success

⸻

7. Endpoint Selection

When multiple endpoints are present:

Consumers:
	•	MUST filter endpoints by supported trust model
	•	MUST evaluate both global and per-endpoint trustModelsSupported
	•	SHOULD consider priority
	•	MUST allow local policy override

Consumers MUST NOT assume:
	•	all endpoints are equivalent
	•	all endpoints support all trust models

⸻

8. Trust Model Selection

Consumers MUST select a trust model based on:
	•	local policy
	•	discovery document
	•	endpoint capabilities

If multiple models are available:
	•	SHOULD prefer stronger models (e.g., TAPS)
	•	MUST allow local override

⸻

9. Artefact Retrieval

Consumers:
	•	MUST use the selected endpoint
	•	MUST use HTTPS
	•	MUST validate TLS

⸻

10. Trust Validation

10.1 General

If trust validation is enabled:
	•	MUST be applied consistently
	•	MUST produce a clear validation outcome

⸻

10.2 WebPKI Model

Consumers:
	•	MUST validate TLS chain
	•	MUST NOT expect additional evidence

⸻

10.3 TAPS Model

Consumers:
	•	MUST resolve trust anchors via DNS
	•	MUST validate signatures
	•	MUST validate timestamps
	•	MUST verify transparency inclusion

⸻

11. Validation Outcomes

Validation MUST produce one of:

Outcome	Meaning
VALID	All required checks passed
INVALID	A required check failed
INDETERMINATE	Validation could not be completed


⸻

11.1 Required Behavior
	•	L3 consumers MUST fail closed on INVALID
	•	MAY allow INDETERMINATE based on policy
	•	MUST log outcomes

⸻

12. Error Handling

Consumers MUST define behavior for:
	•	discovery failure
	•	endpoint unavailability
	•	signature failure
	•	timestamp inconsistency
	•	trust anchor mismatch

⸻

13. Logging and Auditability

Consumers SHOULD log:
	•	TEI processed
	•	discovery result
	•	endpoint selected
	•	trust model selected
	•	validation outcome

This supports:
	•	compliance verification
	•	incident analysis
	•	long-term audit

⸻

14. Security Considerations

This specification enforces:
	•	HTTPS-only communication
	•	TLS validation
	•	separation of transport and artefact trust
	•	optional DNSSEC protection

⸻

15. CRA Alignment

Profile L3 supports:
	•	pre-purchase transparency
	•	long-term validation
	•	lifecycle traceability

⸻

16. Conformance Summary

Profile	Capability
L1	TEI resolution and artefact retrieval
L2	Secure communication and structured discovery
L3	Full trust validation and auditability


⸻

17. Implementation Guidance

Implementations SHOULD:
	•	adopt L2 as a baseline
	•	adopt L3 for regulated environments
	•	support gradual upgrade paths

⸻

✅ Result

This document now:
	•	Fits cleanly into your existing TEA doc bundle
	•	Uses the same tone and layering model
	•	Connects all components without redefining them
	•	Provides a normative behavioral contract

⸻

🚀 Optional Next Step

If you want to go one level further toward standardization:

👉 Add:

spec/conformance/test-suite.md

Containing:
	•	concrete TEIs
	•	sample discovery docs
	•	expected validation outcomes

That would make TEA:

not just a spec — but a verifiable ecosystem

⸻

If you want, I can generate that test suite next.