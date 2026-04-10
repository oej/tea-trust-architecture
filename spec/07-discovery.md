# 📘 TEA Discovery Security Architecture
**Version:** 1.0  
**Status:** Draft (Implementation-Ready)

---

## Table of Contents

- [1. Introduction](#1-introduction)
- [2. TEI – Discovery Starting Point](#2-tei--discovery-starting-point)
- [3. Design Principles](#3-design-principles)
- [4. Discovery Endpoint](#4-discovery-endpoint)
- [5. Trust Layers](#5-trust-layers)
- [6. Trust Models](#6-trust-models)
- [7. DNS Trust Model (TEA-Native)](#7-dns-trust-model-tea-native)
- [8. Certificate Profile](#8-certificate-profile)
- [9. Signature Model](#9-signature-model)
- [10. Canonicalization](#10-canonicalization)
- [11. Timestamp Requirements](#11-timestamp-requirements)
- [12. Transparency](#12-transparency)
- [13. Validation Procedures](#13-validation-procedures)
- [14. Validity Scope](#14-validity-scope)
- [15. Security Properties](#15-security-properties)
- [16. STRIDE Summary](#16-stride-summary)
- [17. Error Model](#17-error-model)
- [18. Consumer Flow](#18-consumer-flow)
- [19. Final Summary](#19-final-summary)

---

## 1. Introduction

The TEA discovery mechanism is the **bootstrap trust step** of the TEA ecosystem.

It answers two fundamental questions:

1. **Where is the correct TEA service for this product?**  
2. **Is that mapping to API endpoints authorized by the manufacturer?**

Discovery is a two-stage process:

```
TEI → manufacturer domain → /.well-known/tea → TEA API endpoints
```

Discovery provides:

- API endpoint authorization  
- trust model signaling  
- cryptographic protection of service metadata  

It does **not** establish trust in TEA artefacts or TEA collections.  
That is handled separately by signatures, timestamps, transparency, and evidence bundles.

---

## 2. TEI – Discovery Starting Point

### 2.1 What is a TEI?

A **Transparency Exchange Identifier (TEI)** identifies a **product**, not a specific release.

It is the **entry point for discovery**.

Example structure:

```
tei://example.com/product/<base64url-encoded-id>
```

Optional version selection:

```
tei://example.com/product/<base64url-id>?version=<string>
```

---

### 2.2 Key Properties

- TEI reuses **existing vendor identifiers where possible**  
- UUIDs are used only when no identifier exists  
- identifier MUST be **BASE64url encoded**  
- TEI domain MUST be the **manufacturer-controlled domain**  

---

### 2.3 Why TEI Matters

TEI ensures:

- discovery starts from a **manufacturer-controlled namespace**  
- no central registry is required  
- identifiers remain stable across infrastructure changes  

---

### 2.4 Resolution Model

The TEI resolves to a manufacturer domain:

```
tei://example.com/... → example.com
```

Consumers then perform discovery using:

```
https://example.com/.well-known/tea
```

DNS resolution may return:

- IPv4 (A records)  
- IPv6 (AAAA records)  
- HTTPS/SVCB records  

Resolution MUST follow standard HTTPS resolution behavior.

---

## 3. Design Principles

### 3.1 Separation of Concerns

| Layer | Responsibility |
|------|---------------|
| TEI | product identity |
| Discovery | API endpoint authorization |
| Transport | TLS confidentiality and integrity |
| Trust | signatures, timestamps, transparency |

TLS provides:

- **confidentiality of discovery data in transit**  
- **integrity protection during transport**  
- **server authentication (WebPKI)**  

However:

> TLS MUST NOT be used as a trust anchor for TEA discovery or TEA artefact validation.

All trust decisions MUST be based on:

- signatures  
- timestamps  
- transparency evidence  
- trust-anchor validation (DNS or PKIX depending on model)

---

### 3.2 Identity Model

- public key = identity  
- certificate = validity wrapper  
- DNS publishes TEA-native certificates  
- SAN binds key to DNS namespace  

---

### 3.3 Manufacturer Domain Control

The manufacturer domain:

- anchors TEI  
- hosts discovery  
- defines authorized API endpoints  
- controls delegation  

---

## 4. Discovery Endpoint

```
https://<manufacturer-domain>/.well-known/tea
```

Requirements:

- TLS MUST be used  
- TLS MUST be validated  

However:

> TLS alone MUST NOT establish trust in discovery content

The discovery document itself MUST be cryptographically validated.

---

## 5. Trust Layers

### 5.1 TEI Trust

TEI provides:

- starting point for discovery  
- binding to manufacturer domain  

TEI itself is not signed. Trust derives from:

- domain control  
- subsequent discovery validation  

---

### 5.2 Discovery Trust

Discovery establishes:

- authorized TEA API endpoints  

Based on:

- signature (**MUST**)  
- timestamp (**MUST**)  
- certificate validation  
- optional transparency  

---

### 5.3 Transport Trust

TLS provides:

- confidentiality  
- integrity  
- server authentication  

---

### 5.4 TEA Artefact Trust

Handled separately via:

- TEA collections  
- TEA artefacts  
- evidence bundles  

---

## 6. Trust Models

### 6.1 WebPKI

- PKIX validation  
- DNS MUST NOT be used as a trust anchor  
- DNS MAY strengthen validation via CAA  

---

### 6.2 TEA-Native (TAPS)

- self-signed certificate  
- DNS publication REQUIRED  
- DNSSEC OPTIONAL  
- fingerprint-derived SAN REQUIRED  

---

### 6.3 Removed Model

The previously proposed two-layer TEA-native model is removed.

Rationale:

- reintroduces long-lived keys  
- increases complexity  
- conflicts with ephemeral key design  

---

## 7. DNS Trust Model (TEA-Native)

- certificates MUST be published via DNS CERT records (PKIX)  
- TLSA MUST NOT be used  
- DNSSEC is OPTIONAL but recommended  

---

## 8. Certificate Profile

- CN MUST NOT be used  
- SAN MUST be fingerprint-derived  
- Ed25519 REQUIRED  
- certificate validity MUST be ≤ 1 hour  

---

## 9. Signature Model

Discovery MUST include:

- signature  
- timestamp  
- optional transparency  

Signature applies to canonical JSON.

---

## 10. Canonicalization

RFC 8785 (JSON Canonicalization Scheme) MUST be used.

---

## 11. Timestamp Requirements

Timestamp is **MANDATORY**.

It proves:

- the signature existed at a specific time  
- the certificate was valid at that time  

This enables:

- long-term validation  
- protection against backdating  

---

## 12. Transparency

OPTIONAL but RECOMMENDED.

Provides:

- auditability  
- publication visibility  

Supported systems:

- Sigsum  
- SCITT (future)

---

## 13. Validation Procedures

### TEI → Discovery Flow

1. parse TEI  
2. extract domain  
3. resolve DNS  
4. fetch discovery  
5. validate TLS  
6. validate signature  
7. validate timestamp  
8. validate certificate  
9. extract authorized API endpoints  

---

## 14. Validity Scope

Discovery:

- authorizes API endpoints  
- does not establish artefact trust  

---

## 15. Security Properties

- manufacturer-controlled discovery  
- no central registry  
- resilience to infrastructure change  

---

## 16. STRIDE Summary

| Threat | Mitigation |
|------|-----------|
| Spoofing | TLS + signature |
| Tampering | signature |
| Repudiation | timestamp |
| Disclosure | TLS |
| DoS | redundancy |
| Elevation | domain separation |

---

## 17. Error Model

- INVALID_TEI  
- DISCOVERY_SIGNATURE_INVALID  
- DISCOVERY_TIMESTAMP_INVALID  
- DISCOVERY_DNS_MISMATCH  

---

## 18. Consumer Flow

```
TEI → domain → discovery → API endpoints → artefact validation
```

---

## 19. Final Summary

Discovery in TEA is a **two-step trust process**:

1. TEI → manufacturer domain  
2. discovery → authorized API endpoints  

---

## Final Statement

TEI defines:

> **what product to look for**

Discovery defines:

> **where to find it**

TEA trust architecture defines:

> **why it can be trusted**