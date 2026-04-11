# 📘 TEA Trust Architecture — Evidence Validation Specification
**Version:** 1.0  
**Status:** Draft (Normative, Implementation-Ready)

---

## Status

This document defines how TEA evidence bundles are **validated**.

It specifies:

- validation steps  
- cryptographic checks  
- binding rules  
- transparency validation models  

The key words **MUST**, **SHOULD**, and **MAY** are to be interpreted as described in:

- RFC 2119  
- RFC 8174  

This document is intended to be used with:

- TEA Evidence Bundle Specification  
- TEA X.509 Profile  
- RFC 3161 (Time-Stamp Protocol)  

---

## Table of Contents

1. [Purpose](#1-purpose)  
2. [Scope](#2-scope)  
3. [Validation Philosophy](#3-validation-philosophy)  
4. [Inputs](#4-inputs)  
5. [Validation Model Overview](#5-validation-model-overview)  
6. [Algorithm Requirements](#6-algorithm-requirements)  
7. [Step-by-Step Validation](#7-step-by-step-validation)  
8. [Certificate Validation](#8-certificate-validation)  
9. [Timestamp Validation](#9-timestamp-validation)  
10. [Transparency Validation](#10-transparency-validation)  
11. [Binding Validation](#11-binding-validation)  
12. [Offline Validation Requirements](#12-offline-validation-requirements)  
13. [Error Handling](#13-error-handling)  
14. [Implementation Hints](#14-implementation-hints)  
15. [Security Considerations](#15-security-considerations)  
16. [Normative References](#16-normative-references)  
17. [Informative References](#17-informative-references)  
18. [Final Statement](#18-final-statement)  

---

## 1. Purpose

This document defines how a validator verifies that:

> a TEA artifact is authentic, correctly signed, properly timestamped, and (optionally) transparently published.

---

## 2. Scope

Applies to validation of:

- TEA artifacts (primary)  
- TEA collections (optional)  
- discovery documents (optional)  

---

## 3. Validation Philosophy

### 3.1 Evidence-Based Trust

Validation relies only on:

- cryptographic verification  
- preserved evidence  

NOT on:

- live infrastructure  
- online services  

---

### 3.2 Deterministic Validation

Given identical inputs:

- all compliant validators MUST produce identical results  

---

### 3.3 Fail-Closed Model

Any failure:

> MUST result in rejection  

---

## 4. Inputs

Required:

- artifact (binary)  
- evidence bundle  

Optional:

- trust policy  
- trusted TSA roots  
- trusted transparency logs  

---

## 5. Validation Model Overview

```text
artifact → signature → certificate → timestamp → transparency
```

Each layer MUST bind to the next.

---

## 6. Algorithm Requirements

### 6.1 Signature Algorithm

```text
Ed25519
```

(RFC 8032, RFC 8410)

---

### 6.2 Hash Algorithm

```text
SHA-256
```

(RFC 6234)

---

### 6.3 Enforcement

Any deviation:

> MUST fail validation  

---

## 7. Step-by-Step Validation

Validators MUST:

1. verify artifact integrity  
2. verify signature  
3. verify certificate  
4. verify timestamp  
5. verify timestamp binding  
6. verify transparency (if present or required)  
7. verify transparency binding  
8. apply policy  

---

## 8. Certificate Validation

The certificate contains the **public key** corresponding to the private key used for signing.

Validators MUST:

- verify certificate structure (RFC 5280)  
- verify validity period  
- verify public key matches signature  

---

### 8.1 Time Validation

The timestamp MUST satisfy:

```text
notBefore ≤ timestamp ≤ notAfter
```

---

## 9. Timestamp Validation

Validators MUST:

- verify RFC 3161 timestamp  
- verify TSA signature  
- extract timestamp  

---

### 9.1 Binding Rule

```text
messageImprint = SHA-256(signature)
```

---

### 9.2 Rationale

Timestamp proves:

> signature existed during certificate validity  

---

## 10. Transparency Validation

Transparency validation depends on the system used.

---

### 10.1 Requirement Levels

| Profile | Requirement |
|--------|------------|
| Minimal | OPTIONAL |
| TEA-native | SHOULD |
| High Assurance | REQUIRED |

---

### 10.2 General Requirements

If present, validators MUST:

- verify inclusion proof  
- verify signed log state  
- verify binding to signature  

---

### 10.3 Sigsum (Recommended)

Validators MUST verify:

- inclusion proof  
- checkpoint (signed tree head)  
- witness signatures  

---

#### Witness Requirements

- MUST meet quorum  
- MUST validate against trusted witnesses  

---

Reference:

- https://www.sigsum.org  

---

### 10.4 Rekor (Allowed)

Validators MUST verify:

- inclusion proof  
- signed tree head  

Validators SHOULD verify:

- log identity  

---

References:

- https://rekor.sigstore.dev  
- https://www.sigstore.dev  

---

### 10.5 SCITT (Future)

Validators MUST verify:

- signed receipt  
- binding to signature  

---

Reference:

- https://datatracker.ietf.org/wg/scitt/about/  

---

### 10.6 Absence of Transparency

If required but missing:

> validation MUST fail  

If optional:

> validation MAY proceed  

---

## 11. Binding Validation

All layers MUST refer to the same cryptographic object.

---

### 11.1 Required Bindings

| From | To | Requirement |
|-----|----|------------|
| Artifact | Signature | Signature verifies |
| Signature | Timestamp | SHA-256 match |
| Signature | Transparency | SHA-256 match |
| Certificate | Signature | public key match |

---

### 11.2 Failure Rule

Any mismatch:

> MUST fail validation  

---

## 12. Offline Validation Requirements

Validation MUST be possible without:

- TSA access  
- transparency access  
- certificate retrieval  

---

### 12.1 Required Data

Evidence bundle MUST contain:

- signature  
- certificate  
- timestamp  
- transparency (if required)  

---

## 13. Error Handling

Validation MUST fail if:

- signature invalid  
- certificate invalid  
- timestamp invalid  
- transparency invalid (if required)  
- binding mismatch  
- unsupported algorithm  

---

## 14. Implementation Hints

- validate in strict order  
- fail early  
- cache trust anchors  
- use constant-time crypto  

---

## 15. Security Considerations

- certificates may be expired at validation time  
- timestamp replaces certificate lifetime as time anchor  
- transparency provides auditability  
- Ed25519 reduces attack surface  

---

## 16. Normative References

- RFC 2119  
- RFC 8174  
- RFC 5280 (X.509)  
- RFC 8032 (Ed25519)  
- RFC 8410 (Ed25519 in X.509)  
- RFC 6234 (SHA-256)  
- RFC 3161 (Timestamping)  

---

## 17. Informative References

- Sigsum — https://www.sigsum.org  
- Rekor — https://rekor.sigstore.dev  
- Sigstore — https://www.sigstore.dev  
- SCITT — https://datatracker.ietf.org/wg/scitt/about/  

---

## 18. Final Statement

A valid TEA artifact satisfies:

- correct signature  
- valid certificate at signing time  
- valid timestamp  
- correct binding  
- transparency inclusion (if required)  

---

### Key Principle

> Trust emerges from consistent, independent cryptographic evidence.
