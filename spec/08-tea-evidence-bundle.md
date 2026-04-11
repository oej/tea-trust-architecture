# 📘 TEA Trust Architecture — Evidence Bundle Specification
**Version:** 1.0  
**Status:** Draft (Normative, Implementation-Ready)

---

## Status

This document defines the **evidence bundle** used in the TEA Trust Architecture.

The evidence bundle is the **core unit of trust** for TEA artifacts.

It enables:

- long-term validation  
- offline verification  
- independence from external services  

The key words **MUST**, **SHOULD**, and **MAY** are to be interpreted as described in:

- RFC 2119  
- RFC 8174  

This document is intended to be used together with:

- TEA Evidence Validation Specification  
- TEA X.509 Profile  
- RFC 3161 (Time-Stamp Protocol)  

---

## Table of Contents

1. [Purpose](#1-purpose)  
2. [Scope](#2-scope)  
3. [Design Principles](#3-design-principles)  
4. [What Is an Evidence Bundle](#4-what-is-an-evidence-bundle)  
5. [Structure](#5-structure)  
6. [Signature Model](#6-signature-model)  
7. [Algorithm Requirements](#7-algorithm-requirements)  
8. [Timestamp Evidence](#8-timestamp-evidence)  
9. [Transparency Evidence](#9-transparency-evidence)  
10. [Binding Rules](#10-binding-rules)  
11. [Reuse Model](#11-reuse-model)  
12. [Encoding and Canonicalization](#12-encoding-and-canonicalization)  
13. [Transport and API Integration](#13-transport-and-api-integration)  
14. [Validation Requirements](#14-validation-requirements)  
15. [Security Considerations](#15-security-considerations)  
16. [Normative References](#16-normative-references)  
17. [Informative References](#17-informative-references)  
18. [Final Statement](#18-final-statement)  

---

## 1. Purpose

The evidence bundle provides **all cryptographic material required to verify a TEA artifact**.

It ensures that validation can be performed:

- without contacting external systems  
- long after certificate expiration  
- independent of infrastructure availability  

---

## 2. Scope

This specification applies to:

- TEA artifacts (primary use)  
- TEA collections (optional)  
- discovery documents (optional)  

---

## 3. Design Principles

### 3.1 Evidence Over Infrastructure

Trust is derived from:

- signatures  
- timestamps  
- transparency  

NOT from:

- live services  
- persistent keys  

---

### 3.2 Artifact-Centric Model

An evidence bundle is bound to:

> a single TEA artifact

It MAY be reused across multiple collections.

---

### 3.3 Immutability

Once created, an evidence bundle:

- MUST NOT change  
- MUST remain valid indefinitely  

---

### 3.4 Single Identity

The same key identity is used across:

- signing  
- timestamp binding  
- transparency logging  

---

## 4. What Is an Evidence Bundle

An evidence bundle is a structured object containing:

- the signature over the artifact  
- the signing certificate (containing the public key)  
- timestamp evidence  
- transparency log evidence  

The signature is created using the **private key**, while the certificate contains the corresponding public key.

---

## 5. Structure

Example (informative):

```json
{
  "signature": {
    "algorithm": "Ed25519",
    "value": "<base64-signature>"
  },
  "certificate": "<base64-der>",
  "timestamps": [
    {
      "type": "rfc3161",
      "token": "<base64>"
    }
  ],
  "transparency": [
    {
      "system": "sigsum",
      "logId": "<id>",
      "inclusionProof": "<proof>",
      "checkpoint": "<signed-tree-head>",
      "witnessSignatures": [
        "<sig1>",
        "<sig2>"
      ]
    }
  ]
}
```

---

## 6. Signature Model

The signature:

- MUST be computed using the private key  
- MUST be over the raw artifact bytes  
- MUST be included in the evidence bundle  

Detached signatures MAY exist externally, but:

> the evidence bundle contains the authoritative signature  

---

## 7. Algorithm Requirements

### 7.1 Signature Algorithm

```text
Ed25519
```

Defined in:

- RFC 8032  
- RFC 8410  

---

### 7.2 Hash Algorithm

```text
SHA-256
```

Defined in:

- RFC 6234  

---

### 7.3 Enforcement

Any other algorithm:

> MUST result in validation failure  

---

## 8. Timestamp Evidence

Evidence bundles MUST include:

- at least one RFC 3161 timestamp  

Defined in:

- RFC 3161  

---

### 8.1 Binding Rule

```text
messageImprint = SHA-256(signature)
```

---

### 8.2 Rationale

The timestamp proves:

> the signature existed during certificate validity  

---

## 9. Transparency Evidence

### 9.1 Requirement Level

Transparency evidence:

- OPTIONAL in baseline deployments  
- SHOULD be present in TEA-native deployments  
- REQUIRED in high-assurance profiles  

---

### 9.2 Supported Systems

TEA supports multiple transparency systems:

- **Sigsum** (RECOMMENDED)  
- **Rekor (Sigstore)** (ALLOWED)  
- **SCITT (IETF)** (FUTURE)  

TEA does not depend on a single system.

---

### 9.3 Sigsum

Sigsum provides:

- Ed25519-based identity  
- log signatures  
- witness-based consistency  

Evidence SHOULD include:

- inclusion proof  
- checkpoint  
- witness signatures  

Reference:

- https://www.sigsum.org  

---

### 9.4 Rekor (Sigstore)

Rekor provides:

- Merkle tree transparency  
- inclusion proofs  
- signed tree heads  

Evidence MAY include:

- entry UUID  
- inclusion proof  
- signed tree head  

References:

- https://rekor.sigstore.dev  
- https://www.sigstore.dev  

---

### 9.5 SCITT (IETF)

SCITT provides:

- signed receipts  
- COSE-based evidence  

Reference:

- https://datatracker.ietf.org/wg/scitt/about/  

---

### 9.6 Binding Rule (Critical)

Transparency MUST bind to:

```text
SHA-256(signature)
```

or:

```text
SHA-256(timestamped_signature)
```

---

## 10. Binding Rules

The evidence chain:

```text
artifact → signature → timestamp → transparency
```

All bindings MUST match.

---

## 11. Reuse Model

Evidence bundles:

- MAY be reused across collections  
- MUST NOT be modified  

---

## 12. Encoding and Canonicalization

Evidence bundles are JSON.

Canonicalization MUST follow:

- RFC 8785 (JCS)

---

## 13. Transport and API Integration

Artifacts MAY be delivered as:

- artifact only  
- artifact + signature (multipart)  
- artifact + evidence bundle (multipart)  

---

## 14. Validation Requirements

Consumers MUST verify:

- signature  
- certificate  
- timestamp  
- transparency (if present)  
- binding chain  

---

## 15. Security Considerations

- supports long-term validation  
- minimizes key exposure  
- transparency provides auditability  
- Ed25519 simplifies implementation  

---

## 16. Normative References

- RFC 2119  
- RFC 8174  
- RFC 8032 (Ed25519)  
- RFC 8410 (Ed25519 in X.509)  
- RFC 6234 (SHA-256)  
- RFC 3161 (Timestamping)  
- RFC 8785 (JSON Canonicalization)  

---

## 17. Informative References

- Sigsum — https://www.sigsum.org  
- Rekor — https://rekor.sigstore.dev  
- Sigstore — https://www.sigstore.dev  
- SCITT — https://datatracker.ietf.org/wg/scitt/about/  

---

## 18. Final Statement

The evidence bundle transforms:

> ephemeral cryptographic events  
into  
> durable, verifiable proof  

---

### Key Principle

> Trust is derived from consistent, independent evidence — not from persistent keys or infrastructure.
