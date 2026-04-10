# 📘 TEA Trust Architecture — High Assurance Profile
**Version:** 1.0  
**Status:** Draft (Normative, Implementation-Ready)

---

## Status

This document defines the **High Assurance Profile** for the TEA Trust Architecture.

This profile specifies **strict validation and publication requirements** intended for:

- regulated environments (e.g., CRA-aligned systems)  
- safety-critical software supply chains  
- long-term validation (≥10 years)  

The key words **MUST**, **SHOULD**, and **MAY** are to be interpreted as described in:

- RFC 2119  
- RFC 8174  

---

## Table of Contents

1. [Purpose](#1-purpose)  
2. [Scope](#2-scope)  
3. [Core Principles](#3-core-principles)  
4. [Trust Model Requirements](#4-trust-model-requirements)  
5. [Signature and Certificate Requirements](#5-signature-and-certificate-requirements)  
6. [Timestamp Requirements](#6-timestamp-requirements)  
7. [Transparency Requirements (Sigsum)](#7-transparency-requirements-sigsum)  
8. [Evidence Bundle Requirements](#8-evidence-bundle-requirements)  
9. [Evidence Binding Requirements](#9-evidence-binding-requirements)  
10. [Publication Requirements](#10-publication-requirements)  
11. [Consumer Validation Requirements](#11-consumer-validation-requirements)  
12. [Trust Anchors](#12-trust-anchors)  
13. [Failure Handling](#13-failure-handling)  
14. [Security Considerations](#14-security-considerations)  
15. [Final Statement](#15-final-statement)  

---

## 1. Purpose

This profile defines a **strict validation and publication policy** for TEA.

It ensures that:

- trust is derived from multiple independent evidence sources  
- long-term validation is possible without relying on live services  
- publication is controlled and auditable  

---

## 2. Scope

This profile applies to:

- TEA artifacts  
- TEA collections  
- discovery documents (when signed)  
- signing certificates  

---

## 3. Core Principles

### 3.1 Multi-Source Trust

Trust MUST be derived from:

- signature  
- timestamp  
- transparency  
- trust anchor validation  

---

### 3.2 Evidence Over Keys

Long-term trust is based on:

> preserved evidence, not persistent keys

---

### 3.3 Immutability

All published objects:

- MUST be immutable  
- MUST remain available  

---

### 3.4 Offline Verifiability

Validation MUST be possible without:

- network access  
- live log queries  

---

## 4. Trust Model Requirements

This profile requires:

- TEA-native trust model OR WebPKI with additional constraints  
- strict evidence validation  

For TEA-native:

- DNS-based trust anchors MUST be used  
- DNSSEC SHOULD be used when available  

---

## 5. Signature and Certificate Requirements

### 5.1 Algorithms

- Ed25519 SHOULD be used  

---

### 5.2 Certificate Lifetime

Certificates MUST:

- be short-lived  
- have a lifetime ≤ 1 hour  

---

### 5.3 Key Usage

- keys MUST be ephemeral  
- private keys MUST be destroyed after signing  

---

### 5.4 Certificate Binding

Certificates MUST:

- contain exactly one primary SAN DNS entry  
- the primary SAN DNS entry MUST:
  - represent the manufacturer-controlled domain  
  - include the fingerprint-derived identifier  

Certificates MAY additionally include:

- one optional secondary SAN DNS entry  

The secondary SAN:

- MUST NOT be under the manufacturer-controlled domain  
- SHOULD be controlled by an independent or long-term stable domain  
- MUST use the same fingerprint-derived identifier  

#### 5.4.1 Rationale

The optional secondary SAN enables:

- long-term accessibility of trust anchors  
- resilience against:
  - company closure  
  - domain loss  
  - acquisition or restructuring  

#### 5.4.2 Constraints

The following constraints apply:

- maximum of two SAN DNS entries  
- exactly one primary SAN (manufacturer domain)  
- at most one secondary SAN (external domain)  
- both SAN entries MUST refer to the same public key identity  

---

## 6. Timestamp Requirements

### 6.1 Mandatory Timestamp

All signed objects MUST have:

- at least one RFC 3161 timestamp  

---

### 6.2 Dual Timestamping

Implementations SHOULD use:

- at least two independent TSAs  

---

### 6.3 Binding

```text
timestamp.messageImprint = SHA-256(signature)
```

---

### 6.4 Validity Constraint

```text
timestamp ∈ [certificate.notBefore, certificate.notAfter]
```

---

## 7. Transparency Requirements (Sigsum)

### 7.1 Mandatory Use

Sigsum MUST be used for transparency.

---

### 7.2 Objects to Log

The following MUST be logged:

- short-lived signing certificates  
- TEA collections  
- TEA artifacts requiring independent authenticity  

---

### 7.3 Witness Requirements

Implementations MUST require:

- multiple independent witnesses  

Minimum:

- 2 witnesses  

Recommended:

- 3+ witnesses  

---

### 7.4 Witness Verification

Consumers MUST verify:

- witness signatures  
- consistency of checkpoints  

---

### 7.5 Binding

Sigsum entries MUST correspond to:

```text
SHA-256(signature)
```

or:

```text
SHA-256(timestamped_signature)
```

---

### 7.6 Offline Verification

Evidence MUST allow:

- offline verification of inclusion proofs  
- verification of cosigned checkpoints  

---

## 8. Evidence Bundle Requirements

Each TEA artifact MUST have:

- exactly one evidence bundle  

The bundle MUST include:

- signature  
- certificate  
- timestamp(s)  
- Sigsum inclusion proof  
- cosigned checkpoint  
- witness signatures  

---

## 9. Evidence Binding Requirements

Evidence MUST be bound as:

```text
artifact → signature → timestamp → transparency
```

Consumers MUST verify:

- binding consistency  
- digest matching  

---

## 10. Publication Requirements

### 10.1 Commit Control

Publication MUST:

- require human approval  
- require strong authentication (MFA)  

---

### 10.2 Commit Validation

The commit step MUST:

- validate all evidence  
- enforce profile compliance  
- reject incomplete data  

---

### 10.3 CI/CD Constraints

CI/CD:

- MAY prepare releases  
- MUST NOT publish releases  

---

## 11. Consumer Validation Requirements

Consumers MUST:

1. verify signature  
2. validate certificate  
3. validate timestamp  
4. verify Sigsum inclusion  
5. verify witness signatures  
6. verify binding  
7. enforce policy  

---

## 12. Trust Anchors

Trust anchors include:

- TEA DNS-published certificates (TEA-native)  
- WebPKI roots (if applicable)  
- Sigsum log public keys  
- Sigsum witness public keys  

Implementations MUST define:

- accepted logs  
- accepted witnesses  
- quorum policy  

---

## 13. Failure Handling

Validation MUST fail if:

- any required evidence is missing  
- any binding mismatch occurs  
- witness quorum is not satisfied  
- timestamp validation fails  
- certificate validation fails  

---

## 14. Security Considerations

### 14.1 Key Exposure

Short-lived keys reduce:

- compromise impact  
- revocation complexity  

---

### 14.2 Log Integrity

Witnesses prevent:

- split-view attacks  
- silent log rewriting  

---

### 14.3 Long-Term Validation

Preserved evidence ensures:

- future verification  
- auditability  

---

## 15. Final Statement

This profile enforces a **high-assurance trust model** where:

- trust is derived from independent evidence sources  
- validation is deterministic and reproducible  
- publication is controlled and auditable  

---

### Key Principle

> High assurance is achieved by requiring consistency across independent systems, not by trusting any single authority.
