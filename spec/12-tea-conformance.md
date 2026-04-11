# 📘 TEA Trust Architecture — Conformance Specification
**Version:** 1.0  
**Status:** Draft (Normative, Implementation-Ready)

---

## Status

This document defines **conformance requirements** for implementations of the TEA Trust Architecture.

It specifies:

- mandatory behaviors  
- validation requirements  
- publication requirements  
- cryptographic constraints  

The key words **MUST**, **MUST NOT**, **SHOULD**, and **MAY** are to be interpreted as described in:

- RFC 2119  
- RFC 8174  

This document is normative for:

- TEA consumers  
- TEA publishers  
- TEA services  

---

## Table of Contents

1. [Purpose](#1-purpose)  
2. [Scope](#2-scope)  
3. [Conformance Levels](#3-conformance-levels)  
4. [Cryptographic Requirements](#4-cryptographic-requirements)  
5. [Certificate Requirements](#5-certificate-requirements)  
6. [Key Management Requirements](#6-key-management-requirements)  
7. [Evidence Bundle Requirements](#7-evidence-bundle-requirements)  
8. [Validation Requirements](#8-validation-requirements)  
9. [Transparency Requirements](#9-transparency-requirements)  
10. [Publication Requirements](#10-publication-requirements)  
11. [API Requirements](#11-api-requirements)  
12. [Error Handling](#12-error-handling)  
13. [Security Requirements](#13-security-requirements)  
14. [Normative References](#14-normative-references)  
15. [Final Statement](#15-final-statement)  

---

## 1. Purpose

This specification defines the **minimum required behavior** for TEA Trust Architecture implementations.

It ensures:

- interoperability  
- predictable validation outcomes  
- consistent security guarantees  

---

## 2. Scope

Applies to:

- TEA consumers (validators)  
- TEA publishers (release systems)  
- TEA services (APIs)  

---

## 3. Conformance Levels

### 3.1 Minimal

- signature validation  
- certificate validation  

---

### 3.2 TEA-Native

- timestamp REQUIRED  
- transparency SHOULD  

---

### 3.3 High Assurance

- timestamp REQUIRED  
- transparency REQUIRED  
- multiple evidence sources REQUIRED  

---

## 4. Cryptographic Requirements

Implementations MUST use:

### 4.1 Signature Algorithm

```text
Ed25519
```

- RFC 8032  
- RFC 8410  

---

### 4.2 Hash Algorithm

```text
SHA-256
```

- RFC 6234  

---

### 4.3 Prohibited Algorithms

Any other algorithms:

> MUST NOT be accepted  

---

## 5. Certificate Requirements

Certificates MUST:

- conform to RFC 5280  
- contain Ed25519 public key  
- have validity ≤ 1 hour  
- include SAN DNS entries  

Certificates MUST NOT:

- rely on CN for identity  

---

## 6. Key Management Requirements

### 6.1 Single-Use Keys

A key pair MUST:

- be used for a single signing event  
- NOT be reused  

---

### 6.2 Fingerprint Uniqueness

Fingerprint:

```text
SHA-256(public key)
```

MUST NOT be reused.

---

### 6.3 Enforcement

Publishers MUST:

- track used fingerprints  
- reject reuse  

---

## 7. Evidence Bundle Requirements

Evidence bundles MUST include:

- signature  
- certificate  
- timestamp  

Transparency:

- OPTIONAL (Minimal)  
- SHOULD (TEA-native)  
- REQUIRED (High Assurance)  

---

## 8. Validation Requirements

Validators MUST:

- verify signature  
- verify certificate  
- verify timestamp  
- verify binding chain  

---

### 8.1 Binding Enforcement

All bindings MUST match:

```text
artifact → signature → timestamp → transparency
```

---

### 8.2 Algorithm Enforcement

Non-compliant algorithms:

> MUST fail validation  

---

## 9. Transparency Requirements

Supported systems:

- Sigsum (RECOMMENDED)  
- Rekor (ALLOWED)  
- SCITT (FUTURE)  

---

### 9.1 If Present

Validators MUST:

- verify inclusion proof  
- verify signed log state  

---

### 9.2 If Required

Missing transparency:

> MUST fail validation  

---

## 10. Publication Requirements

### 10.1 Commit Control

Publication MUST:

- require explicit authorization  
- enforce commit step  

---

### 10.2 Evidence Completeness

Publishers MUST:

- attach complete evidence bundle  
- verify before publication  

---

### 10.3 Key Enforcement

Publishers MUST:

- reject reused keys  
- ensure key deletion after use  

---

## 11. API Requirements

APIs MUST support:

- artifact retrieval  
- evidence bundle retrieval  
- multipart responses  

---

### 11.1 Supported Formats

- artifact only  
- artifact + signature  
- artifact + evidence bundle  

---

## 12. Error Handling

Implementations MUST fail if:

- signature invalid  
- certificate invalid  
- timestamp invalid  
- binding mismatch  
- unsupported algorithm  

---

## 13. Security Requirements

Implementations MUST:

- enforce fail-closed validation  
- minimize key lifetime  
- support offline validation  

---

## 14. Normative References

- RFC 2119  
- RFC 8174  
- RFC 5280 (X.509)  
- RFC 8032 (Ed25519)  
- RFC 8410 (Ed25519 in X.509)  
- RFC 6234 (SHA-256)  
- RFC 3161 (Timestamping)  
- RFC 8785 (JSON Canonicalization)  

---

## 15. Final Statement

Conformance ensures that:

- all implementations behave consistently  
- validation outcomes are deterministic  
- trust guarantees are preserved  

---

### Key Principle

> Conformance transforms architecture into enforceable trust.
