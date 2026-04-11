# 📘 TEA Transparency Exchange Identifier (TEI) Specification
**Version:** 1.0  
**Status:** Draft (Core TEA Specification)

---

## Table of Contents

- [1. Introduction](#1-introduction)
- [2. Background and Design Intent](#2-background-and-design-intent)
- [3. Identifier Reuse Policy](#3-identifier-reuse-policy)
- [4. Rationale for a New URI Scheme](#4-rationale-for-a-new-uri-scheme)
- [5. URI Scheme Definition](#5-uri-scheme-definition)
- [6. Syntax](#6-syntax)
- [7. Authority, Ownership, and Uniqueness](#7-authority-ownership-and-uniqueness)
- [8. TEI Type System](#8-tei-type-system)
- [9. Identifier Encoding](#9-identifier-encoding)
- [10. Canonicalization](#10-canonicalization)
- [11. Query Parameters](#11-query-parameters)
- [12. Semantics](#12-semantics)
- [13. Resolution Model](#13-resolution-model)
- [14. Interoperability Considerations](#14-interoperability-considerations)
- [15. Security Considerations](#15-security-considerations)
- [16. IANA Considerations](#16-iana-considerations)
- [17. References](#17-references)

---

## 1. Introduction

The **Transparency Exchange Identifier (TEI)** defines a URI-based mechanism for identifying software products and components within the Transparency Exchange API (TEA).

TEI is designed to provide a **stable, globally unique, and transport-independent identifier** that integrates naturally with DNS-based discovery and modern software supply chain systems.

Unlike location-based identifiers such as URLs, TEI separates:

- **identity** (what something is)  
- **location** (where it is hosted)  
- **validation** (whether it is trustworthy)  

This separation is fundamental to enabling long-term validation and resilience in distributed ecosystems.

---

## 2. Background and Design Intent

Modern software ecosystems already rely on multiple identifier systems:

- Package URLs (purl)  
- SWID tags  
- commercial product identifiers (GTIN, EAN, etc.)  
- internal product identifiers  

However, these identifiers lack:

- a unified resolution model  
- DNS-based ownership  
- integration with transparency and trust systems  

TEI addresses this by:

- **reusing existing identifiers**
- **binding them to a DNS authority**
- **providing a deterministic URI representation**

A key design constraint is:

> TEI MUST NOT introduce a new identifier ecosystem.

Instead, it standardizes how existing identifiers are **represented, transported, and resolved**.

---

## 3. Identifier Reuse Policy

### 3.1 General Principle

TEI is explicitly designed to reuse existing identifiers.

A TEI MUST contain:

- an identifier already assigned by the manufacturer, OR  
- an identifier from an established ecosystem  

TEI implementations MUST NOT require new identifiers if a suitable one exists.

---

### 3.2 Preferred Identifiers

Manufacturers SHOULD use:

- Package URL (purl)  
- SWID  
- GTIN / EAN / UPC  
- existing internal identifiers (if stable and unique)  

---

### 3.3 UUID Fallback

If no suitable identifier exists:

```text
A UUID MUST be generated and used with type "uuid".
```

UUIDs MUST:

- conform to RFC 4122  
- be stable over time  

---

### 3.4 Stability Requirement

Identifiers used in TEI:

- MUST be stable  
- MUST uniquely identify a product or component  
- MUST NOT change across releases  

---

### 3.5 Namespace Responsibility

When using identifiers from external namespaces:

- the manufacturer MUST ensure they are authorized to use them  
- required registrations MUST be performed  

TEI does not enforce or validate namespace ownership.

---

### 3.6 Non-Goals

TEI does not:

- define a new identifier system  
- validate identifier ownership  
- act as a registry authority  

---

## 4. Rationale for a New URI Scheme

Existing approaches were evaluated:

| Approach | Limitation |
|--------|-----------|
| HTTPS URLs | Bind identity to location |
| URNs | No DNS-based ownership |
| Raw identifiers | No unified resolution |

TEI introduces:

- DNS authority as identity root  
- separation of identity and location  
- integration with TEA discovery  

---

## 5. URI Scheme Definition

The TEI scheme is:

```text
tei
```

General form:

```text
tei://<authority>/<type>/<identifier>[?query]
```

This structure reflects:

- authority → ownership  
- type → identifier system  
- identifier → canonical value  

---

## 6. Syntax

```abnf
tei-uri     = "tei://" authority "/" type "/" identifier [ "?" query ]

authority   = host

type        = 1*( ALPHA / DIGIT / "-" )

identifier  = 1*( ALPHA / DIGIT / "-" / "_" )

query       = query-param *( "&" query-param )
```

---

## 7. Authority, Ownership, and Uniqueness

The authority component:

- MUST be a valid DNS domain  
- defines the namespace of the identifier  
- MUST correspond to the TEA discovery domain  

---

### 7.1 Identifier Uniqueness (Normative)

```text
For a given authority, the combination of <type> and <identifier> MUST uniquely identify a single product or component.
```

---

### 7.2 Scope of Identity

```text
TEI identity = authority + type + identifier
```

The `version` parameter does not affect identity.

---

### 7.3 Responsibility

The authority owner MUST:

- ensure uniqueness  
- prevent collisions  
- maintain identifier stability  

---

### 7.4 Design Implication

This model enables:

- decentralized identifier management  
- no global registry requirement  
- compatibility with DNS delegation  

---

## 8. TEI Type System

### 8.1 Design Principle

TEI types exist solely to enable reuse of existing identifier ecosystems.

---

### 8.2 Defined Types

| Type | Description |
|------|------------|
| purl | Package URL |
| swid | SWID |
| hash | Cryptographic hash |
| uuid | UUID (fallback) |
| eanupc | EAN/UPC |
| gtin | GTIN |
| asin | ASIN |

---

### 8.3 Governance

TEI types are governed by the TEA working group (TC54 TG1).

```text
Manufacturers MUST NOT introduce new TEI types.
```

```text
TEI implementations MUST reject undefined types.
```

---

### 8.4 Extensibility

New types:

- MUST be defined by TC54 TG1  
- MUST include canonicalization rules  
- SHOULD reference external standards  

---

## 9. Identifier Encoding

Identifiers are encoded using:

> base64url encoding (RFC 4648, Section 5)

---

### Rules

- input MUST be canonical UTF-8  
- padding MUST NOT be used  
- encoding MUST be deterministic  

---

### Normative Statement

```text
The identifier MUST be the base64url encoding of the canonical UTF-8 representation of the identifier.
```

---

## 10. Canonicalization

Canonicalization ensures deterministic identity.

---

### General Rules

- UTF-8 encoding  
- no whitespace  
- stable representation  

---

### Type-Specific Rules

#### purl

MUST follow purl canonical form.

#### uuid

- lowercase  
- RFC 4122 compliant  

#### hash

```text
<algorithm>:<value>
```

---

### Equality

Two TEIs are equal if all components match after normalization.

---

## 11. Query Parameters

### version

```text
?version=<string>
```

- OPTIONAL  
- applies only to products  
- does not affect identity  

---

## 12. Semantics

A TEI identifies:

- a product  
- or a component  

It does not identify:

- artifacts  
- locations  

---

## 13. Resolution Model

TEIs are not directly dereferenceable.

```text
TEI → DNS → discovery → API → data
```

This ensures separation of:

- identity  
- location  
- trust  

---

## 14. Interoperability Considerations

Implementations MUST:

- canonicalize before encoding  
- use base64url without padding  

---

### Case Rules

| Component | Rule |
|----------|------|
| scheme | insensitive |
| authority | insensitive |
| type | sensitive |
| identifier | sensitive |

---

### Consistency Requirement

Equivalent identifiers MUST produce identical TEIs.

---

## 15. Security Considerations

TEI itself provides no trust guarantees.

Trust is established through:

- TEA trust architecture  
- signatures  
- timestamps  
- transparency systems  

---

### Risks

- authority spoofing  
- homograph attacks  
- encoding inconsistencies  

---

## 16. IANA Considerations

- Scheme: `tei`  
- Status: provisional  
- Applications: TEA  
- Contact: TEA / CycloneDX  
- Change controller: TEA maintainers  

---

## 17. References

- RFC 3986 — URI Syntax  
- RFC 4648 — Base64url  
- RFC 4122 — UUID  
- RFC 7595 — URI Scheme Registration  

---