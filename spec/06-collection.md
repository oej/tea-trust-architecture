# 📘 TEA Signature Model: Collections and Artefacts

---

## 1. Introduction

This document defines the semantics, purpose, and validation rules for signatures used in the Transparency Exchange API (TEA).

TEA distinguishes between two fundamentally different types of signatures:

- collection signatures, which are statements by the publisher about a release  
- artefact signatures, which are statements about individual artefact authenticity  

These signatures serve different roles and MUST NOT be conflated.

This document defines:

- what each signature type means  
- how they interact  
- how consumers MUST validate them  
- how to interpret trust conclusions  
- how signatures relate to certificates, timestamps, DNS publication, and transparency evidence  

---

## 2. Core Principles

### 2.1 Separation of Concerns

TEA separates:

- integrity of artefacts  
- publisher assertions about releases  
- binding between artefacts and releases  

These are implemented as:

- artefact signature → authenticity of artefact  
- collection signature → authenticity of publisher statement about the release  
- checksums in the collection → binding of artefact bytes to that signed statement  

---

### 2.2 Signed Collection as Integrity Map

A TEA collection is not merely metadata.

A signed collection is a publisher-authenticated integrity map of artefacts because it contains:

- references to artefacts  
- checksums of artefacts  
- release context  
- versioning metadata  

and the entire structure is signed.

---

### 2.3 Many-to-Many Relationships

TEA explicitly supports:

- one artefact appearing in multiple collections  
- multiple collections for one software version  
- collection updates that do not change artefact bytes  

Consumers MUST NOT assume uniqueness of either artefacts or collections.

---

### 2.4 Dual-Level Trust Model

TEA trust for release data is intentionally dual-layered:

- artefact-level signatures establish artefact authenticity  
- collection-level signatures establish release inclusion and publisher approval  

Both layers are important, but they answer different questions.

---

## 3. Collection Signatures

### 3.1 Meaning

A collection signature asserts:

> “This collection version, including its artefact checksums and metadata, is approved by the publisher.”

It guarantees:

- authenticity of the collection  
- integrity of all checksums within it  
- integrity of release metadata  
- authenticity of the publisher statement that these artefacts belong to this collection version  

---

### 3.2 What a Collection Signature Does Not Guarantee

A collection signature does not guarantee:

- that each artefact is intrinsically authentic on its own  
- that each artefact is separately signed  
- that this is the only collection for a release  
- that no later collection version exists  

---

### 3.3 Binding via Checksums

The collection includes checksums for artefacts.

Because the collection is signed, those checksums are part of the signed publisher statement.

This creates the binding:

> “These exact bytes belong to this collection version.”

---

### 3.4 Collection Versioning

A collection version may change without changing artefact bytes.

Examples include:

- VEX updates  
- metadata corrections  
- descriptive changes  
- additional references  
- updated evidence  

Therefore:

- collection version is not equivalent to software version  
- a collection update does not necessarily imply a software update  

---

### 3.5 Collection Signature as Release Approval

The collection signature is the publisher’s approval of release composition.

In operational terms, this is the main release-level trust statement in TEA.

---

## 4. Artefact Signatures

### 4.1 Meaning

An artefact signature asserts:

> “This artefact was produced and signed by the holder of this key.”

It provides:

- authenticity of the artefact  
- integrity of the artefact  

---

### 4.2 Optional in Core TEA, Recommended for Assurance

Artefact signatures are:

- optional in core TEA  
- recommended for stronger assurance  
- required by stricter validation profiles or deployment policy  

This means TEA can still bind an unsigned artefact to a release via signed collection checksums, but independent artefact authenticity is only established when an artefact signature is present and valid.

---

### 4.3 Signature Forms

Artefact signatures may be:

- detached  
- inline  

Example: CycloneDX JSON with embedded signature.

---

### 4.4 Independence from Collection

Artefact signatures are independent of collections.

This means:

- artefacts can be reused across releases  
- artefacts remain verifiable outside TEA  
- authenticity can be validated independently  

---

### 4.5 What an Artefact Signature Does Not Guarantee

An artefact signature does not guarantee:

- that the artefact belongs to a given TEA release  
- that the artefact matches a specific collection version  
- that the artefact was approved for release  

Those guarantees come from the collection signature and checksum binding.

---

## 5. Combined Trust Model

### 5.1 Three Core Validation Elements

TEA establishes trust using:

1. collection signature  
2. checksums inside the collection  
3. artefact signature (when present)  

---

### 5.2 Trust Statements

With collection only:

> “This exact file is part of this signed collection version.”

With collection + artefact signature:

> “This exact file is part of this signed collection version, and the artefact itself is authentic.”

---

### 5.3 Full Trust Interpretation

High-assurance interpretation:

- artefact is authentic  
- artefact matches collection checksum  
- publisher approved inclusion  
- time and publication evidence are valid  

---

## 6. Signature Inputs and Canonicalization

### 6.1 Deterministic Signing Requirement

Signatures require consistent byte representation.

---

### 6.2 JSON Canonicalization

RFC 8785 (JCS) SHOULD be used when applicable.

Signer MUST define:

- raw bytes OR  
- canonical JSON  

Consumers MUST match.

---

### 6.3 Raw Byte Signing

