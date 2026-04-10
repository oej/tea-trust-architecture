# 📘 TEA Evidence Bundle Specification
**Version:** 1.0  
**Status:** Draft (Normative, Implementation-Ready)

---

# Table of Contents

1. [Introduction](#1-introduction)  
2. [Purpose](#2-purpose)  
3. [Scope](#3-scope)  
4. [Core Design Principles](#4-core-design-principles)  
5. [Evidence Model](#5-evidence-model)  
6. [Bundle Structure](#6-bundle-structure)  
7. [Object](#7-object)  
8. [Signature](#8-signature)  
9. [Certificate](#9-certificate)  
10. [Timestamps](#10-timestamps)  
11. [Transparency Evidence](#11-transparency-evidence)  
12. [Digest Algorithm and Canonicalization](#12-digest-algorithm-and-canonicalization)  
13. [Binding Rules (Normative)](#13-binding-rules-normative)  
14. [Validation Model](#14-validation-model)  
15. [Reuse Rules](#15-reuse-rules)  
16. [Profiles](#16-profiles)  
17. [Error Handling](#17-error-handling)  
18. [Extensibility](#18-extensibility)  
19. [Rationale](#19-rationale)  

---

# 1. Introduction

The TEA Evidence Bundle defines how cryptographic evidence associated with a signed object is packaged, transported, and validated.

It is the **primary unit of trust** in the TEA trust architecture.

An evidence bundle encapsulates:

- the digital signature  
- the signing certificate  
- timestamp evidence  
- transparency evidence  
- optional validation material  

---

# 2. Purpose

Modern software supply chain systems rely on:

- short-lived signing keys  
- short-lived certificates  
- distributed trust anchors  

This creates a challenge:

> How to validate signatures long after keys and certificates no longer exist.

The TEA Evidence Bundle preserves:

- proof of what was signed  
- proof of who signed it  
- proof of when it was signed  
- proof of public visibility  

---

# 3. Scope

An evidence bundle applies to a **single TEA artifact**.

Examples:

- SBOM  
- binary artifact  
- VEX  
- attestation  

---

## 3.1 Scope Restriction

Evidence bundles defined in this specification:

- MUST refer to TEA artifacts  
- MUST NOT be reused for:
  - TEA collections  
  - discovery documents  

---

# 4. Core Design Principles

## 4.1 Atomic Trust Object

The evidence bundle is the **atomic unit of trust**.

All validation MUST be performed using the bundle.

---

## 4.2 Detached but Bound

The bundle does not replace the artifact.

- artifact → authoritative content  
- bundle → validation evidence  

---

## 4.3 Offline Validation

Bundles SHOULD contain sufficient information for validation without:

- contacting TSA  
- contacting transparency services  
- retrieving certificates externally  

---

## 4.4 No Implicit Trust

The bundle does not establish trust by itself.

Trust decisions require policy evaluation.

---

# 5. Evidence Model

The validation chain is:

```text
artifact ↔ evidence bundle
              ├─ signature
              ├─ certificate
              ├─ timestamp(s)
              └─ transparency evidence
```

All elements MUST refer to the same cryptographic object.

---

# 6. Bundle Structure

```json
{
  "bundleVersion": "1.0",
  "object": { ... },
  "signature": { ... },
  "certificate": { ... },
  "timestamps": [ ... ],
  "transparency": [ ... ],
  "validationMaterial": { ... }
}
```

---

# 7. Object

```json
{
  "objectType": "tea-artifact",
  "objectId": "artifact-123",
  "digest": {
    "algorithm": "sha-256",
    "value": "BASE64URL..."
  }
}
```

---

## 7.1 Rules

- MUST identify the artifact  
- Digest MUST use SHA-256  
- Digest MUST match exact artifact bytes  

---

# 8. Signature

```json
{
  "format": "jws-detached",
  "algorithm": "EdDSA",
  "value": "BASE64URL...",
  "signatureDigest": {
    "algorithm": "sha-256",
    "value": "BASE64URL..."
  }
}
```

---

## 8.1 Rules

- Signature MUST be over the artifact  
- `signatureDigest` MUST be SHA-256 over the signature value  
- Signature MUST be verifiable using the certificate  

---

# 9. Certificate

```json
{
  "format": "x509-pem",
  "certificate": "-----BEGIN CERTIFICATE----- ...",
  "chain": [ ... ]
}
```

---

## 9.1 Rules

- MUST be the certificate used for signing  
- MUST conform to TEA certificate profile  
- MAY include chain  

---

# 10. Timestamps

```json
[
  {
    "format": "rfc3161",
    "token": "BASE64...",
    "messageImprint": {
      "algorithm": "sha-256",
      "value": "..."
    }
  }
]
```

---

## 10.1 Binding Rule

```
messageImprint = SHA-256(signature)
```

---

## 10.2 Requirements

- MUST bind to signature (not artifact)  
- MUST use SHA-256  
- MUST prove signature existed within certificate validity  

---

# 11. Transparency Evidence

---

## 11.1 Purpose

Provides:

- public visibility  
- auditability  
- tamper detection  

---

## 11.2 Binding Rule

Transparency MUST bind to:

- signature  
OR  
- timestamped signature  

NOT the raw artifact.

---

## 11.3 Common Structure

```json
{
  "system": "rekor",
  "binding": {
    "type": "signature",
    "digest": {
      "algorithm": "sha-256",
      "value": "..."
    }
  },
  "verification": { ... }
}
```

---

# 12. Digest Algorithm and Canonicalization

## 12.1 Digest Algorithm

TEA defines a single digest algorithm:

- `sha-256`

---

## 12.2 Normative Requirements

- All digests MUST use SHA-256  
- No other algorithms are permitted  
- Implementations MUST support SHA-256  

---

## 12.3 Prohibited Algorithms

- MD5  
- SHA-1  
- SHA-512  
- any unspecified algorithm  

---

## 12.4 Canonicalization

JSON objects MUST use:

> RFC 8785 — JSON Canonicalization Scheme (JCS)

---

## 12.5 Digest Computation

```
digest = SHA-256(JCS(object))
```

---

## 12.6 Encoding

Digest values MUST use base64url.

---

# 13. Binding Rules (Normative)

A verifier MUST validate:

---

## 13.1 Artifact → Signature

Signature verifies the artifact.

---

## 13.2 Signature → Timestamp

Timestamp binds to signature.

---

## 13.3 Signature → Transparency

Transparency binds to signature or timestamped signature.

---

## 13.4 Certificate → Signature

Certificate validates the signature.

---

## 13.5 Object Consistency

All digests MUST refer to the same artifact.

---

# 14. Validation Model

A verifier MUST:

1. verify artifact digest  
2. verify signature  
3. validate certificate  
4. validate timestamp  
5. verify timestamp binding  
6. validate transparency  
7. verify transparency binding  
8. apply policy  

---

## 14.1 Rule

> Validation MUST fail on any mismatch or invalid evidence.

---

# 15. Reuse Rules

---

## 15.1 Allowed Reuse

Evidence bundles MAY be reused:

- across collections  
- across distribution channels  

---

## 15.2 Conditions

Reuse is allowed only if:

- artifact digest matches  
- bundle refers to the same artifact  

---

## 15.3 Prohibited Reuse

Evidence bundles MUST NOT be reused for:

- TEA collections  
- discovery documents  

---

# 16. Profiles

## 16.1 Minimal

- signature  
- certificate  

---

## 16.2 TEA Trust Architecture

- timestamp REQUIRED  
- transparency REQUIRED  

---

## 16.3 High Assurance

- multiple TSAs  
- multiple transparency systems  

---

# 17. Error Handling

Validation MUST fail if:

- digest mismatch  
- signature invalid  
- certificate invalid  
- timestamp invalid  
- transparency invalid  
- binding inconsistency  

---

# 18. Extensibility

- unknown fields MUST be ignored  
- additional evidence types MAY be added  
- future formats MAY include CBOR / COSE  

---

# 19. Rationale

Short-lived certificates and ephemeral keys eliminate long-term key risk but require durable validation evidence.

The evidence bundle provides:

- durable proof of authorship  
- durable proof of signing time  
- durable proof of public visibility  

---

# Final Statement

The TEA Evidence Bundle transforms:

> ephemeral cryptographic signals  
into  
> durable, verifiable evidence  

---

## Key Principle

> All evidence layers MUST refer to the same cryptographic object.
