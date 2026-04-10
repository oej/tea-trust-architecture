# 📘 TEA Evidence Validation Specification
**Version:** 1.0  
**Status:** Draft (Implementation-Ready)

---

# 1. Introduction

This document defines how a TEA Evidence Bundle MUST be validated.

It specifies:

- the validation sequence  
- binding verification rules  
- trust evaluation points  
- failure handling  

This document is **normative** for any TEA consumer implementing:

> **TEA with the Trust Architecture**

---

## 1.1 Relationship to Other Specifications

This document depends on:

- TEA Evidence Bundle Specification  
- TEA Trust Architecture Core Specification  
- TEA Validation Policy  

---

## 1.2 Validation vs Trust

This specification distinguishes between:

### Evidence Verification
Cryptographic validation of:

- signatures  
- timestamps  
- transparency evidence  

### Trust Evaluation
Policy decisions about:

- trusted certificate authorities  
- trusted TSAs  
- trusted transparency logs  

> A bundle can be **valid but not trusted**.

---

# 2. Validation Model Overview

Validation proceeds through a strict chain:

```text
TEA object → signature → certificate → timestamp → transparency
```

Each step MUST:

- succeed independently  
- bind to the same cryptographic object  

---

## 2.1 Core Principle

> Partial validation is equivalent to validation failure.

---

## 2.2 Validation Modes

Validation MAY operate in:

- **online mode** (external checks allowed)  
- **offline mode** (bundle-only validation)  

Implementations MUST support offline validation.

---

# 3. Inputs

A validator requires:

- TEA object (external or embedded)  
- TEA Evidence Bundle  
- validation policy (L1/L2/L3 or equivalent)  

---

# 4. Validation Steps (Normative)

## Step 1 — Object Integrity

The validator MUST:

1. compute digest of TEA object  
2. compare with `bundle.object.digest`  

Failure → MUST reject  

---

## Step 2 — Signature Verification

The validator MUST:

1. extract signature  
2. verify signature against object  
3. use public key from certificate  

Failure → MUST reject  

---

## Step 3 — Certificate Validation

### 3.1 General

The validator MUST:

- parse certificate  
- verify it matches TEA certificate profile  

---

### 3.2 TEA-Native

Validator MUST:

- compute SHA-256(public key)  
- verify SAN format:

```text
<fingerprint>.<trust-domain>
```

- confirm fingerprint match  

Failure → MUST reject  

---

### 3.3 WebPKI

Validator MUST:

- validate PKIX chain  
- verify chain to trusted root  

---

### 3.4 Certificate Validity

Validator MUST verify:

- certificate was valid at timestamp  

---

## Step 4 — Timestamp Validation

### 4.1 Presence

For TEA with the trust architecture:

- timestamp MUST be present  

---

### 4.2 Cryptographic Validation

Validator MUST:

- verify TSA signature  
- validate TSA certificate chain  

---

### 4.3 Binding Verification

Validator MUST verify:

```text
timestamp.messageImprint == hash(signature)
```

Failure → MUST reject  

---

### 4.4 Time Consistency

Validator MUST verify:

```text
timestamp.time ∈ certificate validity window
```

---

### 4.5 Trust Evaluation

Validator MUST:

- trust TSA according to policy  

---

## Step 5 — Transparency Validation

### 5.1 Presence

- REQUIRED in high-assurance profiles  
- OPTIONAL otherwise  

---

### 5.2 Cryptographic Validation

Validator MUST verify:

- inclusion proof  
- log signature or receipt  

---

### 5.3 Binding Verification

Validator MUST verify:

- transparency binds to signature or timestamped signature  

---

### 5.4 Log Trust

Validator MUST:

- validate log public key  
- apply trust policy  

---

## Step 6 — Evidence Consistency

Validator MUST ensure:

- all evidence refers to the same signature  
- no conflicting digests exist  

Failure → MUST reject  

---

## Step 7 — Policy Evaluation

After cryptographic validation:

Validator MUST apply policy:

- validation level (L1/L2/L3)  
- trust anchors  
- allowed algorithms  

---

# 5. Offline Validation Requirements

A validator MUST be able to validate using only:

- bundle contents  
- local trust store  

---

## 5.1 Required Bundle Content

Bundles SHOULD include:

- certificate  
- timestamp token  
- transparency evidence  
- verification material  

---

# 6. Trust Model Handling

## 6.1 TEA-Native

Validator MUST:

- validate fingerprint-derived SAN  
- treat DNS as publication mechanism  
- optionally validate DNSSEC  

---

## 6.2 WebPKI

Validator MUST:

- validate PKIX chain  
- ignore DNS CERT as trust anchor  

Validator SHOULD:

- validate CAA  

---

# 7. Failure Handling

## 7.1 Hard Failures (MUST Reject)

- invalid signature  
- missing signature  
- certificate mismatch  
- timestamp invalid  
- binding mismatch  

---

## 7.2 Conditional Failures

Handled according to policy:

| Condition | L1 | L2 | L3 |
|----------|----|----|----|
| Missing timestamp | OK | warn | fail |
| Missing transparency | OK | warn | fail |
| DNSSEC failure | OK | warn | fail |
| CAA violation | OK | SHOULD fail | MUST fail |

---

## 7.3 Logging Requirements

Validators SHOULD log:

- validation result  
- failed steps  
- timestamp status  
- transparency status  
- trust decisions  

---

# 8. Security Considerations

## 8.1 Timestamp as Core Anchor

Timestamp enables:

- validation after certificate expiry  
- protection against backdating  

---

## 8.2 Transparency Limitations

Transparency:

- does NOT prevent attacks  
- enables detection  

---

## 8.3 Critical Risk

> Valid signature + invalid authorization

Validation MUST NOT imply authorization.

---

## 8.4 Replay Protection

Timestamp + transparency mitigate:

- replay of stale signatures  

---

# 9. Implementation Guidance

## 9.1 Recommended Order

Implementations SHOULD follow strict step order.

---

## 9.2 Caching

Validators MAY cache:

- certificates  
- timestamps  
- transparency proofs  

But MUST NOT skip validation.

---

## 9.3 Parallel Validation

Timestamp and transparency MAY be validated in parallel.

---

# 10. Key Principles

1. Evidence must be cryptographically verifiable  
2. Evidence must be consistently bound  
3. Trust is policy-driven  
4. Partial validation is failure  

---

# 11. Final Statement

The TEA Evidence Validation model ensures that:

- signatures remain verifiable after certificate expiry  
- validation can be performed offline  
- trust is derived from evidence, not infrastructure  

It operationalizes the TEA trust architecture by transforming:

> stored evidence  
into  
> verifiable trust decisions
