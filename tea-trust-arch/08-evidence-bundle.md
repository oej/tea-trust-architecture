# 📘 TEA Evidence Bundle Specification
**Version:** 1.0  
**Status:** Draft (Normative, RFC-style)

---

## Status

This document defines the **TEA evidence bundle**, the primary trust object in the TEA Trust Architecture.

It specifies:

- structure and semantics of evidence bundles  
- how evidence binds to TEA objects  
- how evidence is created and reused  
- how integrity of external bundles is ensured  

This specification applies to:

- **TEA Trust Architecture (REQUIRED)**
- **base TEA (OPTIONAL)**

The key words **MUST**, **SHOULD**, and **MAY** are to be interpreted as described in:

- RFC 2119  
- RFC 8174  

---

## Table of Contents

1. [Introduction](#1-introduction)  
2. [Role of the Evidence Bundle](#2-role-of-the-evidence-bundle)  
3. [Scope and Binding Targets](#3-scope-and-binding-targets)  
4. [Evidence Bundle Structure](#4-evidence-bundle-structure)  
5. [Signature Semantics](#5-signature-semantics)  
6. [Certificate Semantics](#6-certificate-semantics)  
7. [Timestamp Semantics](#7-timestamp-semantics)  
8. [Transparency Evidence](#8-transparency-evidence)  
9. [Canonicalization and Digest Rules](#9-canonicalization-and-digest-rules)  
10. [External Evidence Bundles](#10-external-evidence-bundles)  
11. [Immutability and Reuse](#11-immutability-and-reuse)  
12. [Relationship to Collections](#12-relationship-to-collections)  
13. [Relationship to Discovery](#13-relationship-to-discovery)  
14. [Relationship to Lifecycle (CLE)](#14-relationship-to-lifecycle-cle)  
15. [Normative Requirements](#15-normative-requirements)  
16. [Error Conditions](#16-error-conditions)  
17. [Security Considerations](#17-security-considerations)  
18. [Normative References](#18-normative-references)  
19. [Informative References](#19-informative-references)  

---

## 1. Introduction

The TEA Trust Architecture is built on a central idea:

> **Trust is derived from evidence, not from long-lived keys or infrastructure.**

The **evidence bundle** is the object that carries that evidence.

It allows a consumer to verify:

- that an object was signed  
- which key was used  
- when the signature existed  
- whether the event was publicly recorded (optional)  

without requiring access to:

- the original signing system  
- a live PKI  
- revocation infrastructure  

---

## 2. Role of the Evidence Bundle

The evidence bundle is:

> **the unit of trust in TEA**

It replaces fragmented models where:

- signatures  
- certificates  
- timestamps  
- transparency proofs  

are handled independently.

Instead, TEA groups them into a single, portable object.

### 2.1 What the bundle proves

An evidence bundle enables verification of:

- **authenticity** (signature)
- **key validity at signing time** (certificate)
- **existence in time** (timestamp)
- **public accountability** (transparency, optional)

---

## 3. Scope and Binding Targets

An evidence bundle binds to a specific object.

### 3.1 Supported targets

Evidence bundles MAY bind to:

- **TEA artifacts** (primary use case)
- **compliance documents (treated as standalone artifacts)**
- **TEA collections**
- **discovery documents**
- **lifecycle (CLE) documents**

### 3.2 Binding rule

The bundle MUST be cryptographically bound to:

> the exact bytes of the target object

This is achieved through the signature.

---

## 4. Evidence Bundle Structure

An evidence bundle is a structured object containing:

```json
{
  "signature": { ... },
  "certificate": { ... },
  "timestamps": [ ... ],
  "transparency": [ ... ]
}
```

### 4.1 Components

| Component | Required | Description |
|----------|---------|-------------|
| signature | YES | Cryptographic signature over target |
| certificate | YES | Contains public key used for verification |
| timestamps | YES (trust architecture) | Proof of existence in time |
| transparency | REQUIRED (trust architecture) | Log inclusion proofs |

---

## 5. Signature Semantics

### 5.1 Purpose

The signature binds:

- the target object  
- to a specific key pair  

### 5.2 Requirements

- MUST use Ed25519  
- MUST cover exact target bytes  
- MUST be verifiable using the certificate  

### 5.3 Important clarification

> The signature is **part of the evidence bundle**, not a separate trust object.

Detached signatures MAY exist for compatibility, but:

- they are not sufficient for trust validation  
- they should be included or referenced within the bundle  

### 5.4 Publisher-side validation (CRITICAL)

When an evidence bundle is submitted to a TEA Publisher API:

- the Publisher API MUST verify that the signature validates against the target object  
- the verification MUST use the public key contained in the certificate  

Evidence bundles that fail this validation:

> MUST be rejected and MUST NOT be stored or processed further  

---

## 6. Certificate Semantics

### 6.1 Role

The certificate provides:

- the public key  
- validity period  
- binding to DNS identity  

### 6.2 Requirements

- MUST follow TEA X.509 profile  
- MUST have lifetime < 1 hour  
- MUST contain DNS SAN  
- MUST correspond to the signing key  

### 6.3 Identity model

The certificate is:

> a **validity wrapper**, not a long-term identity

Identity is derived from:

- DNS anchoring  
- key fingerprint  

---

## 7. Timestamp Semantics

### 7.1 Requirement

Timestamps are:

> **REQUIRED in TEA Trust Architecture**

### 7.2 What a timestamp proves

A timestamp proves:

- the signature existed at a specific time  
- the signed object existed at that time  

### 7.3 Trust model

Trust depends on:

- trusted TSA  
- cryptographic binding to signature  

### 7.4 Operational guidance

- multiple timestamps SHOULD be used  
- timestamps SHOULD be compared for consistency  

---

## 8. Transparency Evidence

### 8.1 Requirement

Transparency evidence is:

> **REQUIRED in TEA Trust Architecture**

### 8.2 Supported systems

- Rekor  
- Sigsum  

SCITT MAY be supported in addition but is not required.

### 8.3 Publisher requirement

A publisher MUST include transparency evidence from at least one of:

- Sigsum, or  
- Rekor  

### 8.4 Consumer requirement

Consumers and TEA services implementing the TEA Trust Architecture MUST support validation of:

- Sigsum  
- Rekor  

### 8.5 What it provides

- append-only logging  
- detection of equivocation  
- auditability  

---

## 9. Canonicalization and Digest Rules

### 9.1 Digest algorithm

All digests MUST use:

```text
SHA-256
```

No other algorithms are permitted.

---

### 9.2 JSON canonicalization

When hashing JSON objects:

- MUST use RFC 8785 (JCS)

### 9.3 Why this is required

JSON is not byte-stable.

Canonicalization ensures:

- consistent hashing  
- interoperability  
- resistance to formatting changes  

---

## 10. External Evidence Bundles

### 10.1 Use case

Evidence bundles MAY be stored externally and referenced.

### 10.2 Requirement

When referenced externally, the reference MUST include:

- URI  
- SHA-256 digest  

### 10.3 Digest computation

Digest MUST be computed over:

```text
SHA-256(JCS(evidenceBundle))
```

### 10.4 Rationale

This prevents:

- substitution attacks  
- silent modification of evidence  

### 10.5 Restriction for lifecycle (CLE)

Lifecycle (CLE) documents:

> MUST NOT use external evidence bundles

Evidence for CLE MUST be embedded within the CLE document.

---

## 11. Immutability and Reuse

### 11.1 Immutability

An evidence bundle is:

> **immutable**

Any change results in a new bundle.

---

### 11.2 Artifact reuse

Evidence bundles for artifacts:

- MAY be reused across collections  

### 11.3 Scope of reuse

Evidence reuse applies:

> **ONLY to artifacts (including compliance documents treated as artifacts)**

### 11.4 Collection reuse

Evidence bundles for collections:

- MUST NOT be reused across collections  

### 11.5 Lifecycle (CLE) reuse

Evidence bundles for lifecycle (CLE) documents:

> MUST NOT be reused across versions

Each lifecycle version:

- MUST have its own evidence bundle  
- MUST be independently signed and timestamped  

### 11.6 Rationale

Artifacts are immutable content.  
Collections are contextual statements.  
Lifecycle documents are **time-dependent commitments**.

---

## 12. Relationship to Collections

### 12.1 Collection role

A TEA collection:

- binds artifacts to a release  

### 12.2 Evidence relationship

- artifact evidence proves authenticity  
- collection evidence proves release statement  

### 12.3 Important distinction

> A collection does NOT replace artifact evidence.

Both must be evaluated independently.

---

## 13. Relationship to Discovery

### 13.1 Discovery evidence

Discovery documents MAY have evidence bundles.

### 13.2 Purpose

- validate service location metadata  
- protect against tampering  

### 13.3 Independence

Discovery evidence is independent of:

- artifact evidence  
- collection evidence  

---

## 14. Relationship to Lifecycle (CLE)

### 14.1 Lifecycle role

Lifecycle (CLE) documents represent:

> time-dependent statements about the state and support of a product or component

### 14.2 Evidence requirements

Lifecycle documents:

- MUST be signed  
- MUST include timestamps (trust architecture)  
- MUST include transparency evidence (trust architecture)  

### 14.3 Binding model

The evidence bundle binds to:

> the full lifecycle document for a specific version

### 14.4 Independence

Lifecycle evidence is independent of:

- artifact evidence  
- collection evidence  

### 14.5 No reuse

Each lifecycle version:

- MUST have unique evidence  
- MUST be validated independently  

---

## 15. Normative Requirements

### 15.1 General

An evidence bundle MUST:

- include signature and certificate  
- include at least one timestamp (trust architecture)  
- include transparency evidence (trust architecture)  
- use Ed25519  
- use SHA-256 for digests  

---

### 15.2 Binding

The bundle MUST:

- bind to exact target bytes  
- not be reusable across different targets  

---

### 15.3 Publisher validation requirement

Publisher implementations MUST:

- verify that the signature matches the target object  
- verify that the certificate corresponds to the signing key  
- reject evidence bundles that fail verification  

---

### 15.4 External references

External bundles MUST:

- include SHA-256 digest  
- use canonical JSON for hashing  

---

## 16. Error Conditions

Validation MUST fail when:

- signature verification fails  
- certificate is invalid  
- timestamp missing or invalid  
- transparency evidence missing or invalid  
- digest mismatch occurs  
- canonicalization rules violated  

Example identifiers:

- `EVIDENCE_SIGNATURE_INVALID`  
- `EVIDENCE_CERT_INVALID`  
- `EVIDENCE_TIMESTAMP_MISSING`  
- `EVIDENCE_TRANSPARENCY_MISSING`  
- `EVIDENCE_DIGEST_MISMATCH`  
- `EVIDENCE_CANONICALIZATION_ERROR`  

---

## 17. Security Considerations

### 17.1 Substitution attacks

Mitigated by:

- SHA-256 digest binding  

---

### 17.2 Key compromise

Mitigated by:

- short-lived certificates  
- no key reuse  

---

### 17.3 Time manipulation

Mitigated by:

- trusted timestamps  
- multiple TSAs  

---

### 17.4 Transparency risks

Mitigated by:

- witness verification  
- multiple logs  

---

### 17.5 WebPKI mode

When WebPKI is used as the trust model:

> evidence bundles MUST NOT be included.

---

## 18. Normative References

- RFC 2119 / RFC 8174  
- RFC 5280 — X.509  
- RFC 3161 — Time-Stamp Protocol  
- RFC 8785 — JSON Canonicalization Scheme  

---

## 19. Informative References

- Rekor Transparency Log  
- Sigsum Transparency Log  
- IETF SCITT Architecture  
- TEA Trust Architecture Specification  

---

## Final Statement

The evidence bundle defines:

> **why an object can be trusted**

It transforms TEA from a data exchange format into:

> **a verifiable, time-aware, and audit-ready trust system**
