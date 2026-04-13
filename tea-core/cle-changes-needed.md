# 📘 TEA Core — Lifecycle (CLE) Support and Evolution
**Directory:** `tea-core/cle.md`  
**Version:** 1.0  
**Status:** Draft (Informative with Normative Guidance for Future Evolution)

---

## Status

This document describes how **Common Lifecycle Enumeration (CLE)** is currently used in TEA Core and defines the **required evolution** of the model to support:

- lifecycle versioning  
- historical traceability  
- auditability  
- regulatory alignment (e.g. EU CRA)

This document is:

- **descriptive** of the current OpenAPI-based model  
- **normative** regarding required future capabilities  

---

## Table of Contents

1. Introduction  
2. CLE in TEA Core Today  
3. Limitations of the Current Model  
4. Design Principles for Lifecycle Handling  
5. Required Enhancements to TEA Core  
6. Updated API Model (Distributed CLE Endpoints)  
7. Lifecycle Versioning Model  
8. Publisher Workflow Requirements  
9. Consumer Expectations  
10. Future Alignment with Trust Architecture  
11. Summary  

---

## 1. Introduction

Lifecycle information is a core element of software transparency.

Examples include:

- end-of-sale  
- end-of-support  
- end-of-life  
- deprecation  
- replacement  

These lifecycle statements:

- influence operational and procurement decisions  
- affect vulnerability management  
- are critical for regulatory compliance  

TEA uses **Common Lifecycle Enumeration (CLE)** (ECMA-428) to express lifecycle data.

---

## 2. CLE in TEA Core Today

In the current TEA OpenAPI specification:

- lifecycle information is included in resource representations  
- lifecycle data is associated with:

  - product  
  - product release  
  - component  
  - component release  

Lifecycle data is:

- embedded in API responses  
- not exposed as a standalone resource  

---

## 3. Limitations of the Current Model

The current approach is sufficient for simple use cases but fails in real-world scenarios.

### 3.1 No lifecycle versioning

Lifecycle data:

- can change over time  
- has no version identity  

Result:

> Consumers cannot determine what changed or when.

---

### 3.2 No historical traceability

There is no mechanism to:

- retrieve previous lifecycle states  
- compare lifecycle changes  

---

### 3.3 No immutability guarantees

Lifecycle data may be:

- overwritten  
- silently changed  

This breaks:

- auditability  
- regulatory expectations  

---

### 3.4 No lifecycle publication workflow

Lifecycle updates:

- are not treated as formal publications  
- lack approval and governance mechanisms  

---

### 3.5 No independent lifecycle lifecycle (object)

Lifecycle is not:

- independently addressable  
- independently versioned  

---

## 4. Design Principles for Lifecycle Handling

To support real-world usage, lifecycle data MUST follow these principles:

### 4.1 Lifecycle is time-dependent

Lifecycle is not static metadata.

It represents:

> a commitment that evolves over time

---

### 4.2 Lifecycle updates are events

Each update MUST be treated as:

- a new version  
- a new published statement  

---

### 4.3 Lifecycle must be auditable

Consumers MUST be able to:

- retrieve previous versions  
- understand changes  

---

### 4.4 Lifecycle must be immutable

Once published:

> A lifecycle version MUST NOT be modified

---

### 4.5 Lifecycle remains scoped to its subject

TEA does not introduce a global `/cle` resource.

Lifecycle remains associated with:

- product  
- product release  
- component  
- component release  

---

## 5. Required Enhancements to TEA Core

The following changes are required.

---

### 5.1 Introduce lifecycle versioning

Each lifecycle update MUST:

- create a new version  
- preserve all previous versions  

---

### 5.2 Introduce lifecycle version identifiers

Each lifecycle version MUST include:

- version identifier  
- creation timestamp  
- reference to previous version  

---

### 5.3 Introduce update reason

Each lifecycle update MUST include a reason, for example:

- "end-of-life date extended"  
- "end-of-sale announced"  
- "correction of previous information"  

---

### 5.4 Introduce lifecycle publication workflow

Lifecycle updates MUST follow a controlled process:

- creation (draft)  
- review / approval  
- publication (commit)  

---

### 5.5 Introduce lifecycle history APIs

Consumers MUST be able to retrieve:

- current lifecycle  
- all lifecycle versions  
- specific lifecycle version  

---

## 6. Updated API Model (Distributed CLE Endpoints)

Lifecycle remains scoped to each resource type.

### 6.1 Product

```
GET /products/{productId}/lifecycle
GET /products/{productId}/lifecycle/versions
GET /products/{productId}/lifecycle/versions/{version}
```

---

### 6.2 Product Release

```
GET /product-releases/{id}/lifecycle
GET /product-releases/{id}/lifecycle/versions
GET /product-releases/{id}/lifecycle/versions/{version}
```

---

### 6.3 Component

```
GET /components/{id}/lifecycle
GET /components/{id}/lifecycle/versions
GET /components/{id}/lifecycle/versions/{version}
```

---

### 6.4 Component Release

```
GET /component-releases/{id}/lifecycle
GET /component-releases/{id}/lifecycle/versions
GET /component-releases/{id}/lifecycle/versions/{version}
```

---

## 7. Lifecycle Versioning Model

Each lifecycle version is treated as a logical document.

### 7.1 Required fields

```
{
  "version": "string",
  "previousVersion": "string | null",
  "createdAt": "timestamp",
  "reason": "string",
  "lifecycle": { ... ECMA-428 ... }
}
```

---

### 7.2 Version chain

Lifecycle versions form a chain:

```
v1 → v2 → v3 → ...
```

Each version:

- is immutable  
- is independently retrievable  

---

## 8. Publisher Workflow Requirements

Lifecycle updates MUST follow a controlled process.

### 8.1 Draft phase

Lifecycle changes may be prepared in CI/CD.

---

### 8.2 Approval phase

Publication MUST require:

- explicit approval  
- authenticated and authorized actor  

---

### 8.3 Commit phase

Upon publication:

- a new lifecycle version is created  
- previous versions remain accessible  

---

### 8.4 Audit trail

Implementations SHOULD log:

- lifecycle changes  
- timestamps  
- actor identity  

---

## 9. Consumer Expectations

Consumers MUST:

- support retrieval of lifecycle versions  
- be able to compare lifecycle changes  

Consumers SHOULD:

- detect changes in lifecycle commitments  
- alert on significant changes  

---

## 10. Future Alignment with Trust Architecture

TEA Core does not mandate cryptographic protection.

However, lifecycle data is a strong candidate for:

- signing  
- timestamping  
- transparency logging  

Future TEA Trust Architecture documents define:

- evidence bundles for lifecycle documents  
- validation requirements  

---

## 11. Summary

The current TEA model:

- supports lifecycle data  
- does not support lifecycle evolution  

To meet real-world requirements:

> Lifecycle data MUST become versioned, immutable, and historically accessible

This change:

- aligns TEA with regulatory expectations  
- enables auditability  
- improves trust in lifecycle commitments  

---

## Final Statement

Lifecycle information is not just descriptive metadata.

It is:

> **a sequence of commitments made over time — and those commitments must remain visible, traceable, and verifiable**
