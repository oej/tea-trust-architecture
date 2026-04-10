# 📘 TEA Collection Specification
**Version:** 1.0  
**Status:** Draft (Normative, Implementation-Ready)

---

# Table of Contents

1. [Introduction](#1-introduction)  
2. [Purpose](#2-purpose)  
3. [Scope](#3-scope)  
4. [Core Concepts](#4-core-concepts)  
5. [Collection Structure](#5-collection-structure)  
6. [Artifacts](#6-artifacts)  
7. [Signatures and Evidence](#7-signatures-and-evidence)  
8. [Evidence Bundle References](#8-evidence-bundle-references)  
9. [Digest and Canonicalization](#9-digest-and-canonicalization)  
10. [Validation Model](#10-validation-model)  
11. [Reuse Across Collections](#11-reuse-across-collections)  
12. [Profiles](#12-profiles)  
13. [Error Conditions](#13-error-conditions)  
14. [Extensibility](#14-extensibility)  

---

# 1. Introduction

A **TEA collection** is the authoritative description of a release.

It defines:

- which artifacts belong to a release  
- the exact byte representation of those artifacts  
- optional cryptographic verification mechanisms  

The collection is the **publisher’s release statement**.

---

# 2. Purpose

The TEA collection provides:

- deterministic release definition  
- artifact binding via cryptographic digests  
- a stable unit for validation and distribution  

The collection itself does **not establish trust**.  
Trust is established through:

- signatures  
- evidence bundles  
- validation policies  

---

# 3. Scope

A collection:

- MAY reference multiple artifacts  
- MAY be versioned  
- MAY exist without signatures (base TEA)  

The TEA trust architecture introduces additional requirements on top of this base model.

---

# 4. Core Concepts

### 4.1 Collection

A **collection** is a structured object describing a release.

---

### 4.2 Artifact

A **TEA artifact** is any file referenced by the collection.

Examples:

- SBOM  
- binary  
- VEX  
- documentation  

---

### 4.3 Evidence Bundle

An **evidence bundle** contains:

- signature  
- certificate  
- timestamp(s)  
- transparency evidence  

It is the **primary unit of trust** in the TEA trust architecture.

---

### 4.4 Detached Signature (Legacy)

A **detached signature** is a standalone signature file.

It is supported for compatibility but:

> In TEA trust architecture, evidence bundles SHOULD be used instead.

---

# 5. Collection Structure

Example:

```json
{
  "collectionId": "release-2026.01",
  "version": "1.0",
  "artifacts": [ ... ],
  "signatures": [ ... ],
  "evidenceBundles": [ ... ]
}
```

---

# 6. Artifacts

Each artifact MUST include a digest.

```json
{
  "artifactId": "sbom",
  "uri": "https://example.com/sbom.json",
  "digest": {
    "algorithm": "sha-256",
    "value": "BASE64URL..."
  }
}
```

### Rules

- Digest MUST match exact artifact bytes  
- Artifact content MUST NOT be modified without updating digest  

---

# 7. Signatures and Evidence

TEA supports multiple approaches:

---

## 7.1 Detached Signatures (Legacy Support)

```json
{
  "type": "smime",
  "uri": "https://example.com/signature.p7s"
}
```

Supported formats may include:

- S/MIME / CMS  
- JWS  
- GPG (not recommended)  

---

## 7.2 Evidence Bundle (Preferred)

Evidence bundles encapsulate all verification material.

They:

- replace standalone signature handling  
- enable offline validation  
- support long-term verification  

---

# 8. Evidence Bundle References

Collections MAY reference external evidence bundles.

---

## 8.1 Structure

```json
{
  "objectType": "tea-collection",
  "uri": "https://example.com/evidence/collection.bundle.json",
  "digest": {
    "algorithm": "sha-256",
    "value": "BASE64URL..."
  }
}
```

---

## 8.2 Rules

- `uri` MUST resolve to the evidence bundle  
- `digest` MUST match the exact bundle content  
- Digest MUST be computed over canonical representation (see Section 9)  

---

## 8.3 Binding

The referenced bundle MUST:

- refer to this collection  
- contain a matching object digest  

Mismatch MUST result in validation failure.

---

# 9. Digest and Canonicalization

JSON representations are not stable across formatting.

Therefore:

### Rule

All JSON digests MUST use:

> **RFC 8785 — JSON Canonicalization Scheme (JCS)**

---

### Process

1. Canonicalize JSON  
2. Compute digest  
3. Encode using base64url  

---

### Rationale

Ensures:

- consistent hashing  
- interoperability  
- stable validation  

---

# 10. Validation Model

Validation MUST follow:

---

### 10.1 Collection Integrity

- verify collection structure  
- verify artifact digests  

---

### 10.2 Signature / Evidence

If present:

- verify detached signatures  
OR  
- validate evidence bundle  

---

### 10.3 Evidence Bundle Validation

When using evidence bundles:

1. verify object digest  
2. verify signature  
3. verify certificate  
4. verify timestamp  
5. verify timestamp binding  
6. verify transparency evidence  

---

### Rule

> Validation MUST fail on any binding mismatch.

---

# 11. Reuse Across Collections

### 11.1 Artifact Reuse

An artifact MAY appear in multiple collections.

---

### 11.2 Evidence Bundle Reuse

An evidence bundle MAY be reused across collections if:

- the artifact digest matches  
- the bundle refers to the same object  

---

### 11.3 Implication

Artifacts and evidence bundles become:

> reusable, immutable building blocks  

---

# 12. Profiles

### 12.1 Minimal (Base TEA)

- artifacts with digests  
- optional detached signatures  

---

### 12.2 TEA Trust Architecture

- evidence bundles REQUIRED  
- timestamps REQUIRED  
- transparency REQUIRED  

---

### 12.3 High Assurance

- multiple timestamps  
- multiple transparency systems  
- strict validation policies  

---

# 13. Error Conditions

Validation MUST fail if:

- artifact digest mismatch  
- bundle digest mismatch  
- signature invalid  
- timestamp invalid  
- transparency invalid  
- binding inconsistency  

---

# 14. Extensibility

Rules:

- unknown fields MUST be ignored  
- additional evidence types MAY be added  
- future formats (CBOR, COSE) MAY be supported  

---

# Final Statement

The TEA collection defines:

- *what belongs to a release*  

The evidence bundle defines:

- *why it can be trusted*  

Together, they provide:

- deterministic composition  
- verifiable integrity  
- long-term validation  

---

## Key Principle

> A collection binds artifacts.  
> An evidence bundle binds trust.
