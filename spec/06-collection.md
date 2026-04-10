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
9. [Digest Algorithm and Canonicalization](#9-digest-algorithm-and-canonicalization)  
10. [Validation Model](#10-validation-model)  
11. [Reuse Rules](#11-reuse-rules)  
12. [Profiles](#12-profiles)  
13. [Error Conditions](#13-error-conditions)  
14. [Extensibility](#14-extensibility)  

---

# 1. Introduction

A **TEA collection** is the authoritative description of a release.

It defines:

- which artifacts belong to a release  
- the exact byte representation of those artifacts  
- optional cryptographic verification references  

The collection is the **publisher’s release statement**.

---

# 2. Purpose

The TEA collection provides:

- deterministic release definition  
- artifact binding via cryptographic digests  
- a stable unit for validation and distribution  

The collection itself does **not establish trust**.

Trust is established through:

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

## 4.1 TEA Collection

A structured object describing a release.

---

## 4.2 TEA Artifact

A **TEA artifact** is any file referenced by the collection.

Examples:

- SBOM  
- binary  
- VEX  
- documentation  

---

## 4.3 Evidence Bundle

An **evidence bundle** is the primary unit of trust and contains:

- signature  
- certificate  
- timestamp(s)  
- transparency evidence  

---

## 4.4 Detached Signature (Legacy)

A standalone signature file.

Supported for compatibility, but:

> In the TEA trust architecture, evidence bundles SHOULD be used instead.

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

---

## 6.1 Rules

- The digest MUST be computed using SHA-256  
- The digest MUST match the exact artifact bytes  
- Artifact content MUST NOT change without updating the digest  

---

# 7. Signatures and Evidence

TEA supports two models:

---

## 7.1 Detached Signatures (Legacy)

```json
{
  "type": "smime",
  "uri": "https://example.com/signature.p7s"
}
```

Supported formats may include:

- S/MIME / CMS  
- JWS  
- GPG (NOT RECOMMENDED)  

---

## 7.2 Evidence Bundles (Preferred)

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
  "objectType": "tea-artifact",
  "uri": "https://example.com/evidence/artifact.bundle.json",
  "digest": {
    "algorithm": "sha-256",
    "value": "BASE64URL..."
  }
}
```

---

## 8.2 Normative Requirements

- The `uri` MUST resolve to the evidence bundle  
- The `digest` MUST match the exact bundle content  
- The digest MUST be computed using SHA-256  
- The digest MUST be computed over a canonical representation  

---

## 8.3 Binding Requirements

The referenced bundle MUST:

- refer to the same artifact  
- contain an object digest matching the artifact digest  

Mismatch MUST result in validation failure.

---

## 8.4 Scope Restriction

Evidence bundle reuse is **restricted to artifacts only**.

Evidence bundles MUST NOT be reused for:

- TEA collections  
- discovery documents  

---

# 9. Digest Algorithm and Canonicalization

## 9.1 Digest Algorithm

TEA defines a single digest algorithm:

- `sha-256`

---

## 9.2 Normative Requirements

- All digests MUST use SHA-256  
- No other digest algorithm is permitted  
- Implementations MUST support SHA-256  

---

## 9.3 Prohibited Algorithms

The following MUST NOT be used:

- MD5  
- SHA-1  
- SHA-512  
- any other algorithm not defined by this specification  

---

## 9.4 Canonicalization

JSON-based objects MUST be canonicalized using:

> RFC 8785 — JSON Canonicalization Scheme (JCS)

---

## 9.5 Digest Computation

For JSON objects:

```
digest = SHA-256(JCS(object))
```

---

## 9.6 Encoding

Digest values MUST be encoded using base64url.

---

# 10. Validation Model

Validation MUST follow:

---

## 10.1 Collection Integrity

- verify collection structure  
- verify artifact digests  

---

## 10.2 Evidence Validation

If evidence bundles are present:

1. verify artifact digest  
2. verify bundle digest  
3. validate evidence bundle:
   - signature  
   - certificate  
   - timestamp  
   - transparency  

---

## 10.3 Rule

> Validation MUST fail on any binding mismatch.

---

# 11. Reuse Rules

## 11.1 Artifact Reuse

An artifact MAY appear in multiple collections.

---

## 11.2 Evidence Bundle Reuse

An evidence bundle MAY be reused only when:

- it refers to a TEA artifact  
- the artifact digest is identical  

---

## 11.3 Prohibited Reuse

Evidence bundles MUST NOT be reused for:

- TEA collections  
- discovery documents  

---

## 11.4 Principle

Artifacts are immutable objects.  
Collections are contextual release statements.

---

# 12. Profiles

## 12.1 Base TEA

- artifacts with digests  
- optional detached signatures  

---

## 12.2 TEA Trust Architecture

- evidence bundles REQUIRED  
- timestamps REQUIRED  
- transparency REQUIRED  

---

## 12.3 High Assurance

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

- unknown fields MUST be ignored  
- additional evidence types MAY be added  
- future formats (CBOR, COSE) MAY be supported  

---

# Final Statement

The TEA collection defines:

- what belongs to a release  

The evidence bundle defines:

- why it can be trusted  

---

## Key Principle

> A collection binds artifacts.  
> An evidence bundle binds trust.
