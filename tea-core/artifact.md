# 📘 TEA Artifact Specification (Core)
**Version:** 1.0  
**Status:** Draft (Core TEA Specification)

---

## Table of Contents

- [1. Introduction](#1-introduction)
- [2. Purpose and Scope](#2-purpose-and-scope)
- [3. Definition of an Artifact](#3-definition-of-an-artifact)
- [4. Core Properties](#4-core-properties)
- [5. Artifact Identity Model](#5-artifact-identity-model)
- [6. Immutability and Reuse](#6-immutability-and-reuse)
- [7. Relationship to Collections](#7-relationship-to-collections)
- [8. Retrieval and Distribution](#8-retrieval-and-distribution)
- [9. Media Types and Encoding](#9-media-types-and-encoding)
- [10. Artifact Integrity](#10-artifact-integrity)
- [11. Interoperability Requirements](#11-interoperability-requirements)
- [12. Security Considerations](#12-security-considerations)
- [13. References](#13-references)

---

## 1. Introduction

Artifacts are the fundamental deliverables exchanged through TEA.

They represent the actual content associated with a release, such as:

- software packages  
- SBOMs  
- VEX documents  
- attestations  
- documentation  

This document defines how artifacts are identified, referenced, and distributed within TEA.

---

## 2. Purpose and Scope

This specification defines:

- what an artifact is  
- how artifacts are identified  
- how artifacts are retrieved  

It does NOT define:

- how artifacts are signed  
- how artifacts are validated  

These are defined in the TEA trust architecture.

---

## 3. Definition of an Artifact

An artifact is:

```text
A binary or structured object that is part of a product release and can be independently retrieved.
```

---

### Key Characteristics

- artifacts are opaque to TEA  
- TEA does not interpret artifact content  
- artifacts may be any format  

---

## 4. Core Properties

Every artifact MUST have:

- a cryptographic digest  
- a stable binary representation  

---

### Optional Properties

Artifacts MAY have:

- a filename  
- a media type  
- descriptive metadata  

---

## 5. Artifact Identity Model

Artifacts are identified by their digest.

---

### Normative Requirement

```text
The identity of an artifact MUST be defined by a SHA-256 digest of its exact binary representation.
```

---

### Example

```json
{
  "digest": {
    "algorithm": "sha-256",
    "value": "BASE64URL..."
  }
}
```

---

### Rationale

Digest-based identity ensures:

- global uniqueness  
- content-addressability  
- independence from location  

---

### Implementation Hint

```text
Compute the digest on the exact byte stream delivered to consumers.
Any transformation (e.g., reformatting) will invalidate the identity.
```

---

## 6. Immutability and Reuse

### Normative Requirement

```text
Artifacts MUST be immutable once published.
```

---

### Reuse Principle

```text
The same artifact MAY be referenced by multiple collections.
```

---

### Implication

- artifacts are stored once  
- collections reference artifacts by digest  

---

### Design Insight

This enables:

- deduplication  
- consistent validation  
- cross-release reuse  

---

## 7. Relationship to Collections

Collections reference artifacts.

---

### Binding Model

```text
Collection → artifact digest → artifact
```

---

### Normative Rule

```text
Collections MUST NOT embed artifact content.
Collections MUST reference artifacts by digest.
```

---

### Important Constraint

```text
The digest of an artifact MUST NOT change across collection versions.
```

---

## 8. Retrieval and Distribution

Artifacts are retrieved independently of collections.

---

### Conceptual API

```text
GET /artifacts/{digest}
```

---

### Delivery Modes

#### 1. Artifact Only

```text
Content-Type: application/octet-stream
```

---

#### 2. Artifact + Detached Signature

```text
Content-Type: multipart/*
```

Contains:

- artifact  
- signature  

---

#### 3. Artifact + Evidence Bundle

```text
Content-Type: multipart/*
```

Contains:

- artifact  
- evidence bundle  

---

### Design Principle

```text
The artifact is always the primary object.
Additional data is optional and transport-dependent.
```

---

## 9. Media Types and Encoding

### Artifact Content

```text
Artifacts MAY use any media type appropriate to their format.
```

Examples:

- application/json  
- application/xml  
- application/pdf  
- application/octet-stream  

---

### TEA Constraint

```text
TEA does not define or restrict artifact media types.
```

---

### Multipart Responses

```text
Multipart responses MUST clearly separate parts.
Each part SHOULD include a Content-Type header.
```

---

### Design Decision

No custom TEA media types are defined.

---

## 10. Artifact Integrity

Integrity is ensured via the digest.

---

### Normative Requirement

```text
Consumers MUST verify that the downloaded artifact matches the expected digest.
```

---

### Verification Model

```text
downloaded artifact → hash → compare with expected digest
```

---

### Important Distinction

```text
Digest verification ensures integrity, not authenticity.
```

Authenticity is handled by the trust architecture.

---

## 11. Interoperability Requirements

### Producers

```text
Producers MUST:
- compute SHA-256 digests
- ensure artifact immutability
- provide stable binary representations
```

---

### Consumers

```text
Consumers MUST:
- verify artifact digests
- reject mismatches
```

---

### Unknown Metadata

```text
Consumers MUST ignore unknown fields.
```

---

## 12. Security Considerations

### Risks

- artifact tampering  
- inconsistent representations  
- digest mismatch  

---

### Mitigations

- strict digest verification  
- immutable storage  
- separation of integrity and authenticity  

---

### Critical Principle

```text
Artifacts are trusted only after:
- digest verification AND
- trust validation (outside this spec)
```

---

## 13. References

- FIPS 180-4 — Secure Hash Standard (SHA-256)  
- RFC 4648 — Base64URL Encoding  
- RFC 9110 — HTTP Semantics  

---
