# 📘 TEA Publisher Workflow Specification
**Version:** 1.0  
**Status:** Draft (Normative, Implementation-Ready)

---

## Status

This document defines the **TEA publisher workflow**, including:

- how TEA artifacts are created and prepared
- how TEA collections are assembled
- how signatures and evidence bundles are generated
- how releases are committed and published
- logging and messaging requirements for the Publisher API

This specification applies to:

- **base TEA**
- **TEA Trust Architecture (overlay)**

The key words **MUST**, **SHOULD**, and **MAY** are to be interpreted as described in:

- RFC 2119  
- RFC 8174  

---

## Table of Contents

1. [Introduction](#1-introduction)  
2. [Workflow Overview](#2-workflow-overview)  
3. [Core Principles](#3-core-principles)  
4. [Artifact Lifecycle](#4-artifact-lifecycle)  
5. [Evidence Bundle Creation](#5-evidence-bundle-creation)  
6. [Collection Assembly](#6-collection-assembly)  
7. [Commit Phase](#7-commit-phase)  
8. [Publication Phase](#8-publication-phase)  
9. [Key Management Requirements](#9-key-management-requirements)  
10. [CI/CD Integration](#10-cicd-integration)  
11. [Messaging Model](#11-messaging-model)  
12. [Logging Requirements](#12-logging-requirements)  
13. [Validation Before Publication](#13-validation-before-publication)  
14. [Error Conditions](#14-error-conditions)  
15. [Security Considerations](#15-security-considerations)  
16. [Normative References](#16-normative-references)  
17. [Informative References](#17-informative-references)  

---

## 1. Introduction

The TEA Publisher Workflow defines how a release moves from:

> **content → signed artifacts → evidence → collection → published release**

The workflow is deliberately split into phases to support:

- automation (CI/CD)
- human approval (gated release)
- strong auditability
- deterministic outputs

A key design goal is:

> **Artifacts become immutable trust objects before publication.**

---

## 2. Workflow Overview

### 2.1 High-level phases

1. Artifact creation  
2. Evidence generation  
3. Collection assembly  
4. Commit (finalization)  
5. Publication  

### 2.2 Flow

```text
Create → Sign → Timestamp → (Transparency) → Bundle → Assemble → Commit → Publish
```

### 2.3 Key separation

- **Preparation phase**: can run in CI/CD  
- **Commit phase**: MUST be controlled and gated  
- **Publication phase**: exposes data to consumers  

---

## 3. Core Principles

### 3.1 Immutability

Once an artifact has:

- signature
- timestamp
- (optional) transparency log inclusion

it becomes:

> **immutable and reusable across collections**

---

### 3.2 Evidence as the trust unit

Trust is not derived from:

- the collection
- the API
- the transport

Trust is derived from:

> **evidence bundles bound to artifacts**

---

### 3.3 Separation of concerns

| Component | Responsibility |
|----------|----------------|
| Artifact | Content |
| Evidence bundle | Trust |
| Collection | Release statement |

---

### 3.4 No key reuse

> A key pair MUST NOT be reused.

This is enforced at publication time.

---

## 4. Artifact Lifecycle

### 4.1 Creation

Artifacts MAY include:

- binaries
- SBOMs (CycloneDX, SPDX)
- configuration files
- metadata

### 4.2 Identification

Each artifact MUST have:

- a stable identifier
- a SHA-256 digest

### 4.3 Storage

Artifacts MUST be stored in a way that ensures:

- immutability
- content-addressable retrieval (recommended)

---

## 5. Evidence Bundle Creation

### 5.1 Steps

For each artifact:

1. Generate a new key pair  
2. Create a certificate (< 1 hour lifetime)  
3. Sign the artifact using the private key (from the key pair associated with the certificate)  
4. Generate timestamp(s)  
5. Submit to a transparency log (Sigsum or Rekor)  
6. Assemble evidence bundle  
7. Upload artifact, signature, and certificate to the Publisher API
9. Publisher API verifies that the signature validates against the artifact using the uploaded certificate

---

### 5.2 Evidence bundle contents

- signature  
- certificate (containing the public key)  
- timestamp(s)  
- transparency proof(s)  

> At least one transparency log inclusion proof (Sigsum or Rekor) MUST be present for TEA Trust Architecture compliance.

The Publisher API MUST verify that the signature is valid for the artifact using the included certificate before accepting the evidence bundle.

---

### 5.3 Canonicalization

If the evidence bundle is JSON:

- MUST use RFC 8785 canonical form for hashing  

---

### 5.4 Result

The artifact + evidence bundle becomes:

> **frozen in time and independently verifiable without reliance on the publisher**

---

## 6. Collection Assembly

### 6.1 Inputs

- artifact references  
- artifact digests  
- optional evidence bundle references  
- release metadata  

### 6.2 Rules

- artifacts MUST be referenced by SHA-256 digest  
- evidence bundles MAY be external  
- external bundles MUST include SHA-256 digest  

---

### 6.3 Important constraint

> Evidence reuse applies ONLY to artifacts.

Collection evidence is unique per collection.

---

## 7. Commit Phase

The commit phase is the most critical step.

### 7.1 Purpose

- finalize the release
- enforce policy
- prevent inconsistencies

---

### 7.2 Required checks

The system MUST:

#### 1. Verify artifact integrity
- digest matches stored artifact

#### 2. Verify evidence bundles
- signature valid  
- timestamp present  
- transparency proof present (Sigsum or Rekor)  
- bundle digest correct
- signature MUST validate against the artifact using the associated certificate

#### 3. Enforce key uniqueness
- public key fingerprint MUST NOT exist previously

#### 4. Verify completeness
- all required artifacts present
- all required evidence present

---

### 7.3 Human control

Commit SHOULD:

- require explicit approval
- require MFA for production releases

---

### 7.4 Output

A committed release produces:

- immutable collection
- immutable artifact set
- immutable evidence bundles

---

## 8. Publication Phase

### 8.1 Actions

- publish artifacts  
- publish evidence bundles  
- publish collection  
- update discovery (if needed)  

---

### 8.2 Delivery formats

Artifact retrieval MAY return:

1. Artifact only  
2. Artifact + detached signature (multipart)  
3. Artifact + evidence bundle (multipart)  

> When an evidence bundle is provided, it includes the signature, timestamp(s), and transparency proof(s).

---

### 8.3 Example (multipart)

```text
multipart/mixed
  ├── artifact.bin
  └── evidence.json
```

---

## 9. Key Management Requirements

### 9.1 Key generation

- MUST generate new key pair per signing event  

### 9.2 Algorithm

- MUST use Ed25519  

### 9.3 Lifetime

- certificates MUST be < 1 hour  

### 9.4 Fingerprint tracking

Publisher systems MUST:

- store public key fingerprints  
- reject reuse  

---

## 10. CI/CD Integration

### 10.1 Allowed in CI/CD

- artifact generation  
- signing  
- timestamping  
- evidence bundle creation
- upload signing certificates associated with artefacts 

### 10.2 Not allowed in CI/CD

- final publication  
- trust anchor updates  

---

### 10.3 Token handling

CI/CD MAY use:

- OIDC-based short-lived tokens  
- ephemeral credentials  

Secrets MUST NOT be long-lived.

---

### 10.4 Publisher-side validation (CRITICAL)

When CI/CD uploads:

- artifact  
- signature  
- certificate  

the Publisher API MUST verify that:

- the certificate corresponds to the public key used for signature verification  
- the signature validates against the artifact  

Uploads that fail validation MUST be rejected.

---

## 11. Messaging Model

The Publisher API MUST support structured messaging.

### 11.1 Purpose

- workflow coordination  
- auditability  
- automation integration  

---

### 11.2 Event types

- `artifact.created`  
- `artifact.signed`  
- `evidence.created`  
- `collection.assembled`  
- `release.committed`  
- `release.published`  

---

### 11.3 Requirements

Messages MUST:

- be structured (JSON)  
- include timestamps  
- include identifiers  
- be immutable  

---

## 12. Logging Requirements

### 12.1 General

All critical operations MUST be logged.

---

### 12.2 Logged events

- key generation  
- signing operations  
- timestamp requests  
- transparency submissions  
- commit decisions  
- publication actions

---

### 12.3 Log properties

Logs MUST be:

- append-only  
- tamper-evident  
- time-stamped  

---

### 12.4 Retention

Logs SHOULD be retained for:

- ≥ 10 years (CRA alignment)

---

## 13. Validation Before Publication

Before publication, the system MUST verify:

- all artifacts are valid  
- all evidence bundles are valid  
- transparency proof exists (Sigsum or Rekor)  
- no key reuse occurred  
- all references resolve correctly
- signatures match artifacts when verified with the associated certificates

---

## 14. Error Conditions

Examples:

- `PUBLISHER_KEY_REUSE_DETECTED`  
- `PUBLISHER_EVIDENCE_INVALID`  
- `PUBLISHER_TIMESTAMP_MISSING`  
- `PUBLISHER_ARTIFACT_DIGEST_MISMATCH`  
- `PUBLISHER_COMMIT_INCOMPLETE`  

---

## 15. Security Considerations

### 15.1 Key compromise

Mitigated by:

- short-lived keys  
- no reuse  

---

### 15.2 CI/CD risks

Mitigated by:

- separation of commit phase  
- short-lived credentials  

---

### 15.3 Logging tampering

Mitigated by:

- append-only logs  
- integrity protection  

---

### 15.4 Incomplete releases

Mitigated by:

- strict commit validation  

---

### 15.5 Transparency guarantees

Transparency logs provide:

- append-only publication guarantees  
- detection of hidden or backdated releases  

This reduces the risk of:

- undetected artifact replacement  
- selective disclosure attacks  

## 16. Normative References

- RFC 2119 / RFC 8174  
- RFC 5280 — X.509  
- RFC 3161 — Time-Stamp Protocol  
- RFC 8785 — JSON Canonicalization  

---

## 17. Informative References

- TEA Trust Architecture  
- TEA Evidence Bundle Specification  
- TEA Evidence Validation Specification  
- EU Cyber Resilience Act (CRA)  

---

## Final Statement

The TEA Publisher Workflow ensures that:

> **Artifacts are cryptographically bound, time-stamped, and verifiable before they are published.**

This guarantees:

- reproducibility  
- auditability  
- long-term trust  

and enables TEA to function as a **secure-by-design publication system**.
