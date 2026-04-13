# 📘 TEA Trust Architecture — Sigsum Profile
**Version:** 1.0  
**Status:** Draft (Normative, Implementation-Ready)

---

## Status

This document defines a **TEA implementation profile** for using **Sigsum** as a transparency backend within the TEA trust architecture.

This specification is **implementation-ready** but subject to change based on implementation experience and community feedback.

The key words **MUST**, **SHOULD**, and **MAY** are to be interpreted as described in:

- RFC 2119  
- RFC 8174  

---

## Table of Contents

1. [Purpose](#1-purpose)  
2. [Scope](#2-scope)  
3. [Relationship to the TEA Trust Architecture](#3-relationship-to-the-tea-trust-architecture)  
4. [Sigsum Security Model](#4-sigsum-security-model)  
5. [A Practical View: Logs, Witnesses, and Trust](#5-a-practical-view-logs-witnesses-and-trust)  
6. [What Is Logged in Sigsum](#6-what-is-logged-in-sigsum)  
7. [Cryptographic Binding Model](#7-cryptographic-binding-model)  
8. [Logging Requirements by TEA Object Type](#8-logging-requirements-by-tea-object-type)  
9. [Verification Material and Evidence Bundles](#9-verification-material-and-evidence-bundles)  
10. [Validation Requirements](#10-validation-requirements)  
11. [Trust Anchors](#11-trust-anchors)  
12. [Trusting Sigsum as a Service](#12-trusting-sigsum-as-a-service)  
13. [Failure Handling](#13-failure-handling)  
14. [Privacy Considerations](#14-privacy-considerations)  
15. [Profiles](#15-profiles)  
16. [External References](#16-external-references)  
17. [Final Statement](#17-final-statement)  

---

## 1. Purpose

This profile defines how TEA uses **Sigsum** as a transparency backend.

It is an implementation profile for the TEA transparency layer, not a replacement for the TEA trust architecture.

Sigsum provides:

- transparency evidence  
- inclusion proofs  
- append-only log guarantees  
- witness-backed verification of log consistency  

TEA still relies on its own trust model for:

- certificate validation  
- timestamp validation  
- DNS or PKIX anchoring  
- publication authorization  
- TEA collection semantics  

---

## 2. Scope

This profile applies to:

- short-lived TEA signing certificates  
- signed TEA collections  
- signed TEA artifacts  
- signed attestations  
- optionally signed discovery documents  

Sigsum is NOT:

- a TEA artifact repository  
- a trust anchor  
- a timestamp authority  
- a replacement for evidence bundles  

---

## 3. Relationship to the TEA Trust Architecture

Transparency is one **independent trust layer**.

Sigsum complements:

- signatures (authenticity)  
- timestamps (time ordering)  
- DNS/PKIX (identity anchoring)  
- publication controls (intent)  

No single component is trusted alone.

---

## 4. Sigsum Security Model

Sigsum logs **signed checksums** in an append-only Merkle tree.

It provides:

- verifiable inclusion  
- append-only guarantees  
- consistency proofs  
- witness-backed checkpoints  

Sigsum does NOT provide:

- identity trust  
- correctness of content  
- authorization of publication  

These are handled by TEA.

---

## 5. A Practical View: Logs, Witnesses, and Trust

### The Problem

A log alone could attempt to:

- present different histories to different users  
- rewrite or hide entries  

This is known as a **split-view attack**, described in RFC 6962.

---

### The Sigsum Model

| Role | Responsibility |
|------|---------------|
| Log | Maintains append-only Merkle tree |
| Witnesses | Verify and co-sign checkpoints |
| Clients | Verify proofs and consistency |

---

### Step 1 — Submission

A TEA object is submitted in its signed form.

The log:

- appends it  
- returns an inclusion promise  

---

### Step 2 — Checkpoint

The log produces a checkpoint:

- tree root hash  
- tree size  
- log signature  

Equivalent to a **Signed Tree Head (STH)** in RFC 6962.

---

### Step 3 — Witness Cosigning

Witnesses:

- verify consistency  
- co-sign checkpoints  

Result:

- **cosigned checkpoint**

---

### Step 4 — Distribution

The checkpoint is:

- published  
- cached  
- included in evidence bundles  

---

### Step 5 — Consumer Verification

The consumer verifies:

1. inclusion proof  
2. log signature  
3. witness signatures  
4. consistency  

---

### Key Insight

> The log provides transparency, but witnesses provide accountability.

---

## 6. What Is Logged in Sigsum

Sigsum logs:

- signed checksums  

It MUST NOT be used to store:

- TEA artifacts  
- TEA collections  
- certificates  

TEA MUST store full objects separately.

---

## 7. Cryptographic Binding Model

### Core Rule

```text
artifact → signature → timestamp(signature) → Sigsum log
```

### Binding Requirements

```text
timestamp.messageImprint == SHA-256(signature)
```

Sigsum MUST log:

```text
SHA-256(signature)
```

or:

```text
SHA-256(timestamped_signature)
```

Mismatch → validation MUST fail.

---

## 8. Logging Requirements by TEA Object Type

### Certificates

SHOULD be logged.

---

### TEA Collections

SHOULD be logged.

---

### TEA Artifacts

SHOULD be logged if independently verifiable.

---

### Discovery

MAY be logged.

---

### High Assurance

MUST log:

- certificates  
- collections  
- critical artifacts  

---

## 9. Verification Material and Evidence Bundles

Evidence bundles MUST include:

- inclusion proof  
- checkpoint  
- log identifier  
- witness signatures  
- binding digest  

Offline validation MUST be supported.

---

## 10. Validation Requirements

Consumers MUST verify:

1. signature  
2. certificate  
3. timestamp  
4. binding  
5. inclusion proof  
6. checkpoint signature  
7. witness signatures  

---

## 11. Trust Anchors

Sigsum is NOT a trust anchor.

Trust anchors in this profile include:

### 11.1 Log Public Keys

Consumers MUST trust:

- specific Sigsum log public keys  

---

### 11.2 Witness Public Keys

Consumers MUST trust:

- configured witness identities  

Policy MAY require:

- multiple witnesses  
- quorum validation  

---

### 11.3 Policy Definition

Implementations MUST define:

- accepted logs  
- accepted witnesses  
- required quorum  

---

## 12. Trusting Sigsum as a Service

Sigsum is trusted as:

> a verifiable transparency witness

NOT as:

- identity provider  
- authority  

---

## 13. Failure Handling

| Condition | Result |
|----------|--------|
| invalid proof | FAIL |
| invalid checkpoint | FAIL |
| invalid witness | FAIL |
| binding mismatch | FAIL |

---

## 14. Privacy Considerations

Sigsum logs minimal data.

Implementations SHOULD assess:

- correlation risk  
- metadata exposure  

---

## 15. Profiles

### Minimal

- log collection  
- log certificate  

---

### Recommended

- log artifacts  
- preserve proofs  

---

### High Assurance

- multiple witnesses  
- strict policy  
- offline validation  

---

## 16. External References

- RFC 2119 — Requirement Levels  
- RFC 8174 — Requirement Keywords Clarification  
- RFC 3161 — Time-Stamp Protocol  
- RFC 6962 — Certificate Transparency  
- Sigsum Design: https://git.sigsum.org/sigsum/tree/doc/design.md  
- Sigsum Project: https://www.sigsum.org/  

---

## 17. Final Statement

Sigsum provides transparency evidence by making signed statements publicly auditable.

It is:

- a transparency mechanism  
- an audit layer  

It is NOT:

- a trust anchor  
- a source of truth  

---

### Key Principle

> Transparency provides evidence. Trust comes from verification.
