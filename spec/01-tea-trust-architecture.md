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
- collections  
- artifact distribution  

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
| Collections | REQUIRED | REQUIRED |
| Artifact signatures | OPTIONAL | REQUIRED (profile-dependent) |
| Timestamps | OPTIONAL | REQUIRED |
| Evidence bundles | NOT DEFINED | REQUIRED |
| Transparency | OPTIONAL | PROFILE-DEPENDENT |
| DNS trust anchors | OPTIONAL | REQUIRED (TEA-native) |

---

## 3. Terminology

- **TEA artifact**: A binary or structured object (e.g. SBOM, firmware)
- **TEA collection**: A release definition binding artifacts together
- **Evidence bundle**: A structured object containing:
  - signature  
  - certificate  
  - timestamp(s)  
  - optional transparency evidence  
- **TAPS**: Trust Anchor Publication Service (DNS-based distribution)
- **TEI**: Transparency Exchange Identifier

---

## 4. Architecture Overview

The architecture consists of three domains:

1. **Discovery trust**  
2. **Consumer trust**  
3. **Publication trust**

Each domain addresses a different question:

| Domain | Question |
|--------|----------|
| Discovery | Where is the correct TEA service? |
| Consumer | Is this artifact valid and authentic? |
| Publication | Was this release intentionally published? |

---

## 5. Trust Model

Trust is derived from **independent evidence sources**:

- signature  
- timestamp  
- transparency log  
- DNS or PKI trust anchor  

> No single component defines trust.

Consistency across these sources establishes trust.

---

## 6. Evidence Model

### 6.1 Evidence bundle as trust unit

> The evidence bundle is the primary unit of trust.

It binds:

```text
object → signature → timestamp → transparency
```

---

### 6.2 Evidence contents

An evidence bundle MUST include:

- signature  
- certificate (public key)  
- at least one timestamp  

It MAY include:

- transparency log entries (Sigsum, Rekor, SCITT)

---

### 6.3 Detached evidence

Evidence bundles MAY be:

- embedded  
- referenced externally  

If external, the collection MUST include:

```text
SHA-256 digest of the evidence bundle
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

NOT:

- raw artifact  
- raw collection  

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

- correct API endpoint  
- authorized delegation  

Requires:

- TLS  
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

### 9.1 Algorithm

- Ed25519 ONLY  

### 9.2 Digest

- SHA-256 ONLY  

---

### 9.3 Identity

```text
identity = SHA-256(public key)
```

---

### 9.4 Key usage

- one key pair per signing event  
- key reuse is prohibited  

---

## 10. Timestamp Model

### 10.1 Purpose

Timestamps provide:

- proof of signing time  
- ordering  
- long-term validation  

---

### 10.2 Requirements

- MUST be trusted (validated via CA trust store)  
- MUST bind to signature  
- SHOULD use multiple TSAs  

---

### 10.3 Rationale

Long-term trust depends on:

> evidence of *when* something was signed, not just *who* signed it

---

## 11. Transparency Model

### 11.1 Supported systems

- Sigsum  
- Rekor  
- SCITT (optional)  

---

### 11.2 Role

Transparency provides:

- auditability  
- tamper detection  
- publication evidence  

---

### 11.3 Policy

- transparency is OPTIONAL  
- REQUIRED in high-assurance profiles  

---

## 12. DNS and Trust Anchoring

### 12.1 TEA-native (TAPS)

- certificates MUST be published in DNS  
- DNSSEC is OPTIONAL but recommended  

---

### 12.2 WebPKI

- DNS MUST NOT be used as trust anchor  
- DNS MAY provide CAA policy  

---

## 13. Artifact vs Collection Semantics

### 13.1 TEA artifact

Represents:

- exact binary content  

Authenticity comes from:

- evidence bundle  

---

### 13.2 TEA collection

Represents:

- release composition  

Does NOT prove artifact authenticity.

---

## 14. Evidence Reuse Rules

### 14.1 Artifact evidence

Artifact evidence bundles:

- MAY be reused  
- MAY appear in multiple collections  

---

### 14.2 Collection evidence

Collection evidence:

- MUST NOT be reused  
- is unique per collection version  

---

### 14.3 Rationale

Artifacts are immutable objects.

Collections are contextual statements.

---

## 15. Publication Model

### 15.1 Workflow

1. Build artifacts  
2. Sign artifacts  
3. Create evidence bundles  
4. Assemble collection  
5. Commit (authoritative step)  

---

### 15.2 Commit step

The commit step MUST:

- require strong authentication  
- validate evidence  
- enforce trust model  
- optionally publish DNS trust anchors  

---

### 15.3 Key property

> CI/CD prepares — humans authorize — TEA commits

---

## 16. CI/CD Authentication and Authorization

TEA services MUST support:

- short-lived credentials  
- OIDC-based authentication  
- bearer tokens  

---

### 16.1 Requirements

- tokens MUST be bound to job identity  
- tokens MUST be short-lived  
- actions MUST be authorized  

---

## 17. Messaging and Logging Requirements

### 17.1 Requirements

TEA services MUST log:

- signing events  
- timestamp acquisition  
- transparency submissions  
- commit actions  

---

### 17.2 Audit properties

Logs MUST be:

- tamper-evident  
- time-stamped  
- attributable  

---

### 17.3 Messaging

Publication workflows SHOULD emit events for:

- artifact creation  
- evidence generation  
- commit completion  

---

## 18. Security Properties

This architecture provides:

- resistance to key compromise (short-lived keys)  
- no reliance on revocation  
- long-term verifiability  
- distributed trust  
- offline validation  

---

## 19. Implementation Guidance

Implementations SHOULD:

- store artifact + evidence + digest  
- prevent key reuse  
- support multipart artifact delivery:
  - artifact only  
  - artifact + signature  
  - artifact + evidence bundle  

---

## 20. Normative References

- RFC 2119 / RFC 8174  
- RFC 5280 — X.509  
- RFC 3161 — Time-Stamp Protocol  
- RFC 8785 — JSON Canonicalization  
- RFC 4033/4034/4035 — DNSSEC  
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
- IETF SCITT  

---

## Final Statement

The TEA Trust Architecture establishes a model where:

> **Trust is not granted — it is constructed from verifiable evidence.**

It ensures that:

- artifacts are authentic  
- releases are intentional  
- validation remains possible for decades  

without relying on:

- long-lived keys  
- centralized trust  
- revocation infrastructure  
