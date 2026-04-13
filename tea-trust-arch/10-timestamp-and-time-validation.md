# 📘 Timestamp Authority (TSA) Trust and Time Validation Profile

## Status

This document is normative.

It defines the requirements for timestamp generation, binding,
and validation in the TEA trust architecture.

All implementations performing timestamp validation MUST comply
with this specification.

---

## 1. Purpose

This document defines how Timestamp Authorities (TSAs) are used in the TEA architecture to:

- bind digital signatures to time  
- enable long-term validation  
- support the use of short-lived signing certificates and keys  

This specification is aligned with:

- RFC 3161 — Time-Stamp Protocol  
- RFC 5280 — PKIX Certificate and Validation Profile  

---

## 2. Core Design Principle

TEA intentionally uses:

- **short-lived signing certificates and keys**
- **long-lived timestamp evidence**

This combination allows TEA to:

- avoid revocation complexity  
- reduce key compromise impact  
- enable validation for long regulatory periods (e.g. CRA 10+ years)  

> A timestamp proves that a signature existed while the signing certificate was valid, even after the certificate has expired.

---

## 3. Role of Timestamp Authorities

A TSA provides cryptographic proof that:

> a specific digital signature existed at or before a given point in time

In TEA, timestamps are used to:

- bind signatures to time  
- prove that signing occurred during certificate validity  
- support validation long after certificate expiration  

A TSA does **not**:

- establish trust in the signer  
- validate the artifact content  

---

## 4. Security Model of Time

TEA does not assume absolute time.

Instead, it relies on:

- consistency across independent TSAs  
- bounded drift between time sources  
- verifiable ordering via transparency  

> Time is treated as a constrained, cross-validated signal.

---

## 5. Timestamp Token Requirements

A timestamp token MUST:

- be generated according to RFC 3161  
- be signed using an X.509 certificate  
- include a message imprint  
- include a time value (`genTime`)  
- include or reference the TSA certificate  

---

## 6. Timestamp Binding to Signatures (Normative)

### 6.1 What is Timestamped

A TEA implementation MUST timestamp the **digital signature**, not the raw artifact.

```text
artifact → signature → timestamp(signature)
```

---

### 6.2 Message Imprint

The timestamp MUST include:

```text
messageImprint = hash(signature)
```

As defined in RFC 3161.

---

### 6.3 Verification Binding

A TEA consumer MUST verify:

```text
TSTInfo.messageImprint == hash(signature)
```

---

### 6.4 Security Rationale

Timestamping the signature ensures:

- the signature cannot be replaced  
- the artifact-signature relationship is fixed in time  
- the evidence survives beyond certificate lifetime  

---

## 7. Certificate-Time Binding (Critical)

The timestamp MUST be within the signing certificate validity:

```text
timestamp ∈ [certificate.notBefore, certificate.notAfter]
```

This establishes:

> The signature existed at a time when the certificate was valid.

---

## 8. Relationship to Short-Lived Certificates

### 8.1 Short-Lived Certificate Model

TEA uses certificates with very short validity:

- hours to ≤24 hours  
- often single-use  

This reduces:

- exposure of private keys  
- need for revocation  

---

### 8.2 Timestamp as Proof of Valid Use

Because certificates expire quickly:

- they cannot be relied on for long-term validation  

Instead:

> The timestamp becomes the durable proof that the certificate was valid at signing time.

---

### 8.3 Long-Term Validation Logic

A TEA consumer validates:

1. signature is cryptographically correct  
2. timestamp is valid (RFC 3161)  
3. timestamp binds to signature  
4. timestamp falls within certificate validity  

If all conditions hold:

> The signature MUST be considered valid, even if the certificate has expired.

---

### 8.4 No Revocation Requirement

Because of the above:

- revocation checking (CRL/OCSP) MUST NOT be required  

This is a deliberate design choice.

---

## 9. Timestamp Storage Model

Timestamps SHOULD be stored as detached objects.

Example:

```json
{
  "signature": {
    "algorithm": "EdDSA",
    "value": "BASE64URL..."
  },
  "timestamps": [
    {
      "format": "rfc3161",
      "token": "BASE64..."
    }
  ]
}
```

---

## 10. Multiple Timestamps (Recommended)

Multiple TSAs SHOULD be used:

```json
{
  "timestamps": [
    { "tsa": "tsa-eu-1", "token": "..." },
    { "tsa": "tsa-us-1", "token": "..." }
  ]
}
```

Purpose:

- reduce single-point trust  
- detect manipulation  

---

## 11. Timestamp Validation

A TEA consumer MUST:

1. verify TSA signature (RFC 3161)  
2. validate TSA certificate chain (RFC 5280)  
3. verify message imprint binding  
4. verify certificate-time binding  

---

## 12. Time Consistency Validation

Given multiple timestamps:

```text
drift = max(timestamps) - min(timestamps)
```

If drift exceeds threshold:

- validation MUST fail  

---

## 13. Time Health Validation

Implementations SHOULD periodically:

1. query TSAs  
2. compute drift  

---

## 14. Signing-Time Validation

Before accepting a timestamp:

```text
|t_timestamp - t_expected| ≤ allowed_drift
```

Otherwise:

- revalidate time  
- block signing  

---

## 15. TSA Trust Anchors

TSA trust anchors:

- MUST be explicitly configured  
- MUST follow RFC 5280 validation  
- MUST be independent of publisher trust  

---

## 16. Transparency Integration

Timestamped signatures SHOULD be included in transparency systems.

This provides:

- ordering guarantees  
- detection of backdating  

---

## 17. Failure Handling

### TSA failure
- fallback required  

### drift violation
- validation MUST fail  

### signing-time failure
- signing MUST stop  

---

## 18. Logging Requirements

Implementations MUST log:

- TSA used  
- timestamp value  
- drift  
- validation result  

---

## 19. Dependency Constraints

Implementation MUST:

- support offline validation  
- not depend on live TSA access  
- rely on stored timestamp evidence  

---

## 20. Summary

The TEA timestamp model:

- timestamps the **signature**  
- proves certificate validity at signing time  
- supports **short-lived certificates**  
- eliminates revocation dependency  
- enables long-term validation  

> Short-lived certificates provide security at signing time.  
> Timestamps provide trust over time.
