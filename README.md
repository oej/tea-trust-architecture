# TEA Trust Architecture

> *CycloneDX tells you what is inside  
> TEA tells you where to get it  
> TEA Trust Architecture tells you why you can believe it*

**Version:** 1.0.0  

---

## Status

This document defines the **TEA Trust Architecture**, an optional normative overlay to the Transparency Exchange API (TEA).

This specification is **implementation-ready** but subject to change based on implementation experience and community feedback.

The key words **MUST**, **SHOULD**, and **MAY** are to be interpreted as described in RFC 2119.

This document is part of the TEA specification suite and is intended to be used together with:

- TEA core specifications (TEI, Discovery, APIs)  
- TEA Conformance specification  
- TEA Evidence Bundle and Validation specifications  

---

## 1. Introduction

The **TEA Trust Architecture** is an optional overlay to the Transparency Exchange API (TEA).

It defines how to establish **verifiable, long-term trust** in TEA artefacts and collections using cryptographic evidence.

While TEA defines:
- how artefacts are identified  
- how services are discovered  
- how data is retrieved  

The TEA Trust Architecture defines:

> **how that data can be trusted — now and in the future**

---

## 2. Problem Statement

Traditional digital signatures provide:

- integrity  
- identity  

But they do **not** provide:

- durable proof of *when* something was signed  
- protection against backdating  
- public auditability  
- long-term verifiability after certificate expiry  

This becomes critical in regulatory environments such as the EU Cyber Resilience Act (CRA), where:

- artefacts must remain verifiable for ≥10 years  
- validation must work after infrastructure changes  
- historical states must be auditable  

---

## 3. Solution Overview

The TEA Trust Architecture extends TEA with **evidence-based validation**.

It combines:

- **Signatures** → integrity and identity  
- **Timestamps (RFC 3161)** → proof of existence in time  
- **Transparency logs (Rekor, Sigsum, SCITT)** → public visibility and auditability  
- **DNS / PKI trust anchors** → decentralized trust distribution  

These are packaged into:

> **Evidence Bundles — the atomic unit of trust**

---

## 4. Core Design Principles

### 4.1 Evidence Over Infrastructure Trust
Trust MUST be derived from verifiable evidence, not runtime infrastructure.

---

### 4.2 Short-Lived Keys, Long-Lived Evidence

- Signing certificates MUST be short-lived (≤ 1 hour)  
- Long-term trust is provided by:
  - timestamps  
  - transparency evidence  

---

### 4.3 Time Anchoring

Timestamps:

- prove when a signature existed  
- ensure the certificate was valid at signing time  
- prevent backdating  

---

### 4.4 Transparency and Auditability

Transparency systems provide:

- append-only logs  
- inclusion proofs  
- detection of hidden or conflicting states  

---

### 4.5 Decentralized Trust Anchoring

Trust anchors MAY be:

- X.509 PKIX  
- DNS-based (TAPS)  
- raw public keys  

DNSSEC MAY strengthen DNS-based trust but is not mandatory.

---

## 5. Evidence Bundle

An **evidence bundle** contains all material required to validate a signed object:

- signature  
- signing certificate  
- timestamp evidence  
- transparency evidence  

Properties:

- applies to a single signed object  
- supports offline validation  
- enables long-term verification  

---

## 6. Trust Domains

The TEA Trust Architecture defines three independent but connected trust domains:

### 6.1 Discovery Trust

> “Am I talking to the correct TEA service?”

Requires:

- signed discovery document  
- timestamp (MUST)  
- optional transparency evidence  

---

### 6.2 Consumer Trust

> “Are these artefacts correct and authentic?”

Validates:

- integrity  
- authenticity  
- time of signing  
- publication evidence  

---

### 6.3 Publication Trust

> “Was this release intentionally published?”

Ensures:

- human authorization  
- controlled commit step  
- auditable release  

---

## 7. Artefact-Centric Validation

Artefacts are **first-class verifiable objects**.

They MUST be retrievable independently of collections.

An artefact may be retrieved as:

- artefact only  
- artefact + detached signature  
- artefact + evidence bundle  

> Artefact validation MUST NOT depend on a collection.

---

## 8. Validation Model

Validation follows:

```
object → signature → certificate → timestamp → transparency
```

Each layer MUST bind to the same cryptographic object.

---

## 9. Relationship to TEA

The TEA Trust Architecture:

- does NOT replace TEA  
- extends TEA with trust semantics  

---

## 10. Compliance Alignment

Supports:

- long-term validation  
- auditability  
- lifecycle traceability  

Aligned with:

- EU Cyber Resilience Act (CRA)

---

## 11. Summary

The TEA Trust Architecture establishes:

- signatures → integrity  
- timestamps → time anchoring  
- transparency → public accountability  

Together, they transform:

> **ephemeral signatures into durable, verifiable trust**
