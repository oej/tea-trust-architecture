# 📘 TEA Trust Architecture — Core Specification (v1.6) {#tea-core-spec}

---

# Table of Contents

1. [Introduction](#introduction)  
2. [Background and Problem Statement](#background)  
3. [Trust Architecture Overview](#trust-architecture)  
4. [Identity and Key Model](#identity-model)  
5. [Trust Models](#trust-models)  
6. [Signature Model](#signature-model)  
7. [Evidence Model](#evidence-model)  
8. [Evidence Binding Rules](#evidence-binding)  
9. [Discovery Trust](#discovery)  
10. [Consumer Validation](#consumer-validation)  
11. [Publication Trust](#publication)  
12. [Validation Profiles](#validation-profiles)  
13. [Security Considerations](#security)  
14. [CRA Alignment](#cra)  
15. [Final Rules](#final-rules)  
16. [Conclusion](#conclusion)  

---

# 1. Introduction {#introduction}

The Transparency Exchange API (TEA) enables distribution of software transparency artefacts such as SBOMs, attestations, and release metadata.

This document defines the **TEA Trust Architecture**, which is an:

> **optional security overlay to the core TEA specification**

The core TEA specification defines *how artefacts are exchanged*.  
This document defines *how those artefacts are trusted*.

---

## 1.1 Architectural Philosophy

Traditional systems answer:

> “Is this valid right now?”

TEA answers:

> **“Was this valid at the time it was created, and can we prove it?”**

This shift is essential for:

- long-term validation  
- regulatory compliance  
- supply chain auditability  

---

## 1.2 Reader Guidance

This document contains:

- **normative requirements** (MUST / SHOULD / MAY)  
- **rationale sections** explaining design choices  
- **implementation hints** for practical adoption  

---

## 1.3 Trusted Delivery vs Trusted Content

The TEA Trust Architecture provides **trusted delivery**, not **trusted content**.

It enables verification that:

- an artefact has not been modified  
- an artefact was produced by a specific identity  
- an artefact existed at a provable point in time  

However, it does **not** guarantee that:

- the contents of the artefact are correct  
- SBOMs are complete  
- vulnerability statements are accurate  
- compliance claims are valid  

---

# 2. Background and Problem Statement {#background}

## 2.1 The Long-Term Validation Problem

Software artefacts must often be validated:

- years after release  
- after certificates expire  
- after infrastructure changes  

Traditional PKI fails in this scenario because:

- revocation data disappears  
- trust chains become unverifiable  
- root stores change  

---

## 2.2 The Key Risk

The most important failure mode is:

> **A validly signed but unauthorized or unverifiable artefact**

This can occur when:

- keys are compromised  
- infrastructure is unavailable  
- provenance is unclear  

---

## 2.3 TEA Design Strategy

TEA addresses this by:

- minimizing reliance on infrastructure  
- eliminating long-lived secrets  
- preserving verifiable evidence  

---

# 3. Trust Architecture Overview {#trust-architecture}

TEA separates trust into three domains:

| Domain | Purpose |
|--------|--------|
| Discovery | Identify correct service |
| Consumer Validation | Verify artefacts |
| Publication | Ensure authorization |

---

## 3.1 Why This Separation Exists

Many systems fail because they:

- trust the transport layer too much  
- ignore publication control  
- conflate identity with integrity  

TEA explicitly separates these concerns.

---

## Implementation Hint

Implement these domains as **independent validation steps**, not a single pipeline.

---

# 4. Identity and Key Model {#identity-model}

## 4.1 Identity Definition

> A public key is the identity.

Certificates:

- do not define identity  
- only define validity and metadata  

---

## 4.2 Ephemeral Key Model {#ephemeral-keys}

Keys MUST:

- be generated per signing event  
- be used once  
- be destroyed immediately  

Certificates MUST:

- have a maximum validity of **1 hour**

---

### Rationale

This removes the need for:

- HSM ceremonies  
- long-term key storage  
- revocation infrastructure  

---

### Security Effect

- reduces attack window to minutes/hours  
- makes key compromise low-impact  

---

## Implementation Hint

Use:

- in-memory key generation  
- hardware-backed ephemeral keys where possible  
- automatic key destruction after signing  

---

## 4.3 Fingerprint-Derived Identity

```text
fingerprint = SHA-256(public key)
SAN = <fingerprint>.<trust-domain>
```

---

### Rationale

This avoids:

- naming ambiguity  
- CA dependency  
- identity spoofing  

---

# 5. Trust Models {#trust-models}

## 5.1 TEA-Native

Defines DNS-based trust anchor publication when DNS is used according to this trust model.

---

### Rationale

- publisher controls identity  
- no dependency on CA issuance  

---

### Implementation Hint

Publish certificates using DNS CERT records.  
Enable DNSSEC where feasible.

---

## 5.2 WebPKI

Uses standard PKIX validation.

---

### Trade-Off

| Advantage | Disadvantage |
|----------|-------------|
| widely supported | centralized trust |

---

# 6. Signature Model {#signature-model}

## 6.1 Two Independent Signatures

TEA defines:

- TEA collection signature  
- TEA artefact signature  

---

## 6.2 TEA Collection Signature

Defines release composition.

---

### Rationale

Separates:

- “what is in the release”  
from  
- “what the artefact is”  

---

## 6.3 TEA Artefact Signature

Defines artefact authenticity.

---

## Implementation Hint

Always validate **both layers** independently.

---

# 7. Evidence Model {#evidence-model}

## 7.1 Why Evidence Instead of Revocation

Revocation answers:

> “Is this key still valid?”

TEA answers:

> “Was this valid when it mattered?”

---

## 7.2 Timestamp (RFC 3161)

A timestamp proves:

> A signature existed at time T.

---

### Rationale

- enables validation after certificate expiry  
- removes need for revocation  

---

## Implementation Hint

Use at least one trusted TSA.  
Consider multiple TSAs for high assurance.

---

## 7.3 Transparency Logs

Transparency provides:

- proof of existence  
- ordering  
- auditability  

---

### Rationale

Transparency does not prevent attacks — it makes them visible.

---

## Implementation Hint

Store:

- inclusion proof  
- log identifier  
- log checkpoint  

---

## 7.4 Combined Meaning

| Mechanism | Meaning |
|----------|--------|
| Signature | who |
| Timestamp | when |
| Transparency | that |

---

# 8. Evidence Binding Rules {#evidence-binding}

All signatures MUST:

- be timestamped  
- be verifiable within certificate validity  

---

## Rationale

Without time binding:

- expired certificates cannot be validated  
- revocation becomes required  

---

# 9. Discovery Trust {#discovery}

Discovery establishes:

> manufacturer → TEA service mapping

---

## Requirements

Discovery MUST:

- be signed  
- include timestamp  

---

## Rationale

Prevents:

- endpoint spoofing  
- replay attacks  

---

## Implementation Hint

Cache discovery responses, but always validate signature + timestamp.

---

# 10. Consumer Validation {#consumer-validation}

Consumers MUST validate:

1. TEA collection signature  
2. timestamp  
3. checksum binding  
4. certificate validity at timestamp  
5. identity binding  

---

## Rationale

Each step addresses a different risk:

| Step | Risk |
|------|------|
| signature | tampering |
| timestamp | backdating |
| checksum | substitution |

---

## 10.1 Lifecycle (CLE) Validation

Lifecycle (CLE) documents:

- MUST be signed  
- MUST be versioned  
- MUST be validated using the same mechanisms as collections  

Consumers MUST:

- be able to retrieve previous CLE versions  
- compare lifecycle history over time  

---

# 11. Publication Trust {#publication}

## 11.1 Core Principle

> A valid signature does NOT imply authorization.

---

## 11.2 Commit Model

Publication MUST:

- require human approval  
- use MFA  
- record identity  

---

## Rationale

Prevents:

- CI/CD takeover attacks  
- unauthorized releases  

---

## 11.3 Messaging and Events

Systems SHOULD support:

- asynchronous events  
- workflow integration  

---

## 11.4 Audit Logging

Systems MUST log:

- operations  
- actors  
- results  

---

## Implementation Hint

Logs should be:

- immutable  
- exportable  
- queryable  

---

## 11.5 Lifecycle (CLE) Publication

Lifecycle (CLE) updates:

- MUST follow the same commit and authorization model as collections  
- MUST be versioned  
- MUST be auditable  

---

# 12. Validation Profiles {#validation-profiles}

Profiles allow different assurance levels:

- Baseline  
- Enhanced  
- High Assurance  

---

# 13. Security Considerations {#security}

## Strengths

- minimal key exposure  
- no revocation dependency  
- distributed trust  

---

## Residual Risks

- TSA compromise  
- DNS attacks  
- CA compromise  

---

# 14. CRA Alignment {#cra}

TEA supports:

- lifecycle validation  
- SBOM traceability  
- long-term auditability  
- structured lifecycle communication through CLE  

---

# 15. Final Rules {#final-rules}

1. Signatures MUST be timestamped  
2. Certificates MUST be ≤ 1 hour  
3. Publication MUST be authorized  
4. Partial validation MUST fail  

---

# 16. Conclusion {#conclusion}

TEA establishes a new model:

> **Trust is preserved by evidence, not by infrastructure or long-lived keys.**

---
