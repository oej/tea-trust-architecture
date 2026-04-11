# 📘 TEA Core Specification

## Status

This directory contains the **core Transparency Exchange API (TEA)** specifications.

The documents in this directory define:

- the **identifier model (TEI)**
- the **discovery mechanism**
- the **conceptual data model**
- the **API interaction model**

These documents are **normative for TEA**, together with the OpenAPI specification.

---

## Scope

The TEA Core Specification defines how software transparency data is:

- identified
- discovered
- structured
- published
- retrieved

It includes:

- products and product releases  
- components and component releases  
- collections (groupings of artifacts for a release)  
- artifacts (SBOMs, VEX, binaries, documents, etc.)  
- lifecycle information (CLE – ECMA-428)  
- compliance documents (publisher-scoped)  

The core specification is intentionally **agnostic to trust and security mechanisms**.

---

## Normative Structure

TEA Core is composed of **two complementary normative layers**:

---

### 1. Identifier and Discovery Layer (Non-OpenAPI)

Defined in:

- `tei.md`
- `discovery.md`

These documents normatively define:

- the **TEI scheme** (identifier syntax and semantics)
- how identifiers map to publisher domains
- how discovery is performed via `.well-known` endpoints
- how a client locates TEA services

These mechanisms are **not expressed in OpenAPI**, and therefore must be specified separately.

---

### 2. API and Data Model Layer (OpenAPI)

Defined in:

- OpenAPI specification (`spec/openapi.yaml` in the main repository)

The OpenAPI specification is normative for:

#### API behavior

- endpoints
- request/response formats
- pagination, filtering, and retrieval patterns

#### Data model

- products and product releases  
- components and component releases  
- collections  
- artifacts  
- compliance documents  
- enum types (including compliance document types)  
- lifecycle propagation using CLE (ECMA-428)  

This means:

> The OpenAPI specification is the authoritative definition of TEA object schemas and their relationships.

---

### Key distinction

```text
TEI + Discovery:
How to locate a TEA service

OpenAPI:
How to interact with the service and how data is structured
```

Both layers are required for a complete TEA implementation.

---

## Relationship to TEA Trust Architecture

The TEA Trust Architecture is defined separately under:

```text
spec/
profiles/
```

It is an **optional overlay** that adds:

- signatures  
- certificates  
- timestamps  
- transparency logs  
- DNS-based trust anchoring  
- evidence bundles and validation  

### Important distinction

```text
TEA Core:
Defines WHAT is published and HOW it is accessed

TEA Trust Architecture:
Defines HOW it is secured and validated
```

---

## Design Principle

TEA Core deliberately avoids embedding:

- cryptographic requirements  
- trust models  
- validation rules  
- certificate handling  

This ensures:

- clear separation of concerns  
- flexibility across environments  
- long-term stability of the data model  

---

## Contents of this Directory

Typical documents in `tea-core/` include:

- `tei.md`  
  Transparency Exchange Identifier (TEI) scheme and syntax  

- `discovery.md`  
  Discovery mechanism starting from a TEI  

- `api-overview.md`  
  Conceptual overview of API behavior and object relationships  

- `collection.md`  
  Collections and their relationship to releases  

- `artifact.md`  
  Artifact definition and retrieval  

- `versioning-and-immutability.md`  
  Versioning rules and immutability guarantees  

- `compliance-documents.md`  
  Publisher-scoped compliance documents  

- `glossary.md`  
  Shared terminology across TEA  

---

## What is NOT in TEA Core

The following are explicitly **out of scope** for this directory:

- signatures and signature formats  
- certificates and PKI profiles  
- timestamps and timestamp validation  
- transparency logs (Sigsum, Rekor, SCITT)  
- evidence bundles  
- trust anchors and DNSSEC usage  
- validation procedures  

These are defined in the TEA Trust Architecture.

---

## When to Use TEA Core Alone

TEA Core can be used independently when:

- trust is handled externally  
- integrity validation is not required  
- the environment is controlled or trusted  
- the goal is interoperability of data  

---

## When to Use TEA with Trust Architecture

The TEA Trust Architecture SHOULD be used when:

- long-term validation is required  
- regulatory compliance (e.g. CRA) applies  
- artifacts must be independently verifiable  
- supply chain integrity must be ensured  

---

## Summary

TEA Core defines a **complete, interoperable model for software transparency**, consisting of:

- **TEI + Discovery** → how services are located  
- **OpenAPI** → how services are used and how data is structured  

It intentionally separates:

```text
Data model and access (TEA Core)
from
Trust and validation (TEA Trust Architecture)
```

This separation enables flexibility, composability, and long-term evolution of the specification.