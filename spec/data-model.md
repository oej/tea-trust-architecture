Excellent — that’s the right call. Dropping hybrid removes ambiguity and makes the model much cleaner and enforceable.

Below is the fully rewritten, copy-ready spec/data-model.md, aligned with:
* your original JSON schema
* wrapper model (collection + signature + optional evidence)
* two clear trust models only: webpki and tea-trust
* strict rule: no evidence with WebPKI
* no duplication of OpenAPI-defined collection fields
* proper normative clarity

⸻

:::writing{variant=“standard” id=“66219”}

TEA Trust Data Model

Status: Draft
Applies to: TEA Trust Architecture
Extends: Core TEA collection model (normatively defined in OpenAPI)

⸻

1. Introduction

This document defines the data model extensions introduced by the TEA Trust Architecture.

The base TEA specification defines the structure of the collection object and its fields. That structure is normatively defined in the OpenAPI specification and is not repeated here.

The TEA Trust Architecture introduces:
* a wrapper separating signed content from trust material,
* a mandatory signature object,
* an optional evidence object,
* explicit trust model semantics.

⸻

2. Trust Wrapper Model

2.1 Structure

The TEA Trust Architecture defines a top-level wrapper:

{
  "collection": { ... },
  "signature": { ... },
  "evidence": { ... }
}

2.2 Required Fields

The wrapper MUST include:
* collection
* signature

The wrapper MAY include:
* evidence

2.3 Semantics

collection

The collection object is the authoritative publisher statement.
* It is the only object that is canonicalized and signed.
* Its schema is defined in the OpenAPI specification.

signature

The signature object contains the cryptographic signature over the canonicalized collection.

evidence

The evidence object contains optional supporting validation material.

Its presence and meaning depend on the trust model.

⸻

3. Signature Model

3.1 Purpose

The signature provides:
* integrity of the collection,
* publisher authentication.

3.2 Signature Scope

The signature MUST be computed over:
* the canonicalized collection object.

The following MUST NOT be included in the signature input:
* signature
* evidence

⸻

3.3 Signature Object

The signature object includes:
* type
* algorithm
* value
* optional certificate
* optional trustModel

⸻

4. Trust Models

The TEA Trust Architecture defines two trust models:
* webpki
* tea-trust

These models determine:
* how validation is performed,
* whether evidence is allowed,
* what a conforming implementation MUST verify.

⸻

4.1 Trust Model Identification

The trust model MUST be determined as follows:
	1.	If signature.trustModel is present, it MUST be used.
	2.	Otherwise, it MUST be inferred from signature.type.

⸻

4.2 WebPKI Trust Model

Definition

The WebPKI trust model relies on:
* X.509 certificate chains,
* external trust stores,
* standard PKI validation rules.

Requirements

If:
* signature.type = "webpki"
OR
* signature.trustModel = "webpki"

then:
* the evidence object MUST NOT be present.

Validation Behavior

Validators MUST:
* validate the certificate chain according to WebPKI rules,
* validate the signature over the collection,
* NOT require or process TEA evidence.

Rationale

In this model:
* trust is derived entirely from the WebPKI,
* TEA does not provide additional trust signals.

⸻

4.3 TEA-Trust Model

Definition

The TEA-Trust model relies on:
* cryptographic signatures,
* timestamps,
* transparency receipts,
* explicit trust anchor discovery.

Requirements

If:
* signature.trustModel = "tea-trust"

then:
* the evidence object MUST be present.

Expected Evidence

The evidence object SHOULD include:
* a timestamp,
* transparency receipts,
* additional supporting evidence as applicable.

Validation Behavior

Validators MUST:
* validate the signature over the collection,
* validate timestamp(s),
* validate transparency evidence,
* resolve trust anchors via TEA trust discovery.

Rationale

This model enables:
* long-term validation,
* independence from certificate expiry,
* verifiable publication history.

⸻

5. Evidence Model

5.1 Purpose

The evidence object provides external, independently verifiable trust material.

It is only used in the TEA-Trust model.

⸻

5.2 Structure

The evidence object is a container for:
* timestamp objects,
* transparency receipts,
* DNS-related evidence,
* trust anchor preservation bindings.

⸻

5.3 Binding Model

Evidence is associated with the collection through:

Implicit Binding

Evidence objects reference:
* the collection,
* the collection digest,
* or the signing key material.

Explicit Binding (evidenceRefs)

The publisher MAY include evidenceRefs inside the signed collection.

Each reference contains:
* an evidence type,
* a SHA-256 digest of the evidence object.

This ensures:
* the referenced evidence is cryptographically bound to the signed statement,
* substitution of evidence is detectable.

⸻

6. Canonicalization

6.1 Requirement

The collection object MUST be canonicalized before signing.

6.2 Scope

Canonicalization applies only to:
* the collection object.

6.3 Determinism

Canonicalization MUST:
* produce identical byte sequences across implementations,
* use a well-defined JSON canonicalization method.

⸻

7. Immutability

7.1 Collection

After signing:
* the collection MUST NOT be modified.

7.2 Evidence
* Evidence MAY be added after signing,
* Existing evidence MUST NOT be modified or removed.

⸻

8. Validation Implications

Validation behavior is determined entirely by the trust model.

Trust Model	Signature	Evidence	Timestamp	Transparency
webpki	REQUIRED	NOT ALLOWED	NOT USED	NOT USED
tea-trust	REQUIRED	REQUIRED	REQUIRED	REQUIRED

Validators MUST enforce:
* WebPKI → reject if evidence is present
* TEA-Trust → reject if evidence is missing

⸻

9. Summary

The TEA Trust data model introduces:
* a strict separation between signed content and trust material,
* explicit trust model semantics,
* a controlled and profile-dependent use of evidence,
* and deterministic rules for validation behavior.

By separating WebPKI and TEA-Trust models, the architecture avoids ambiguity and ensures consistent validation across implementations.

⸻

:::