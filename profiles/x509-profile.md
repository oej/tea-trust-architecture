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
5. [Certificate Roles](#5-certificate-roles)  
6. [Profile Requirements](#6-profile-requirements)  
7. [Subject Name Requirements](#7-subject-name-requirements)  
8. [SAN Requirements](#8-san-requirements)  
9. [Key Usage and Extensions](#9-key-usage-and-extensions)  
10. [Algorithms](#10-algorithms)  
11. [Validity Period](#11-validity-period)  
12. [Encoding and Publication](#12-encoding-and-publication)  
13. [Validation Rules](#13-validation-rules)  
14. [DNS and Policy Considerations](#14-dns-and-policy-considerations)  
15. [Security Considerations](#15-security-considerations)  
16. [Examples](#16-examples)  
17. [Final Statement](#17-final-statement)  

---

## 1. Purpose

This document defines how X.509 certificates are used in the TEA Trust Architecture.

The profile is designed to support:

- short-lived signing certificates  
- public-key-centric identity  
- DNS-based publication in TEA-native mode  
- long-term validation using timestamps and transparency evidence  

This profile does **not** use X.509 subject naming as the source of trust identity.

---

## 2. Scope

This profile applies to X.509 certificates used for:

- TEA artifact signing  
- TEA collection signing  
- discovery signing  
- publication of TEA-native trust anchors in DNS  

This profile applies to both:

- **TEA-native trust model**
- **WebPKI trust model (with TEA overlay)**

---

## 3. Design Principles

The TEA X.509 profile is based on the following principles:

1. **Public key is the identity**  
2. **Certificate is a short-lived wrapper, not the root identity**  
3. **Trust must not depend on long-lived private keys**  
4. **DNS publication must bind clearly to the same key identity**  
5. **Long-term validation depends on evidence, not certificate lifetime**  
6. **A single key pair is reused across signing and transparency systems**  

---

## 4. Identity Model

In TEA:

> **The public key is the identity.**

The certificate provides:

- a validity window  
- a standard container format  
- accountability metadata  
- interoperability with timestamp and transparency ecosystems  

The certificate subject is **not** the trust identity.

The trust identity is derived from:

```text
SHA-256(public key)
```

---

## 5. Certificate Roles

Certificates in TEA may be used for:

- discovery signing  
- TEA collection signing  
- TEA artifact signing  
- TEA trust anchor publication (TAPS)  

All roles use the same core profile.

---

## 6. Profile Requirements

Certificates MUST:

- be X.509 v3  
- contain an Ed25519 public key  
- be short-lived  
- include SAN DNS entries as defined in this profile  

Certificates MUST NOT:

- rely on CN for identity  
- contain multiple unrelated identities  

---

## 7. Subject Name Requirements

The subject field:

- MAY contain:
  - O (organization)  
  - OU (organizational unit)  
  - C (country)  

- MUST NOT be used as a trust anchor  
- MUST NOT be relied upon for identity validation  

The CN field:

- SHOULD NOT be used  
- MUST be ignored by consumers  

---

## 8. SAN Requirements

### 8.1 Primary SAN

Certificates MUST contain:

- exactly one **primary SAN DNS entry**

The primary SAN:

- MUST be under the manufacturer-controlled domain  
- MUST encode the fingerprint-derived identifier  

Example:

```text
<fingerprint>.tea.example.com
```

---

### 8.2 Optional Secondary SAN (Long-Term)

Certificates MAY include:

- one **secondary SAN DNS entry**

The secondary SAN:

- MAY be under:
  - the manufacturer-controlled domain, OR  
  - an independent domain  

- MUST encode the same fingerprint-derived identifier  

When the secondary SAN is under the manufacturer-controlled domain:

- it SHOULD use a **separate domain or subdomain**  
- it SHOULD be operated under **separate infrastructure and control boundaries**  

---

### 8.3 Constraints

- maximum of two SAN DNS entries  
- exactly one primary SAN  
- at most one secondary SAN  
- both SANs MUST refer to the same public key identity  

---

## 9. Key Usage and Extensions

Certificates MUST include:

- digitalSignature key usage  

No other key usages are required.

---

## 10. Algorithms

### 10.1 Allowed Algorithm

TEA certificates MUST use:

```text
Ed25519
```

No other algorithms are permitted.

---

### 10.2 Rationale

This restriction ensures:

- compatibility with Sigsum transparency logs  
- consistent key identity across systems  
- simplified validation logic  
- reduced implementation complexity  
- avoidance of algorithm downgrade risks  

---

### 10.3 Key Reuse Across Systems

The same Ed25519 key pair:

- MUST be used for TEA signing  
- MUST be used for Sigsum transparency logging  

This ensures:

- a single cryptographic identity  
- consistent evidence binding  
- simplified trust validation  

---

## 11. Validity Period

Certificates MUST:

- have a lifetime ≤ 1 hour  

---

## 12. Encoding and Publication

Certificates MUST:

- be encoded in DER  

For TEA-native:

- MUST be published in DNS using CERT records  

For WebPKI:

- follow standard CA issuance  

---

## 13. Validation Rules

Consumers MUST:

- validate certificate signature  
- validate certificate time bounds  
- validate binding to timestamp  

Consumers MUST NOT:

- rely solely on certificate validity  

---

## 14. DNS and Policy Considerations

### 14.1 TEA-Native

- DNS is a trust anchor distribution mechanism  
- DNSSEC SHOULD be used  

---

### 14.2 WebPKI

- DNS is NOT a trust anchor  
- DNS MAY enforce policy via CAA records  
- DNSSEC strengthens CAA validation  

---

## 15. Security Considerations

- short-lived certs reduce exposure  
- Ed25519 reduces complexity and attack surface  
- single key identity simplifies validation  
- dual SAN improves survivability  

---

## 16. Examples

```text
Primary:  abcd1234.tea.example.com
Secondary: abcd1234.backup.example.net
```

---

## 17. Final Statement

This profile enforces:

- a single cryptographic identity model  
- strong alignment with transparency systems  
- simplified and robust validation  

---

### Key Principle

> One key, one identity, one algorithm — verified through independent evidence.
