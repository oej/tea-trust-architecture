# 📘 TEA Trust Architecture — X.509 Certificate Profile
**Version:** 1.0  
**Status:** Draft (Normative, Implementation-Ready)

---

## Status

This document defines the **X.509 certificate profile** for the TEA Trust Architecture.

This specification is **implementation-ready** but subject to change based on implementation experience and community feedback.

The key words **MUST**, **SHOULD**, and **MAY** are to be interpreted as described in:

- RFC 2119  
- RFC 8174  

---

## Table of Contents

1. [Purpose](#1-purpose)  
2. [Scope](#2-scope)  
3. [Design Principles](#3-design-principles)  
4. [Identity Model](#4-identity-model)  
5. [Terminology Clarification](#5-terminology-clarification)  
6. [Certificate Roles](#6-certificate-roles)  
7. [Profile Requirements](#7-profile-requirements)  
8. [Subject Name Requirements](#8-subject-name-requirements)  
9. [SAN Requirements](#9-san-requirements)  
10. [Key Usage and Extensions](#10-key-usage-and-extensions)  
11. [Algorithms](#11-algorithms)  
12. [Validity Period](#12-validity-period)  
13. [Key Reuse Prohibition](#13-key-reuse-prohibition)  
14. [Encoding and Publication](#14-encoding-and-publication)  
15. [Validation Rules](#15-validation-rules)  
16. [DNS and Policy Considerations](#16-dns-and-policy-considerations)  
17. [Security Considerations](#17-security-considerations)  
18. [Examples](#18-examples)  
19. [Normative References](#19-normative-references)  
20. [Informative References](#20-informative-references)  
21. [Final Statement](#21-final-statement)  

---

## 1. Purpose

This document defines how X.509 certificates are used in the TEA Trust Architecture.

The profile supports:

- short-lived certificates  
- ephemeral signing keys  
- DNS-based trust anchor publication (TAPS)  
- long-term validation via timestamps and transparency  

---

## 2. Scope

This profile applies to certificates containing public keys used for:

- TEA artifact signing  
- TEA collection signing  
- discovery document signing  
- TEA-native trust anchor publication  

Applicable to:

- TEA-native trust model  
- WebPKI trust model (with TEA overlay)  

---

## 3. Design Principles

1. **Public key is the identity**  
2. **Private key performs signing**  
3. **Certificate is a short-lived wrapper**  
4. **Trust derives from evidence, not key lifetime**  
5. **Keys are ephemeral and single-use**  
6. **DNS binds identity in TEA-native deployments**  
7. **One key MAY be reused across systems (e.g., transparency), but not across time**  

---

## 4. Identity Model

In TEA:

> The public key is the identity.

The identity is derived from:

```text
SHA-256(public key)
```

[RFC 6234]

The certificate:

- provides a validity window  
- provides metadata  
- binds identity to DNS via SAN  

It is **not** the root of trust.

---

## 5. Terminology Clarification

- Signing is performed using the **private key**  
- The certificate contains the corresponding **public key**  
- The certificate does **not** perform cryptographic operations  

All references to signing MUST be interpreted as:

> signing with the private key corresponding to the public key in the certificate  

---

## 6. Certificate Roles

Certificates bind public keys used for:

- artifact signing  
- collection signing  
- discovery signing  

The corresponding private key performs the actual signing.

---

## 7. Profile Requirements

Certificates MUST:

- be X.509 v3 [RFC 5280]  
- contain an Ed25519 public key [RFC 8410]  
- be short-lived  
- include SAN DNS entries  

Certificates MUST NOT:

- rely on CN for identity  
- contain multiple unrelated identities  

---

## 8. Subject Name Requirements

The subject:

- MAY include:
  - O (organization)  
  - OU (organizational unit)  
  - C (country)  

- MUST NOT be used for trust decisions  

CN:

- SHOULD NOT be used  
- MUST be ignored  

---

## 9. SAN Requirements

### 9.1 Primary SAN

Certificates MUST include:

- exactly one primary SAN DNS entry  

The SAN extension is defined in:

- RFC 5280  

The primary SAN:

- MUST be under manufacturer-controlled domain  
- MUST encode fingerprint-derived identity  

---

### 9.2 Optional Secondary SAN

Certificates MAY include:

- one secondary SAN DNS entry  

The secondary SAN:

- MUST encode the same identity  
- SHOULD be on separate infrastructure if under same organization  

---

## 10. Key Usage and Extensions

Certificates MUST include:

- digitalSignature  

As defined in:

- RFC 5280  

---

## 11. Algorithms

### 11.1 Allowed Algorithm

```text
Ed25519
```

Defined in:

- RFC 8032  
- RFC 8410 (X.509 usage)  

---

### 11.2 Hash Algorithm

```text
SHA-256
```

Defined in:

- RFC 6234  

---

### 11.3 Transparency Compatibility

The same key MAY be used with:

- Sigsum (recommended)  
- Rekor (allowed)  

---

## 12. Validity Period

Certificates MUST:

```text
have a lifetime ≤ 1 hour
```

---

## 13. Key Reuse Prohibition

### 13.1 Requirement

A key pair MUST be single-use.

---

### 13.2 Fingerprint

```text
SHA-256(public key)
```

MUST be unique.

---

## 14. Encoding and Publication

Certificates MUST:

- be DER encoded [RFC 5280]  

### TEA-native

Certificates MUST be published in DNS using:

- CERT records [RFC 4398]  

---

## 15. Validation Rules

Consumers MUST:

- validate certificate structure [RFC 5280]  
- verify validity period  
- verify public key matches signature  

---

## 16. DNS and Policy Considerations

### 16.1 TEA-native

- DNSSEC SHOULD be used [RFC 4033, RFC 4034, RFC 4035]  

---

### 16.2 WebPKI

- DNS MAY enforce CA policy using:
  - CAA records [RFC 8659]  

---

## 17. Security Considerations

- short-lived certificates reduce exposure  
- ephemeral keys eliminate long-term risk  
- Ed25519 simplifies cryptography  
- DNSSEC strengthens trust anchor distribution  

---

## 18. Examples

```text
abcd1234.tea.example.com
abcd1234.backup.example.net
```

---

## 19. Normative References

- RFC 2119 — Key words for use in RFCs  
- RFC 8174 — Updates to RFC 2119  
- RFC 5280 — PKIX Certificate and CRL Profile  
- RFC 8032 — EdDSA (Ed25519)  
- RFC 8410 — Ed25519 in X.509  
- RFC 6234 — SHA-256  
- RFC 3161 — Time-Stamp Protocol  

---

## 20. Informative References

- RFC 4033 — DNSSEC Introduction  
- RFC 4034 — DNSSEC Resource Records  
- RFC 4035 — DNSSEC Protocol  
- RFC 4398 — Storing Certificates in DNS  
- RFC 8659 — Certification Authority Authorization (CAA)  

---

## 21. Final Statement

This profile enforces:

- ephemeral identity  
- deterministic validation  
- long-term trust via evidence  

---

### Key Principle

> One key, one identity, one moment in time — preserved through verifiable evidence.
