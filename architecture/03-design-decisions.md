# 📘 TEA Trust Architecture – Design Decisions
**Version:** 1.0  
**Status:** Draft (Non-Normative, Authoritative Rationale)

---

## Status

This document captures the **design decisions and rationale** behind the TEA Trust Architecture.

It is **non-normative**, but authoritative. It explains:

- why specific technical choices were made
- which alternatives were considered
- what trade-offs were accepted

This document complements:

- `spec/trust-architecture.md` (normative)
- `spec/evidence-bundle.md`
- `spec/evidence-validation.md`
- `spec/collection.md`

---

## Table of Contents

1. [Introduction](#1-introduction)  
2. [Design Philosophy](#2-design-philosophy)  
3. [Evidence-Centric Trust Model](#3-evidence-centric-trust-model)  
4. [Ephemeral Keys and No Revocation](#4-ephemeral-keys-and-no-revocation)  
5. [Ed25519-Only Decision](#5-ed25519-only-decision)  
6. [No Key Reuse](#6-no-key-reuse)  
7. [Certificate as Validity Wrapper](#7-certificate-as-validity-wrapper)  
8. [Timestamp-First Trust Model](#8-timestamp-first-trust-model)  
9. [Transparency as Optional (Profile-Driven)](#9-transparency-as-optional-profile-driven)  
10. [Evidence Bundle as a First-Class Object](#10-evidence-bundle-as-a-first-class-object)  
11. [Artifact-Centric Evidence Reuse](#11-artifact-centric-evidence-reuse)  
12. [Collection vs Artifact Trust Separation](#12-collection-vs-artifact-trust-separation)  
13. [SHA-256 as the Single Digest Algorithm](#13-sha-256-as-the-single-digest-algorithm)  
14. [JSON Canonicalization Requirement](#14-json-canonicalization-requirement)  
15. [DNS as Trust Anchor Distribution (TAPS)](#15-dns-as-trust-anchor-distribution-taps)  
16. [Discovery Trust Separation](#16-discovery-trust-separation)  
17. [Multipart Delivery Model](#17-multipart-delivery-model)  
18. [CI/CD and Gated Publication](#18-cicd-and-gated-publication)  
19. [Long-Term Validation and CRA Alignment](#19-long-term-validation-and-cra-alignment)  
20. [Rejected Alternatives](#20-rejected-alternatives)  
21. [Summary of Key Decisions](#21-summary-of-key-decisions)  

---

## 1. Introduction

The TEA Trust Architecture was designed to solve a specific problem:

> How can software artifacts be validated reliably **10+ years after publication**, even if:
> - keys are gone  
> - services are offline  
> - organizations no longer exist  

Traditional PKI models do not solve this problem well.

TEA therefore adopts a different approach:

> **Trust is derived from durable evidence, not long-lived keys.**

---

## 2. Design Philosophy

The architecture is guided by a few core principles:

### 2.1 Minimize long-term secrets
Private keys should exist only briefly.

### 2.2 Maximize verifiability
All trust decisions should be independently reproducible.

### 2.3 Avoid centralized dependencies
No single service should be required for validation.

### 2.4 Prefer simple invariants
Fewer algorithms, fewer options, fewer ambiguities.

### 2.5 Separate concerns clearly
- artifact authenticity  
- release composition  
- discovery  
must not be conflated.

---

## 3. Evidence-Centric Trust Model

### Decision

Trust is based on **evidence bundles**, not certificates.

### Rationale

Certificates alone cannot provide:

- long-term verifiability  
- proof of existence in time  
- protection against backdating  

Evidence bundles combine:

- signature  
- certificate  
- timestamp  
- transparency  

### Consequence

Validation always operates on a **complete set of evidence**, not a single artifact.

---

## 4. Ephemeral Keys and No Revocation

### Decision

- Certificates have lifetime **< 1 hour**
- Revocation is not used

### Rationale

Revocation systems:

- do not scale over long time  
- introduce availability dependencies  
- are frequently ignored in practice  

Short-lived keys eliminate the need for revocation.

### Trade-off

- Requires strong timestamping
- Requires strict workflow control

---

## 5. Ed25519-Only Decision

### Decision

Only **Ed25519** is allowed.

### Rationale

- small key size (important for DNS)
- fast signing and verification
- deterministic behavior
- alignment with Sigsum

### Trade-off

- excludes RSA and other algorithms
- reduces flexibility

### Why this is acceptable

TEA prioritizes:

> interoperability and simplicity over algorithm diversity

---

## 6. No Key Reuse

### Decision

A key pair MUST NOT be reused.

### Rationale

Key reuse introduces:

- correlation risks  
- extended attack windows  
- ambiguity in trust evaluation  

### Consequence

Each signing event is:

- isolated  
- independently verifiable  

---

## 7. Certificate as Validity Wrapper

### Decision

Certificates are not identities. They are **validity wrappers**.

### Rationale

Identity is derived from:

- DNS anchoring
- public key fingerprint

The certificate only defines:

- validity period
- binding context

### Consequence

- certificates can be short-lived
- identity persists independently

---

## 8. Timestamp-First Trust Model

### Decision

Timestamps are mandatory in the trust architecture.

### Rationale

Without timestamps:

- signatures can be backdated  
- ordering cannot be established  
- long-term validation breaks  

### Trust basis

Trust in time is derived from:

- TSA signatures  
- cross-verification (multiple TSAs)

---

## 9. Transparency as Optional (Profile-Driven)

### Decision

Transparency logs are **optional**, not mandatory.

### Rationale

Different environments require different trade-offs:

- some need full public transparency
- others require controlled disclosure

### Supported systems

- Rekor  
- Sigsum  
- SCITT  

### Consequence

Profiles define:

- whether transparency is required  
- how it is validated  

---

## 10. Evidence Bundle as a First-Class Object

### Decision

The evidence bundle is explicitly modeled and stored.

### Rationale

Previously, systems treated:

- signatures  
- timestamps  
- logs  

as separate concerns.

This leads to:

- fragmentation  
- incomplete validation  

### Consequence

All trust material is grouped into a single object.

---

## 11. Artifact-Centric Evidence Reuse

### Decision

Evidence bundles are reusable **only for artifacts**.

### Rationale

Artifacts are immutable content.

Collections are contextual statements.

### Consequence

- artifact evidence can be reused across collections  
- collection evidence cannot  

---

## 12. Collection vs Artifact Trust Separation

### Decision

Collection trust and artifact trust are separate.

### Rationale

A collection states:

> "these artifacts belong together"

It does not prove:

> "these artifacts are authentic"

### Consequence

Validation must check:

- artifact evidence  
- collection integrity  

independently.

---

## 13. SHA-256 as the Single Digest Algorithm

### Decision

Only **SHA-256** is allowed.

### Rationale

- avoids downgrade attacks  
- simplifies implementations  
- ensures interoperability  

### Trade-off

- no algorithm agility  

### Future consideration

Algorithm agility may be introduced in future versions if required.

---

## 14. JSON Canonicalization Requirement

### Decision

JSON objects MUST use RFC 8785 canonicalization for hashing.

### Rationale

JSON is not inherently stable:

- field order varies  
- whitespace varies  

Without canonicalization:

- digests are unreliable  

---

## 15. DNS as Trust Anchor Distribution (TAPS)

### Decision

Trust anchors are distributed via DNS (CERT records).

### Rationale

DNS provides:

- global distribution  
- independence from APIs  
- compatibility with existing infrastructure  

### DNSSEC

- optional  
- recommended  

### Trade-off

- DNS is not universally secured  
- requires additional validation layers  

---

## 16. Discovery Trust Separation

### Decision

Discovery trust is separate from artifact trust.

### Rationale

Discovery answers:

> where to go

Artifact evidence answers:

> what to trust

### Consequence

Both must be validated independently.

---

## 17. Multipart Delivery Model

### Decision

Artifacts may be delivered with:

- no evidence  
- detached signature  
- full evidence bundle  

### Rationale

Supports:

- backward compatibility  
- progressive adoption  

---

## 18. CI/CD and Gated Publication

### Decision

Workflow is split:

- CI/CD prepares artifacts  
- commit phase finalizes release  

### Rationale

Fully automated publication introduces risk:

- key misuse  
- incomplete validation  
- policy bypass  

### Consequence

Final release requires:

- human approval  
- strict validation  

---

## 19. Long-Term Validation and CRA Alignment

### Decision

Architecture explicitly supports **≥10 year validation**.

### Rationale

CRA requires:

- long-term availability  
- verifiable integrity  

### How TEA achieves this

- timestamps provide temporal proof  
- evidence bundles preserve validation context  
- no dependency on revocation  

---

## 20. Rejected Alternatives

### 20.1 Long-lived certificates

Rejected because:

- require revocation  
- increase attack surface  

---

### 20.2 Multiple algorithms

Rejected because:

- increases complexity  
- introduces downgrade risks  

---

### 20.3 Signature-only model

Rejected because:

- lacks time proof  
- lacks auditability  

---

### 20.4 Mandatory transparency

Rejected because:

- not suitable for all environments  

---

### 20.5 Embedding evidence in collections

Rejected because:

- prevents reuse  
- increases duplication  
- complicates validation  

---

## 21. Summary of Key Decisions

| Area | Decision |
|------|----------|
| Keys | Ephemeral, no reuse |
| Algorithm | Ed25519 only |
| Digests | SHA-256 only |
| Trust | Evidence-based |
| Timestamp | Mandatory |
| Transparency | Optional |
| Evidence | First-class object |
| DNS | Trust anchor distribution |
| Workflow | Gated publication |

---

## Final Statement

The TEA Trust Architecture deliberately trades:

- flexibility  
- legacy compatibility  

for:

> **clarity, simplicity, and long-term verifiability**

The result is a system where:

- trust can be evaluated independently  
- validation can be performed offline  
- and software integrity can be proven long after publication.
