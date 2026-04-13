# 📘 TEA DNS Usage and Trust Anchor Model

## Status

- **Version:** 1.0  
- **Status:** Draft (Normative)  
- **Scope:** TEA Trust Architecture  
- **Audience:** Implementers, security architects  

---

## 1. Purpose

This document defines how DNS is used in TEA for:

- trust anchor distribution  
- certificate publication  
- identity binding  
- policy enforcement  

DNS is a **distribution and binding mechanism**, not a standalone source of trust.

---

## 2. Concept Overview

In traditional PKI:

```text
Trust anchor = Certificate Authority (CA)
```

In TEA-native:

```text
Trust anchor = Publisher certificate published in DNS
```

---

### Key Principle

> DNS distributes trust anchor material — it does not establish trust.

Trust is established through:

- signatures  
- timestamps  
- transparency (when required)  
- validation policy  

---

## 3. Identity and Naming Model

### 3.1 Identity Definition

In TEA-native:

- identity = public key  
- certificate = validity wrapper  
- DNS = publication channel  

---

### 3.2 Fingerprint-Derived Naming

Certificates MUST include a SAN DNS name:

```text
<fingerprint>.<trust-domain>
```

Where:

```text
fingerprint = lowercase hex SHA-256(public key)
```

---

### Key Property

> DNS names are derived from keys — not assigned.

This prevents:

- identity spoofing  
- namespace conflicts  

---

## 4. DNS-Based Trust Anchor Publication

### 4.1 CERT Records

Certificates MUST be published using DNS CERT records:

```text
<fingerprint>.<trust-domain>. IN CERT PKIX 0 0 <base64-certificate>
```

---

### 4.2 Requirements

- DNS publication is **REQUIRED** for DNS-based trust models  
- certificate MUST match fingerprint-derived DNS name  
- DNS responses MUST be treated as untrusted input  

---

## 5. DNSSEC Role

### 5.1 What DNSSEC Provides

DNSSEC provides:

- origin authentication  
- integrity protection  

---

### 5.2 What DNSSEC Does NOT Provide

DNSSEC does NOT provide:

- trustworthiness of data  
- certificate validation  
- lifecycle state  
- temporal ordering  

---

### Normative Statement

> DNSSEC authenticates delivery of data, not trust in that data.

---

### 5.3 Optionality

- DNSSEC is **OPTIONAL**  
- TEA MUST function without DNSSEC  

---

## 6. Trust Model Integration

### 6.1 Trust Establishment

A consumer MUST validate:

1. signature  
2. timestamp  
3. certificate validity at signing time  
4. fingerprint → SAN binding  
5. DNS publication  
6. DNSSEC (if required by policy)  

---

### Trust Composition

```text
Trust = signature + timestamp + certificate + DNS (+ DNSSEC) + transparency
```

---

### Critical Rule

> DNS publication alone MUST NOT establish trust.

---

## 7. Evidence Integration

DNS-based trust operates together with:

### 7.1 Timestamp

- proves signing time  
- enables long-term validation  

---

### 7.2 Transparency

- provides auditability  
- provides ordering  

Supported systems:

- Rekor  
- Sigsum  

SCITT MAY be supported in future implementations.

---

### 7.3 Evidence Bundle

A validation set MAY include:

- artefact  
- signature  
- certificate  
- timestamp  
- transparency evidence  
- DNS-derived data  

---

### Lifecycle (CLE) Integration

- CLE documents MUST be signed  
- CLE documents MUST be validated using the same mechanisms as collections  
- CLE documents MUST support versioning and historical retrieval  

CLE documents do not require external DNS-based evidence bundles.

---

## 8. Consumer Validation

### 8.1 Required Steps

A compliant consumer MUST:

1. extract certificate  
2. compute fingerprint  
3. validate SAN binding  
4. retrieve DNS record  
5. compare certificate  
6. validate signature  
7. validate timestamp  
8. validate certificate validity at timestamp  
9. validate DNSSEC (if required)  
10. validate transparency (if required)  

---

### 8.2 Failure Conditions

Validation MUST fail if:

- fingerprint mismatch  
- certificate not published in DNS  
- signature invalid  
- timestamp invalid  

---

## 9. DNS as Policy Enforcement Point

DNS publication systems act as:

> **trust policy enforcement points**

Before publishing, systems MUST validate:

- certificate correctness  
- identity binding  
- signature validity  
- timestamp validity  

---

### Prohibited Behavior

DNS publication MUST NOT be based on:

- unsigned data  
- unvalidated certificates  
- direct CI/CD write without validation  

---

## 10. DNS Publication Requirements

### Required (All Models)

- valid certificate  
- correct SAN binding  
- valid signature  
- valid timestamp  

---

### Additional (DNS-Based Model)

- transparency SHOULD be present  
- MAY be required by policy  

---

### Additional (WebPKI Model)

- PKIX validation MUST succeed  
- CAA SHOULD be validated  

---

## 11. Separation of Duties

Implementations SHOULD separate:

- CI/CD (build + sign)  
- DNS publication (validation + publish)  

CI/CD:

- MAY sign  
- MUST NOT control DNS directly  

DNS publication:

- MUST enforce policy  
- MUST be controlled  

---

## 12. Automated DNS Updates

If automation is used:

- MUST enforce least privilege  
- MUST restrict scope  
- MUST be auditable  
- MUST use short-lived credentials  

---

## 13. DNS Scope Design

Implementations SHOULD separate:

- trust anchors  
- release certificates  

Example:

```text
_tea.example.com       → trust anchors  
_tea-rel.example.com   → release certificates  
```

---

## 14. Security Considerations

### Risks

- DNS spoofing (without DNSSEC)  
- DNS zone compromise  
- incorrect certificate publication  

---

### Mitigations

- DNSSEC (when available)  
- strict validation rules  
- transparency logging  
- timestamp validation  

---

## 15. Final Normative Statements

A TEA implementation:

- MUST NOT treat DNS or DNSSEC as a trust authority  
- MUST treat DNS as a distribution mechanism  
- MUST validate all trust anchors independently  
- MUST combine DNS data with signature, timestamp, and policy validation  

---

## 16. Summary

DNS in TEA:

- distributes trust anchors  
- binds identity to public keys  
- enables decentralized trust  

Trust is established only through:

- signatures  
- timestamps  
- transparency  
- validation policy  

---

## 🎯 One-Line Takeaway

> **DNS distributes trust anchors in TEA — it never defines trust.**