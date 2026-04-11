# 📘 TEA Trust Architecture – Core Specification
**Version:** 1.0  
**Status:** Draft (Normative, RFC-style)

---

## Status

This document defines the **TEA Trust Architecture**, an **optional overlay** to the core TEA specification.

The Trust Architecture adds:

- cryptographic signatures
- timestamps
- transparency logging
- DNS-based trust anchoring
- long-term validation mechanisms

It is designed to support:

- **EU Cyber Resilience Act (CRA)** requirements
- long-term software integrity (≥10 years)
- offline and audit-friendly validation

---

## Table of Contents

1. [Introduction](#1-introduction)  
2. [Scope and Layering](#2-scope-and-layering)  
3. [Terminology](#3-terminology)  
4. [Architecture Overview](#4-architecture-overview)  
5. [Trust Model](#5-trust-model)  
6. [Cryptographic Model](#6-cryptographic-model)  
7. [Evidence Model](#7-evidence-model)  
8. [Evidence Binding Rules](#8-evidence-binding-rules)  
9. [Timestamp Model](#9-timestamp-model)  
10. [Transparency Model](#10-transparency-model)  
11. [DNS Trust Anchoring (TAPS)](#11-dns-trust-anchoring-taps)  
12. [Discovery Trust](#12-discovery-trust)  
13. [Validation Model](#13-validation-model)  
14. [Publisher Responsibilities](#14-publisher-responsibilities)  
15. [Consumer Responsibilities](#15-consumer-responsibilities)  
16. [Security Considerations](#16-security-considerations)  
17. [Normative References](#17-normative-references)  
18. [Informative References](#18-informative-references)  

---

## 1. Introduction

The TEA Trust Architecture extends TEA from a **data exchange protocol** into a **verifiable trust system**.

Base TEA allows:

- structured artifact exchange
- SBOM distribution
- release metadata publication

The Trust Architecture adds:

> **cryptographically verifiable, time-bound, and independently auditable trust**

The core design principle is:

> Trust is not tied to long-lived keys, but to **evidence**.

---

## 2. Scope and Layering

### 2.1 Optional overlay

The Trust Architecture is:

- OPTIONAL
- fully compatible with base TEA
- incrementally adoptable

### 2.2 Separation of concerns

| Layer | Responsibility |
|------|----------------|
| TEA Core | Data model and APIs |
| Trust Architecture | Trust, validation, evidence |
| Profiles | Policy constraints |

### 2.3 Key consequence

A TEA system may:

- operate without trust architecture (basic mode)
- enforce trust architecture (high assurance mode)

---

## 3. Terminology

- **TEA artifact**: immutable content object (SBOM, binary, etc.)
- **TEA collection**: release statement binding artifacts
- **Evidence bundle**: cryptographic proof container
- **Trust anchor**: root of trust published via DNS
- **TAPS**: Trust Anchor Publication Service
- **TSA**: Time Stamp Authority
- **Transparency log**: append-only verifiable log (Rekor, Sigsum, SCITT)

---

## 4. Architecture Overview

The Trust Architecture introduces three interacting domains:

### 4.1 Discovery domain
- resolves TEI → API endpoints
- provides signed metadata

### 4.2 Publication domain
- creates artifacts and collections
- generates signatures and evidence

### 4.3 Consumption domain
- validates artifacts and collections
- evaluates trust evidence

---

## 5. Trust Model

The TEA trust model is **evidence-based**, not revocation-based.

### 5.1 Key principles

- short-lived certificates (< 1 hour)
- no reliance on revocation
- long-term validation via evidence
- distributed trust (DNS, TSA, transparency)

### 5.2 Rationale

Traditional PKI depends on:

- long-lived certificates
- revocation infrastructure

These are fragile over long time periods.

TEA replaces this with:

- **ephemeral signing keys**
- **durable evidence**

---

## 6. Cryptographic Model

### 6.1 Key pairs and certificates

- Signing is performed using **private keys in key pairs**
- Public keys are embedded in certificates
- Certificates act as **validity wrappers**, not identities

### 6.2 Algorithm requirements

- **Ed25519 MUST be used**
- No other algorithms are permitted

### 6.3 Certificate constraints

- Lifetime MUST be **< 1 hour**
- Exactly one DNS SAN required
- Optional second SAN allowed (backup domain)

### 6.4 Key reuse prohibition

> A key pair MUST NOT be reused across certificates.

Publishers MUST enforce:

- no reuse of public key fingerprints
- rejection of duplicate keys in publication workflows

### 6.5 Rationale

This ensures:

- no long-term key exposure risk
- no dependency on revocation
- clean trust boundaries

---

## 7. Evidence Model

### 7.1 Core concept

An **evidence bundle** is the unit of trust.

It contains:

- signature
- certificate (with public key)
- timestamp(s)
- transparency proof(s) (optional)

### 7.2 Why bundles exist

Validation requires multiple pieces of information:

- signature alone is insufficient
- certificate alone is insufficient
- timestamp alone is insufficient

The bundle combines all required elements.

---

## 8. Evidence Binding Rules

### 8.1 Binding target

Evidence bundles bind to:

- **TEA artifacts**
- **TEA collections**
- **discovery documents**

### 8.2 Artifact evidence reuse

Artifact evidence bundles:

- MAY be reused across collections
- represent immutable content

### 8.3 Collection evidence reuse

Collection evidence bundles:

- MUST NOT be reused across collections
- represent unique release statements

### 8.4 External bundle integrity

When an evidence bundle is external:

- it MUST be referenced with a SHA-256 digest
- digest MUST be over canonical JSON (RFC 8785)

---

## 9. Timestamp Model

### 9.1 Requirement

Timestamps are:

> REQUIRED in the Trust Architecture

### 9.2 What timestamps prove

- existence of signature at a given time
- ordering of events
- protection against backdating

### 9.3 Trust model

Trust in timestamps relies on:

- trusted TSAs
- cryptographic binding to signature

### 9.4 Operational guidance

- multiple TSAs SHOULD be used
- timestamp consistency SHOULD be monitored

---

## 10. Transparency Model

### 10.1 Optional but recommended

Transparency logging is:

- OPTIONAL
- profile-driven

Supported systems:

- Rekor
- Sigsum
- SCITT

### 10.2 What transparency provides

- append-only logging
- detection of equivocation
- auditability

### 10.3 Trust model

Trust depends on:

- log integrity
- inclusion proofs
- witness systems (e.g. Sigsum)

---

## 11. DNS Trust Anchoring (TAPS)

### 11.1 Concept

TAPS publishes trust anchors via DNS.

### 11.2 Mechanism

- DNS CERT records contain certificates
- DNSSEC MAY protect integrity

### 11.3 Role

DNS provides:

- initial trust anchor distribution
- independence from API endpoints

### 11.4 WebPKI interaction

Even in WebPKI mode:

- DNS CAA records SHOULD be used
- DNSSEC MAY strengthen validation

---

## 12. Discovery Trust

### 12.1 Separation

Discovery trust is separate from artifact trust.

### 12.2 Requirements

In Trust Architecture:

- discovery MUST be signed
- discovery MUST include timestamp

### 12.3 Rationale

Discovery establishes:

- service location
- trust context

---

## 13. Validation Model

### 13.1 Artifact validation

- verify signature
- validate certificate
- verify timestamp
- verify transparency (if present)

### 13.2 Collection validation

- verify collection integrity
- validate collection evidence (if present)

### 13.3 Combined result

A valid system must conclude:

> artifact is authentic AND belongs to this collection

---

## 14. Publisher Responsibilities

Publishers MUST:

- generate unique key pairs
- prevent key reuse
- produce evidence bundles
- timestamp all signatures
- optionally log to transparency systems
- publish trust anchors in DNS

---

## 15. Consumer Responsibilities

Consumers MUST:

- validate signatures
- validate timestamps
- verify evidence bundle integrity
- enforce policy rules

Consumers SHOULD:

- validate transparency logs
- verify DNS trust anchors

---

## 16. Security Considerations

### 16.1 Key compromise

Mitigated by:

- short-lived keys
- no reuse

### 16.2 Time manipulation

Mitigated by:

- trusted timestamps
- multiple TSAs

### 16.3 DNS attacks

Mitigated by:

- DNSSEC (optional)
- independent validation

### 16.4 Transparency risks

Mitigated by:

- multiple logs
- witness verification

---

## 17. Normative References

- RFC 2119 / RFC 8174 — Requirement keywords  
- RFC 5280 — X.509  
- RFC 6962 — Certificate Transparency  
- RFC 3161 — Time-Stamp Protocol  
- RFC 4033–4035 — DNSSEC  
- RFC 6844 — CAA Records  
- RFC 8785 — JSON Canonicalization Scheme  

---

## 18. Informative References

- Rekor Transparency Log  
- Sigsum Transparency Log  
- IETF SCITT Architecture  
- EU Cyber Resilience Act (CRA)  

---

## Final Statement

The TEA Trust Architecture establishes that:

> Trust is not derived from long-lived keys,  
> but from verifiable, time-bound, and independently auditable evidence.

This enables:

- long-term validation
- offline verification
- resilience against infrastructure changes

and aligns TEA with modern regulatory and operational requirements.
