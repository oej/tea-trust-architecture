# 📘 TEA Versioning and Immutability Model
**Version:** 1.0  
**Status:** Draft (Core TEA Specification)

---

## Table of Contents

- [1. Introduction](#1-introduction)
- [2. Purpose and Scope](#2-purpose-and-scope)
- [3. Design Principles](#3-design-principles)
- [4. Artifact Immutability](#4-artifact-immutability)
- [5. Collection Versioning](#5-collection-versioning)
- [6. Release Identity vs Collection Versions](#6-release-identity-vs-collection-versions)
- [7. Allowed vs Forbidden Changes](#7-allowed-vs-forbidden-changes)
- [8. Version Identification](#8-version-identification)
- [9. Referential Stability](#9-referential-stability)
- [10. Lifecycle Evolution vs Versioning](#10-lifecycle-evolution-vs-versioning)
- [11. Implementation Considerations](#11-implementation-considerations)
- [12. Interoperability Requirements](#12-interoperability-requirements)
- [13. Security Considerations](#13-security-considerations)
- [14. References](#14-references)

---

## 1. Introduction

TEA distinguishes clearly between:

- immutable content (artifacts)  
- evolving metadata (collections)  

This separation enables:

- long-term reproducibility  
- auditability  
- safe updates without redefining releases  

---

## 2. Purpose and Scope

This document defines:

- immutability rules  
- versioning semantics  
- constraints on updates  

It applies to:

- artifacts  
- collections  
- lifecycle data  

---

## 3. Design Principles

### 3.1 Separation of Concerns

```text
Artifacts are immutable.
Collections are versioned.
```

---

### 3.2 Content vs Metadata

```text
Artifacts represent content.
Collections represent metadata about content.
```

---

### 3.3 Deterministic Reproducibility

```text
Given a collection version, the referenced artifacts MUST resolve to identical content.
```

---

## 4. Artifact Immutability

### Normative Requirement

```text
Artifacts MUST be immutable once published.
```

---

### Implication

```text
Any modification to an artifact results in a new artifact identity (new digest).
```

---

### Prohibited Behavior

```text
Artifacts MUST NOT be modified in place.
Artifacts MUST NOT be overwritten.
```

---

### Rationale

Immutability ensures:

- integrity  
- reproducibility  
- safe reuse  

---

## 5. Collection Versioning

Collections are versioned representations of a release.

---

### Normative Principle

```text
A release MAY have multiple collection versions.
```

---

### Purpose

Versioning allows:

- metadata corrections  
- vulnerability updates  
- enrichment over time  

---

### Key Constraint

```text
Collection versions describe the same release.
```

---

## 6. Release Identity vs Collection Versions

### Important Distinction

| Concept | Mutable | Purpose |
|--------|--------|--------|
| Release (TEI + version) | No | Identity |
| Collection Version | Yes | Description |

---

### Normative Rule

```text
Collection versioning MUST NOT change release identity.
```

---

## 7. Allowed vs Forbidden Changes

### Allowed Changes

```text
- updated vulnerability information (e.g., VEX)
- metadata corrections
- additional descriptive fields
- lifecycle updates
```

---

### Forbidden Changes

```text
- modification of artifact digests
- removal of previously declared artifacts
- change of release identity
```

---

### Rationale

```text
Changing artifact content would invalidate reproducibility.
```

---

## 8. Version Identification

Collections MUST be versioned.

---

### Requirements

```text
Each collection version MUST have:
- a unique identifier
- a reference to previous version (if applicable)
- an update reason
```

---

### Update Reason

Example values:

```text
- updated-vex-information
- metadata-correction
- spelling-fix
- additional-context
- other
```

---

### Ordering

```text
Collection versions SHOULD be ordered chronologically.
```

---

## 9. Referential Stability

### Normative Requirement

```text
References to artifacts MUST remain stable across collection versions.
```

---

### Implication

```text
An artifact referenced in one version MUST refer to the same digest in all versions.
```

---

### Exception

```text
New artifacts MAY be added in later versions.
```

---

## 10. Lifecycle Evolution vs Versioning

Lifecycle information may change independently.

---

### Normative Rule

```text
Lifecycle updates MUST NOT affect artifact identity.
```

---

### Relationship

```text
Lifecycle is dynamic metadata.
Artifacts are static content.
```

---

## 11. Implementation Considerations

### Storage

```text
Store:
- artifacts by digest
- collections by version
```

---

### Version Linking

```text
Maintain links between collection versions.
```

---

### Diff Support

```text
Implementations SHOULD support diffing between collection versions.
```

---

## 12. Interoperability Requirements

### Producers

```text
MUST:
- enforce artifact immutability
- version collections correctly
- provide update reasons
```

---

### Consumers

```text
MUST:
- treat artifacts as immutable
- distinguish collection versions
- reject invalid changes
```

---

### Invalid State

```text
If an artifact digest changes across versions, validation MUST fail.
```

---

## 13. Security Considerations

### Risks

- silent mutation of artifacts  
- misleading metadata updates  
- inconsistent version chains  

---

### Mitigations

- digest-based identity  
- strict version validation  
- audit trails  

---

### Critical Principle

```text
Immutability is a prerequisite for trust.
```

---

## 14. References

- RFC 9110 — HTTP Semantics  
- FIPS 180-4 — Secure Hash Standard (SHA-256)  

---
