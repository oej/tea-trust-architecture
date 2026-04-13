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

1. Introduction  
2. Relationship to TEA Core  
3. Terminology  
4. Architecture Overview  
5. Trust Model  
6. Evidence Model  
7. Evidence Binding Rules  
8. Trust Domains  
9. Cryptographic Model  
10. Timestamp Model  
11. Transparency Model  
12. DNS and Trust Anchoring  
13. Artifact vs Collection Semantics  
14. Evidence Reuse Rules  
15. Publication Model  
16. CI/CD Authentication and Authorization  
17. Messaging and Logging Requirements  
18. Security Properties  
19. Implementation Guidance  
20. Normative References  
21. Informative References  

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

### 5.1 TLS Identity Is Not a Trust Input

The TEA Trust Architecture establishes trust based on:

- signatures  
- signing certificates  
- timestamps  
- transparency evidence  
- DNS-based trust anchoring (where applicable)  

Information obtained from TLS connections during discovery, including:

- certificate subject fields (e.g. `O`, `CN`)  
- Extended Validation (EV) attributes  
- any certificate-presented organizational identity  

MUST NOT be used as part of TEA trust validation.

#### Rationale

TLS certificates provide:

```
Transport security (confidentiality and integrity)
```

However:

- WebPKI identity validation is not uniform  
- organization names are not globally unique  
- certificates are frequently reissued  
- private PKIs may assert arbitrary identity  

Therefore:

```
TLS identity is a contextual signal for humans, not a trust anchor
```

#### Allowed Usage

A client MAY:

- record TLS identity fields  
- present them to users  
- use them for anomaly detection  

Only when the certificate chains to a trusted public WebPKI root.

#### Prohibited Usage

A client MUST NOT:

- use TLS identity for trust decisions  
- replace TEA signing validation  
- use TLS identity in automated validation  

#### Separation of Concerns

```
TLS = transport security  
TEA = artifact trust
```

---

## 6. Evidence Model

### 6.1 Evidence bundle as trust unit

The **evidence bundle** is the primary unit of trust.

It binds:

```
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

```
SHA-256 digest over canonical JSON (RFC 8785)
```

---

## 7. Evidence Binding Rules

### 7.1 Signature binding

The signature MUST cover:

- exact bytes of the object  

---

### 7.2 Timestamp binding

The timestamp MUST bind to:

```
hash(signature)
```

---

### 7.3 Certificate validity

```
timestamp ∈ [cert.notBefore, cert.notAfter]
```

---

### 7.4 Transparency binding

Transparency MUST refer to:

- signature OR  
- timestamped signature  

Mismatch MUST fail validation.

---

## 8. Trust Domains

### 8.1 Discovery trust

Requires:

- TLS (confidentiality + integrity)  
- signature  
- timestamp  

---

### 8.2 Consumer trust

Validates:

- artifacts  
- collections  
- evidence bundles  

---

### 8.3 Publication trust

Ensures:

- intentional release  
- authorized publication  

---

## 9. Cryptographic Model

- Algorithm: **Ed25519 ONLY**  
- Digest: **SHA-256 ONLY**  

Identity:

```
SHA-256(public key)
```

Key pairs MUST NOT be reused.

Implementations MUST:

- prevent reuse of known fingerprints  
- reject reuse attempts  

---

## 10. Timestamp Model

Timestamps provide:

- proof of existence  
- ordering  
- long-term validity  

Requirements:

- MUST bind to signature  
- MUST be validated  
- SHOULD use multiple TSAs  

---

## 11. Transparency Model

### 11.1 Overview

Transparency ensures:

- append-only logging  
- auditability  
- equivocation detection  

Supported:

- Sigsum  
- Rekor  

---

### 11.1.1 Publisher

MUST include:

- Sigsum OR Rekor  

---

### 11.1.2 Consumer

MUST support:

- Sigsum  
- Rekor  

---

### 11.1.3 TEA Services

MUST support:

- Sigsum  
- Rekor  

---

### 11.1.4 Validation

- At least one valid receipt REQUIRED  
- All SHOULD be validated  

---

### 11.2 SCITT

- MAY be included  
- MUST NOT be sole mechanism  

---

## 12. DNS and Trust Anchoring

### 12.1 TEA-native

- DNS CERT records REQUIRED  
- DNSSEC OPTIONAL  

---

### 12.2 WebPKI

- DNS not trust anchor  
- CAA MAY be used  

When WebPKI is used:

> evidence bundles MUST NOT be included

---

## 13. Artifact vs Collection Semantics

Artifact:

- immutable  
- proven by evidence  

Collection:

- contextual  
- does not prove artifact authenticity  

---

## 14. Evidence Reuse Rules

Artifact evidence:

- MAY be reused  

Scope:

> ONLY artifacts (including compliance documents)

Collection evidence:

- MUST NOT be reused  

---

## 15. Publication Model

1. Build  
2. Generate evidence  
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
- SHOULD support OIDC  
- MUST enforce boundaries  

---

## 17. Messaging and Logging Requirements

MUST log:

- signing  
- timestamping  
- transparency  
- commit  

Logs MUST be:

- tamper-evident  
- time-bound  
- attributable  

---

## 18. Security Properties

Provides:

- no revocation dependency  
- short-lived keys  
- long-term validation  
- offline verification  

---

## 19. Implementation Guidance

SHOULD:

- store artifact + evidence + digest  
- prevent key reuse  
- support multipart delivery  

---

## 20. Normative References

- RFC 2119 / 8174  
- RFC 5280  
- RFC 3161  
- RFC 8785  
- RFC 4033–4035  
- RFC 8659  

---

## 21. Informative References

- https://github.com/CycloneDX/transparency-exchange-api  
- https://www.sigsum.org/  
- https://github.com/sigstore/rekor  
- https://datatracker.ietf.org/wg/scitt/documents/  

---

## Final Statement

> Trust is constructed from verifiable, independent evidence.

This enables:

- durable validation  
- supply chain integrity  
- audit readiness  

without reliance on:

- long-lived keys  
- centralized trust  
- revocation systems
