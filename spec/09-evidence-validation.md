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
9. [Timestamp Validation](#9-timestamp-validation)  
10. [Transparency Validation](#10-transparency-validation)  
11. [DNS and Trust Anchor Validation](#11-dns-and-trust-anchor-validation)  
12. [Policy Controls](#12-policy-controls)  
13. [Validation Outcomes](#13-validation-outcomes)  
14. [Error Conditions](#14-error-conditions)  
15. [Security Considerations](#15-security-considerations)  
16. [Normative References](#16-normative-references)  
17. [Informative References](#17-informative-references)  

---

## 1. Introduction

Validation in TEA answers the question:

> **Can this object be trusted, and under what conditions?**

The TEA Trust Architecture defines a **multi-layer validation model**:

- evidence validation  
- artifact validation  
- collection validation  
- discovery validation  

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
| Evidence bundle | Authenticity, time, optional transparency |
| Artifact | Exact content |
| Collection | Release membership |
| Discovery | Service location |

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

Each requires different validation steps.

---

## 4. Inputs to Validation

A validation process typically requires:

- target object (artifact, collection, or discovery)
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

---

#### Step 2 — Certificate validation
- MUST conform to TEA X.509 profile  
- MUST contain valid public key  
- MUST respect validity period  

---

#### Step 3 — Signature validation
- MUST verify using certificate public key  
- MUST cover exact target bytes  

---

#### Step 4 — Timestamp validation
- MUST exist  
- MUST be cryptographically valid  
- MUST bind to the signature  

---

#### Step 5 — Optional transparency validation
- if present, MUST verify:
  - inclusion proof  
  - log consistency  

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

## 9. Timestamp Validation

### 9.1 Requirements

- MUST be cryptographically valid  
- MUST bind to signature  

---

### 9.2 Checks

- TSA signature verification  
- timestamp format validity  
- consistency across multiple TSAs (if present)  

---

### 9.3 Policy

Consumers SHOULD:

- accept small time differences  
- detect major inconsistencies  

---

## 10. Transparency Validation

### 10.1 Optional

Transparency validation is:

- OPTIONAL  
- policy-driven  

---

### 10.2 Checks

- inclusion proof verification  
- log integrity  
- consistency proof (if applicable)  

---

### 10.3 Sigsum-specific note

Consumers SHOULD verify:

- witness signatures  
- quorum requirements  

---

## 11. DNS and Trust Anchor Validation

### 11.1 Trust anchor retrieval

Trust anchors MAY be obtained via:

- DNS CERT records  
- DNSSEC (optional)  

---

### 11.2 Checks

- certificate matches DNS anchor  
- DNSSEC validation (if available)  

---

### 11.3 WebPKI mode

Consumers MAY additionally verify:

- CAA records  

---

## 12. Policy Controls

Validation behavior is influenced by policy.

### 12.1 Policy examples

- require transparency logs  
- require multiple TSAs  
- restrict acceptable trust anchors  
- enforce time bounds  

---

### 12.2 Key reuse detection

Consumers SHOULD detect:

- reuse of public key fingerprints across evidence bundles  

---

## 13. Validation Outcomes

Validation results MUST be one of:

- **VALID**  
- **INVALID**  
- **INDETERMINATE** (policy-dependent cases)  

---

## 14. Error Conditions

Validation MUST fail when:

- signature invalid  
- certificate invalid  
- timestamp missing  
- digest mismatch  
- canonicalization failure  

Example identifiers:

- `VALIDATION_SIGNATURE_INVALID`  
- `VALIDATION_CERT_INVALID`  
- `VALIDATION_TIMESTAMP_INVALID`  
- `VALIDATION_DIGEST_MISMATCH`  
- `VALIDATION_CANONICALIZATION_ERROR`  

---

## 15. Security Considerations

### 15.1 Key reuse

Mitigated by:

- publisher enforcement  
- consumer detection  

---

### 15.2 Evidence substitution

Mitigated by:

- SHA-256 digest binding  

---

### 15.3 Time manipulation

Mitigated by:

- trusted TSAs  
- multiple timestamps  
