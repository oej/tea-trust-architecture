# 📘 TEA Evidence Validation Specification
**Version:** 1.0  
**Status:** Draft (Normative, Implementation-Ready)

---

# Table of Contents

1. [Introduction](#1-introduction)  
2. [Purpose](#2-purpose)  
3. [Scope](#3-scope)  
4. [Core Principle](#4-core-principle)  
5. [Validation Model](#5-validation-model)  
6. [Validation Steps](#6-validation-steps)  
7. [Binding Requirements](#7-binding-requirements)  
8. [Certificate Validation](#8-certificate-validation)  
9. [Timestamp Validation](#9-timestamp-validation)  
10. [Transparency Validation](#10-transparency-validation)  
11. [Digest and Canonicalization](#11-digest-and-canonicalization)  
12. [Policy Application](#12-policy-application)  
13. [Error Handling](#13-error-handling)  
14. [Offline Validation](#14-offline-validation)  
15. [Relationship to TEA Collections](#15-relationship-to-tea-collections)  
16. [Security Considerations](#16-security-considerations)  
17. [Final Statement](#final-statement)  

---

# 1. Introduction

This document defines how TEA evidence bundles are validated.

It specifies:

- validation steps  
- binding requirements  
- failure conditions  
- policy interaction  

---

# 2. Purpose

The TEA validation model ensures:

- artifact authenticity  
- integrity  
- verifiable signing time  
- public visibility  

independent of:

- certificate lifetime  
- key persistence  
- service availability  

---

# 3. Scope

This specification applies to:

- validation of TEA evidence bundles  
- validation of TEA artifacts using evidence bundles  

It does not define:

- trust policy decisions  
- trust anchor selection  

---

# 4. Core Principle

Validation in TEA MUST be performed using an **evidence bundle**.

> Signatures MUST NOT be treated as standalone trust objects.

All validation operations MUST be based on:

- the evidence bundle  
- the artifact referenced by the bundle  

---

# 5. Validation Model

The validation model is:

```text
artifact ↔ evidence bundle
              ├─ signature
              ├─ certificate
              ├─ timestamp(s)
              └─ transparency evidence
```

All components MUST refer to the same cryptographic object.

---

# 6. Validation Steps

A verifier MUST perform the following steps:

---

## 6.1 Verify Artifact Digest

- Compute SHA-256 over the artifact  
- Compare with bundle `object.digest`  

---

## 6.2 Verify Signature

- Verify the signature over the artifact  
- Use the public key from the certificate  

---

## 6.3 Validate Certificate

- Validate certificate structure  
- Verify signature chain if present  
- Confirm certificate matches the signing key  

---

## 6.4 Validate Timestamp

- Verify timestamp token validity  
- Verify timestamp signature  
- Verify timestamp trust anchor  

---

## 6.5 Verify Timestamp Binding

```
messageImprint == SHA-256(signature)
```

---

## 6.6 Validate Transparency Evidence

- Verify inclusion proof  
- Verify log signatures  
- Verify consistency proofs (if applicable)  

---

## 6.7 Verify Transparency Binding

Transparency MUST bind to:

- signature  
OR  
- timestamped signature  

---

## 6.8 Apply Policy

Apply local policy decisions:

- trust anchors  
- required evidence types  
- acceptance criteria  

---

## 6.9 Final Decision

Validation succeeds only if all required checks pass.

---

# 7. Binding Requirements

All evidence MUST refer to the same cryptographic object.

---

## 7.1 Artifact Binding

- Signature MUST verify the artifact  

---

## 7.2 Timestamp Binding

- Timestamp MUST bind to signature  

---

## 7.3 Transparency Binding

- Transparency MUST bind to signature or timestamp  

---

## 7.4 Consistency Rule

> Any mismatch between layers MUST result in validation failure.

---

# 8. Certificate Validation

Certificate validation MUST ensure:

- correct signature algorithm  
- valid structure  
- consistency with signing key  

---

## 8.1 Time Consistency

The timestamp MUST satisfy:

```
timestamp ∈ [certificate.notBefore, certificate.notAfter]
```

---

## 8.2 Trust Anchors

Trust anchors may be:

- DNS (TAPS model)  
- WebPKI  
- other policy-defined anchors  

---

# 9. Timestamp Validation

Timestamp validation MUST ensure:

- valid signature  
- trusted TSA  
- correct message imprint  

---

## 9.1 Role of Timestamp

The timestamp provides:

- proof of signing time  
- independence from certificate lifetime  

---

## 9.2 Multiple Timestamps

If multiple timestamps are present:

- verifier SHOULD check consistency  
- policy MAY require agreement  

---

# 10. Transparency Validation

Transparency validation MUST ensure:

- inclusion in log  
- correct binding  
- valid log signatures  

---

## 10.1 Supported Systems

Examples:

- Rekor  
- Sigsum  
- SCITT  

---

## 10.2 Purpose

Transparency provides:

- auditability  
- tamper detection  
- public visibility  

---

# 11. Digest and Canonicalization

## 11.1 Digest Algorithm

TEA defines a single digest algorithm:

- `sha-256`

---

## 11.2 Requirements

- All digests MUST use SHA-256  
- No other algorithms are permitted  

---

## 11.3 Canonicalization

JSON objects MUST be canonicalized using:

> RFC 8785 — JSON Canonicalization Scheme (JCS)

---

## 11.4 Digest Computation

```
digest = SHA-256(JCS(object))
```

---

## 11.5 Encoding

Digest values MUST use base64url encoding.

---

# 12. Policy Application

This specification separates:

- **validation (objective)**  
- **trust decision (policy)**  

---

## 12.1 Examples of Policy Decisions

- acceptable trust anchors  
- required transparency systems  
- timestamp requirements  
- certificate constraints  

---

# 13. Error Handling

Validation MUST fail if:

- artifact digest mismatch  
- signature invalid  
- certificate invalid  
- timestamp invalid  
- transparency invalid  
- binding inconsistency  

---

## 13.1 Fail-Closed Requirement

> Implementations MUST fail closed.

---

# 14. Offline Validation

Evidence bundles SHOULD enable offline validation.

This requires:

- embedded certificate  
- embedded timestamps  
- embedded transparency evidence  

---

# 15. Relationship to TEA Collections

Evidence validation and collection validation are separate concerns.

---

## 15.1 Evidence Bundle

Answers:

> “Is this artifact authentic and verifiable?”

---

## 15.2 Collection

Answers:

> “Does this artifact belong to this release?”

---

## 15.3 Rule

Artifact validation MUST NOT depend on a collection.

---

# 16. Security Considerations

---

## 16.1 Short-Lived Certificates

Certificates are intentionally short-lived.

Long-term validation relies on:

- timestamps  
- preserved evidence  

---

## 16.2 No Implicit Trust

Evidence bundles do not establish trust automatically.

Policy decisions are required.

---

## 16.3 Binding Integrity

All trust depends on correct binding between:

- artifact  
- signature  
- timestamp  
- transparency  

---

## 16.4 Attack Surface

Primary risks:

- substitution attacks  
- replay attacks  
- binding mismatches  

All are mitigated by strict validation rules.

---

# Final Statement

TEA validation is based on:

> consistent, verifiable evidence across independent trust signals  

---

## Key Principle

> Validation succeeds only when all evidence layers agree on the same cryptographic object.
