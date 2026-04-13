# 📘 TEA Evidence Validation Specification
**Version:** 1.0  
**Status:** Draft (Normative, RFC-style)

---

## Status

This document defines how a TEA consumer validates:

- **evidence bundles**
- **TEA artifacts**
- **TEA collections**
- **discovery documents**
- **lifecycle (CLE) documents**

It specifies:

- validation steps  
- required checks  
- failure conditions  
- policy considerations  

This specification applies to:

- **TEA Trust Architecture (REQUIRED)**
- **base TEA (PARTIAL / OPTIONAL)**

The key words **MUST**, **SHOULD**, and **MAY** are to be interpreted as described in:

- RFC 2119  
- RFC 8174  

---

## Table of Contents

1. [Introduction](#1-introduction)  
2. [Validation Philosophy](#2-validation-philosophy)  
3. [Validation Scope](#3-validation-scope)  
4. [Inputs to Validation](#4-inputs-to-validation)  
5. [Evidence Bundle Validation](#5-evidence-bundle-validation)  
6. [Artifact Validation](#6-artifact-validation)  
7. [Collection Validation](#7-collection-validation)  
8. [Discovery Validation](#8-discovery-validation)  
9. [Lifecycle (CLE) Validation](#9-lifecycle-cle-validation)  
10. [Timestamp Validation](#10-timestamp-validation)  
11. [Transparency Validation](#11-transparency-validation)  
12. [DNS and Trust Anchor Validation](#12-dns-and-trust-anchor-validation)  
13. [Policy Controls](#13-policy-controls)  
14. [Validation Outcomes](#14-validation-outcomes)  
15. [Error Conditions](#15-error-conditions)  
16. [Security Considerations](#16-security-considerations)  
17. [Normative References](#17-normative-references)  
18. [Informative References](#18-informative-references)  

---

## 1. Introduction

Validation in TEA answers the question:

> **Can this object be trusted, and under what conditions?**

The TEA Trust Architecture defines a **multi-layer validation model**:

- evidence validation  
- artifact validation  
- collection validation  
- discovery validation  
- lifecycle validation  

Each layer has a distinct role and MUST NOT be conflated.

---

## 2. Validation Philosophy

### 2.1 Evidence-first model

> The evidence bundle is the unit of trust.

Validation MUST start with:

- the evidence bundle  
- not the collection  
- not the transport  
- not the API  

---

### 2.2 Separation of concerns

| Object | What it proves |
|--------|---------------|
| Evidence bundle | Authenticity, time, transparency |
| Artifact | Exact content |
| Collection | Release membership |
| Discovery | Service location |
| Lifecycle (CLE) | Time-dependent lifecycle commitments |

---

### 2.3 No revocation dependency

Validation MUST NOT depend on:

- OCSP  
- CRLs  

Trust is derived from:

- timestamps  
- evidence integrity  

---

## 3. Validation Scope

Validation MAY apply to:

- TEA artifacts  
- TEA collections  
- discovery documents  
- lifecycle (CLE) documents  

Each requires different validation steps.

---

## 4. Inputs to Validation

A validation process typically requires:

- target object (artifact, collection, discovery, or lifecycle document)
- evidence bundle
- trust anchors (DNS or configured)
- validation policy
- optional transparency log access

---

## 5. Evidence Bundle Validation

Evidence validation MUST be performed before any higher-level validation.

### 5.1 Step-by-step process

#### Step 1 — Structure validation
- bundle MUST contain required fields:
  - signature  
  - certificate  
  - timestamps  
  - transparency  

---

#### Step 2 — Certificate validation
- MUST conform to TEA X.509 profile  
- MUST contain valid public key  
- MUST respect validity period  

---

#### Step 3 — Signature validation
- MUST verify using certificate public key  
- MUST cover exact target bytes  
- MUST be consistent with the target object (artifact, collection, discovery document, or lifecycle document)  

---

#### Step 4 — Timestamp validation
- MUST exist  
- MUST be cryptographically valid  
- MUST bind to the signature  

---

#### Step 5 — Transparency validation
- MUST verify at least one valid log entry from:
  - Sigsum, or  
  - Rekor  

- validation MUST include:
  - inclusion proof verification  
  - log integrity checks  

---

#### Step 6 — Canonicalization (if JSON)
- MUST use RFC 8785 for hash validation  

---

### 5.2 Result

Evidence validation produces:

- VALID  
- INVALID  

---

## 6. Artifact Validation

Artifact validation combines:

- artifact integrity  
- evidence validation  

### 6.1 Steps

1. Compute SHA-256 digest of artifact  
2. Compare with expected digest (from collection or reference)  
3. Validate evidence bundle  

---

### 6.2 Result

An artifact is valid if:

- digest matches  
- evidence bundle is valid  

---

## 7. Collection Validation

### 7.1 Purpose

Collection validation proves:

- correct binding between artifacts and release  

---

### 7.2 Steps

1. Validate collection structure  
2. Validate artifact references  
3. Verify artifact digests  
4. Validate collection evidence (if present)  

---

### 7.3 Important rule

> Collection validation does NOT prove artifact authenticity.

Artifact evidence MUST be validated separately.

---

## 8. Discovery Validation

### 8.1 Base TEA

- validate TLS connection  
- parse discovery document  

---

### 8.2 Trust Architecture

1. Validate TLS  
2. Validate discovery signature  
3. Validate timestamp  
4. Validate evidence bundle (if present)  

---

### 8.3 Result

Discovery validation provides:

- trusted API endpoint mapping  

---

## 9. Lifecycle (CLE) Validation

### 9.1 Purpose

Lifecycle validation verifies:

> that lifecycle statements are authentic, time-bound, and version-consistent

---

### 9.2 Steps

1. Validate lifecycle document structure  
2. Validate lifecycle version metadata:
   - version identifier  
   - previous version linkage (if present)  
3. Validate evidence bundle (embedded)  
4. Verify signature binds to full lifecycle document  
5. Validate timestamps  
6. Validate transparency evidence  

---

### 9.3 Important rules

- Lifecycle validation MUST be performed per version  
- Each lifecycle version MUST be validated independently  
- Lifecycle documents MUST NOT rely on external evidence bundles  
- Lifecycle evidence MUST be embedded  

---

### 9.4 Result

A lifecycle document is valid if:

- structure is valid  
- evidence bundle is valid  
- version metadata is internally consistent  

---

## 10. Timestamp Validation

### 10.1 Requirements

- MUST be cryptographically valid  
- MUST bind to signature  

---

### 10.2 Checks

- TSA signature verification  
- timestamp format validity  
- consistency across multiple TSAs (if present)  

---

### 10.3 Policy

Consumers SHOULD:

- accept small time differences  
- detect major inconsistencies  

---

## 11. Transparency Validation

### 11.1 Requirement

Transparency validation is:

> **REQUIRED in TEA Trust Architecture**

---

### 11.2 Supported systems

Consumers MUST support validation of:

- Sigsum  
- Rekor  

SCITT MAY be supported in addition.

---

### 11.3 Checks

- inclusion proof verification  
- log integrity  
- consistency proof (if applicable)  

---

### 11.4 Sigsum-specific note

Consumers SHOULD verify:

- witness signatures  
- quorum requirements  

---

## 12. DNS and Trust Anchor Validation

### 12.1 Trust anchor retrieval

Trust anchors MAY be obtained via:

- DNS CERT records  
- DNSSEC (optional)  

---

### 12.2 Checks

- certificate matches DNS anchor  
- DNSSEC validation (if available)  

---

### 12.3 WebPKI mode

Consumers MAY additionally verify:

- CAA records  

When WebPKI is used:

> evidence bundles MUST NOT be required or expected.

---

## 13. Policy Controls

Validation behavior is influenced by policy.

### 13.1 Policy examples

- require multiple TSAs  
- restrict acceptable trust anchors  
- enforce time bounds  

---

### 13.2 Key reuse detection

Consumers SHOULD detect:

- reuse of public key fingerprints across evidence bundles  

---

## 14. Validation Outcomes

Validation results MUST be one of:

- **VALID**  
- **INVALID**  
- **INDETERMINATE** (policy-dependent cases)  

---

## 15. Error Conditions

Validation MUST fail when:

- signature invalid  
- certificate invalid  
- timestamp missing  
- transparency evidence missing or invalid  
- digest mismatch  
- canonicalization failure  

Example identifiers:

- `VALIDATION_SIGNATURE_INVALID`  
- `VALIDATION_CERT_INVALID`  
- `VALIDATION_TIMESTAMP_INVALID`  
- `VALIDATION_TRANSPARENCY_INVALID`  
- `VALIDATION_DIGEST_MISMATCH`  
- `VALIDATION_CANONICALIZATION_ERROR`  

---

## 16. Security Considerations

### 16.1 Key reuse

Mitigated by:

- publisher enforcement  
- consumer detection  

---

### 16.2 Evidence substitution

Mitigated by:

- SHA-256 digest binding  

---

### 16.3 Time manipulation

Mitigated by:

- trusted TSAs  
- multiple timestamps  

---

## 17. Normative References

- RFC 2119 / RFC 8174  
- RFC 5280 — X.509  
- RFC 3161 — Time-Stamp Protocol  
- RFC 8785 — JSON Canonicalization Scheme  

---

## 18. Informative References

- Rekor Transparency Log  
  https://github.com/sigstore/rekor  

- Sigsum Transparency Log  
  https://www.sigsum.org/  

- IETF SCITT Architecture  
  https://datatracker.ietf.org/wg/scitt/documents/  

- TEA Trust Architecture Specification  
  https://github.com/CycloneDX/transparency-exchange-api  

---

## Final Statement

Validation in TEA ensures that:

> **evidence is internally consistent, cryptographically valid, and bound to the correct object**

Only after evidence validation succeeds can higher-level trust decisions be made.