Exact bytes MUST match during verification.

---

### 6.4 Inline Signature Canonicalization

Format-specific canonicalization rules MUST be followed.

---

### 6.5 Detached Signature Handling

Detached signatures MUST be validated against:

- exact bytes OR  
- defined canonical form  

---

## 7. Signature Algorithms

### 7.1 TEA-Native

- Ed25519 REQUIRED  

---

### 7.2 WebPKI

- algorithms follow PKIX rules  

---

### 7.3 Future Formats

Signature semantics are independent of encoding/wrapper formats.

---

## 8. Consumer Validation Rules

### 8.1 Required Collection Validation

Consumer MUST:

1. validate collection signature  
2. validate collection timestamp  
3. validate transparency evidence (per trust model/profile)  
4. extract checksums  
5. compute artefact digests  
6. compare digests  

---

### 8.2 Artefact Signature Handling

If present:

- detect type (inline/detached)  
- validate accordingly  

---

### 8.3 Artefact Signature Policy

If required:

- missing → fail  
- invalid → fail  

If optional:

- collection binding MAY suffice  

---

### 8.4 TEA-Native Trust Anchor Validation

Consumer MUST:

- validate certificate profile  
- compute SHA-256(public key)  
- verify SAN fingerprint match  
- verify certificate matches DNS CERT record  
- validate DNSSEC when required  

---

### 8.5 WebPKI Validation

Consumer MUST:

- validate PKIX chain  

Consumer MUST NOT:

- use DNS CERT as trust anchor  

Consumer SHOULD:

- validate CAA records  

---

### 8.6 Failure Conditions

Validation MUST fail if:

- collection signature invalid  
- timestamp invalid  
- checksum mismatch  
- required artefact signature invalid  
- trust anchor validation fails  

---

## 9. Validation Profiles

### 9.1 Minimal Profile

- collection signature  
- timestamp  
- checksum binding  

⚠️ Not sufficient for full TEA-native validation unless transparency and DNS validation are also satisfied.

---

### 9.2 Recommended Profile

- collection signature  
- timestamp  
- checksum binding  
- artefact signature (if present)  
- transparency validation  
- trust anchor validation  

---

### 9.3 High-Assurance Profile

- collection signature  
- timestamp  
- checksum binding  
- artefact signature REQUIRED  
- artefact timestamp  
- transparency REQUIRED  
- evidence retention  

---

## 10. Signatures, Time, Transparency, and DNS

### 10.1 Multi-Anchor Trust Context

Trust derives from:

- certificate  
- timestamp  
- DNS  
- transparency  

---

### 10.2 Timestamp Role

Timestamps provide:

- proof of existence in time  
- protection against backdating  
- long-term validation  

---

### 10.2.1 Timestamp Binding (CRITICAL)

The timestamp MUST bind to the signature:

```
messageImprint = hash(signature)
```

And MUST satisfy:

```
timestamp ∈ [certificate.notBefore, certificate.notAfter]
```

---

### 10.3 Transparency Role

Transparency provides:

- auditability  
- ordering  
- tamper detection  

Systems include:

- Rekor  
- Sigsum  
- SCITT  

---

### 10.3.1 Transparency Binding

Transparency evidence MUST refer to the same:

- signature  
  OR  
- timestamped signature  

Mismatch → validation MUST fail  

---

### 10.4 DNS Role

TEA-Native:

- DNS publishes certificate  
- DNSSEC optional  
- DNS publication REQUIRED  

WebPKI:

- DNS not a trust anchor  
- DNS may provide CAA policy  

---

## 11. Evidence Bundle (RECOMMENDED)

Consumers SHOULD support TEA Evidence Bundles containing:

- signature  
- certificate  
- timestamps  
- transparency evidence  

Benefits:

- offline validation  
- long-term verification  
- interoperability  

---

## 12. Important Clarifications

### 12.1 Collection ≠ Artefact Signature

They are distinct trust statements.

---

### 12.2 Checksums ≠ Signatures

Checksums bind, but do not authenticate.

---

### 12.3 Artefact Reuse

Allowed and expected.

---

### 12.4 Collection Updates

Do not imply artefact changes.

---

## 13. Security Considerations

### 13.1 Tampering Resistance

Modification breaks signature or binding.

---

### 13.2 Substitution Protection

Prevented via signed checksums.

---

### 13.3 Replay Protection

Handled via:

- timestamps  
- transparency  
- versioning  

---

### 13.4 Missing Artefact Signatures

- integrity preserved  
- authenticity not guaranteed  

---

### 13.5 Partial Validation Risk

Partial validation leads to unsafe conclusions.

---

## 14. Operational Interpretation

### Publisher

- collection signature = release definition  
- artefact signature = authenticity  

---

### Consumer

- collection → inclusion  
- artefact → authenticity  
- checksum → binding  

---

### Approval

Collection signature corresponds to release approval.

---

## 15. Summary

TEA trust is built from:

- collection signatures  
- checksum binding  
- artefact signatures (optional)  
- timestamps  
- transparency  
- DNS (TEA-native)  

---

## 🎯 Final Rule

Collection signatures define what belongs to a release.  
Artefact signatures define what the artefact is.

Both are required for high assurance.
