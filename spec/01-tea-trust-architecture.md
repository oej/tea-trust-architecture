# 📘 TEA Trust Architecture Core Specification
**Version:** 1.0  
**Status:** Draft (Normative, RFC-style)

---

## Status

This document defines the **TEA Trust Architecture**, an optional overlay to the core TEA specification.

The TEA Trust Architecture introduces:

- cryptographic signatures  
- timestamps  
- transparency evidence  
- DNS-based trust anchoring  
- evidence bundles as first-class trust objects  

It enables:

- long-term validation (≥10 years)  
- offline verification  
- strong supply chain integrity guarantees  

This document is **normative** for implementations claiming compliance with:

> **“TEA with the trust architecture”**

---

## Table of Contents

1. [Introduction](#1-introduction)  
2. [Relationship to TEA Core](#2-relationship-to-tea-core)  
3. [Terminology](#3-terminology)  
4. [Architecture Overview](#4-architecture-overview)  
5. [Trust Model](#5-trust-model)  
6. [Evidence Model](#6-evidence-model)  
7. [Evidence Binding Rules](#7-evidence-binding-rules)  
8. [Trust Domains](#8-trust-domains)  
9. [Cryptographic Model](#9-cryptographic-model)  
10. [Timestamp Model](#10-timestamp-model)  
11. [Transparency Model](#11-transparency-model)  
12. [DNS and Trust Anchoring](#12-dns-and-trust-anchoring)  
13. [Artifact vs Collection Semantics](#13-artifact-vs-collection-semantics)  
14. [Evidence Reuse Rules](#14-evidence-reuse-rules)  
15. [Publication Model](#15-publication-model)  
16. [CI/CD Authentication and Authorization](#16-cicd-authentication-and-authorization)  
17. [Messaging and Logging Requirements](#17-messaging-and-logging-requirements)  
18. [Security Properties](#18-security-properties)  
19. [Implementation Guidance](#19-implementation-guidance)  
20. [Normative References](#20-normative-references)  
21. [Informative References](#21-informative-references)  

---

## 1. Introduction

The TEA Trust Architecture extends TEA from a **data exchange model** to a **verifiable trust system**.

Core TEA defines:

- APIs  
- TEA collections  
- TEA artifact distribution  

The Trust Architecture adds:

> **cryptographic evidence that remains verifiable over time**

This is required to meet regulatory expectations such as:

- EU Cyber Resilience Act (CRA)  
- long-term SBOM retention  
- auditability requirements  

---

## 2. Relationship to TEA Core

This specification is an **overlay**.

| Feature | TEA Core | TEA with Trust Architecture |
|--------|----------|-----------------------------|
| TEA collections | REQUIRED | REQUIRED |
| Artifact signatures | OPTIONAL | REQUIRED (profile-dependent) |
| Timestamps | OPTIONAL | REQUIRED |
| Evidence bundles | NOT DEFINED | REQUIRED |
| Transparency | OPTIONAL | REQUIRED |
| DNS trust anchors | OPTIONAL | REQUIRED (TEA-native) |

---

## 3. Terminology

- **TEA artifact**: A binary or structured object (e.g. SBOM, firmware)  
- **TEA collection**: A release definition binding artifacts together  
- **Evidence bundle**: A structured object containing:
  - signature  
  - certificate  
  - timestamp(s)  
  - transparency evidence  
- **TAPS**: Trust Anchor Publication Service  
- **TEI**: Transparency Exchange Identifier  

---

## 4. Architecture Overview

The TEA Trust Architecture consists of three domains:

1. **Discovery trust**
2. **Consumer trust**
3. **Publication trust**

Each domain answers a distinct question:

| Domain | Question |
|--------|----------|
| Discovery | Am I talking to the correct TEA service? |
| Consumer | Can I trust the artifacts and release? |
| Publication | Was this release intentionally published? |

---

## 5. Trust Model

Trust is derived from **independent evidence sources**:

- signature  
- timestamp  
- transparency logs  
- DNS or PKI trust anchors  

> Trust emerges from consistency across these sources.

No single component is sufficient on its own.

---

## 6. Evidence Model

### 6.1 Evidence bundle as trust unit

The **evidence bundle** is the primary unit of trust.

It binds:

```text
object → signature → timestamp → transparency
```

---

### 6.2 Evidence contents

An evidence bundle MUST include:

- signature  
- certificate  
- at least one timestamp  
- at least one transparency receipt (Sigsum or Rekor)

SCITT MAY be included as additional evidence.

---

### 6.3 Detached evidence

Evidence bundles MAY be:

- embedded  
- externally referenced  

External references MUST include:

```text
SHA-256 digest over canonical JSON (RFC 8785)
```

---

## 7. Evidence Binding Rules

### 7.1 Signature binding

The signature MUST cover:

- the exact bytes of the object  

---

### 7.2 Timestamp binding

The timestamp MUST bind to:

```text
hash(signature)
```

---

### 7.3 Certificate validity

The timestamp MUST satisfy:

```text
timestamp ∈ [cert.notBefore, cert.notAfter]
```

---

### 7.4 Transparency binding

Transparency evidence MUST refer to:

- the signature OR  
- the timestamped signature  

Mismatch MUST result in validation failure.

---

## 8. Trust Domains

### 8.1 Discovery trust

Establishes:

- correct TEA API endpoints  
- authorized delegation  

Requires:

- TLS (transport confidentiality and integrity)  
- signature  
- timestamp (REQUIRED)  

---

### 8.2 Consumer trust

Validates:

- TEA artifacts  
- TEA collections  
- evidence bundles  

---

### 8.3 Publication trust

Ensures:

- releases are intentional  
- publication is authorized  

---

## 9. Cryptographic Model

- Algorithm: **Ed25519 ONLY**  
- Digest: **SHA-256 ONLY**  

Identity is defined as:

```text
SHA-256(public key)
```

Key pairs MUST NOT be reused.

---

## 10. Timestamp Model

Timestamps provide:

- proof of existence in time  
- ordering  
- long-term validation  

Requirements:

- MUST bind to signature  
- MUST be validated  
- SHOULD use multiple TSAs  

---

## 11. Transparency Model

### 11.1 Transparency Model (Normative)

The TEA Trust Architecture relies on transparency systems to provide:

- proof of publication  
- append-only guarantees  
- detection of equivocation  
- auditability  

Supported systems:

- Sigsum  
- Rekor  

---

### 11.1.1 Publisher requirements

A publisher implementation:

- MUST include at least one transparency receipt in every evidence bundle  
- MUST use:
  - Sigsum OR  
  - Rekor  

Publishers MAY include both.

---

### 11.1.2 Consumer requirements

A consumer implementation:

- MUST support validation of:
  - Sigsum  
  - Rekor  

Consumers MUST be able to validate any compliant TEA publication.

---

### 11.1.3 TEA service requirements

A TEA service:

- MUST support validation of both:
  - Sigsum  
  - Rekor  

This ensures interoperability across ecosystems and CI/CD toolchains.

---

### 11.1.4 Validation rule

- At least one valid transparency receipt MUST be verified  
- All recognized receipts SHOULD be validated  

If no valid Sigsum or Rekor evidence exists:

→ validation MUST fail  

---

### 11.2 Future extensibility (SCITT)

SCITT is recognized as a future transparency mechanism.

- MAY be included as additional evidence  
- MUST NOT be the sole transparency mechanism  

---

## 12. DNS and Trust Anchoring

### 12.1 TEA-native (TAPS)

- Certificates MUST be published in DNS  
- DNSSEC is OPTIONAL but RECOMMENDED  

---

### 12.2 WebPKI

- DNS MUST NOT be used as a trust anchor  
- DNS MAY support CAA policy  
- DNSSEC strengthens CAA validation  

---

## 13. Artifact vs Collection Semantics

### TEA artifact

- Represents exact content  
- Authenticity comes from evidence bundle  

### TEA collection

- Represents release composition  
- Does NOT prove artifact authenticity  

---

## 14. Evidence Reuse Rules

### Artifact evidence

- MAY be reused  
- MAY appear in multiple collections  

### Collection evidence

- MUST NOT be reused  

---

## 15. Publication Model

Workflow:

1. Build artifacts  
2. Generate evidence bundles  
3. Assemble collection  
4. Commit  

Commit MUST:

- validate evidence  
- enforce key uniqueness  
- require authorization  
- freeze release  

---

## 16. CI/CD Authentication and Authorization

- MUST support short-lived credentials  
- SHOULD support OIDC-based authentication  
- MUST enforce authorization boundaries  

---

## 17. Messaging and Logging Requirements

TEA services MUST log:

- signing events  
- timestamp acquisition  
- transparency submissions  
- commit actions  

Logs MUST be:

- tamper-evident  
- time-bound  
- attributable  

---

## 18. Security Properties

This architecture provides:

- short-lived key exposure  
- no revocation dependency  
- long-term validation  
- distributed trust  
- offline verification  

---

## 19. Implementation Guidance

Implementations SHOULD:

- store artifact + evidence + digest  
- prevent key reuse  
- support multipart delivery:
  - artifact only  
  - artifact + signature  
  - artifact + evidence  

---

## 20. Normative References

- RFC 2119 / RFC 8174  
- RFC 5280 — X.509  
- RFC 3161 — Time-Stamp Protocol  
- RFC 8785 — JSON Canonicalization  
- RFC 4033–4035 — DNSSEC  
- RFC 8659 — CAA  

---

## 21. Informative References

- TEA Core Specification  
- TEA Evidence Bundle Specification  
- TEA Evidence Validation Specification  
- TEA Discovery Specification  
- TEA X.509 Profile  
- Sigsum Documentation  
- Rekor Documentation  

---

## Final Statement

The TEA Trust Architecture establishes a system where:

> **Trust is constructed from verifiable, independent evidence.**

It ensures that:

- artifacts are authentic  
- releases are intentional  
- validation remains possible over decades  

without relying on:

- long-lived keys  
- centralized trust  
- revocation infrastructure  
