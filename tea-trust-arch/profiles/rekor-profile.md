# 📘 TEA Trust Architecture Rekor Profile

---

## Status

This document is a TEA implementation profile.

It defines how Rekor may be used as a transparency backend within
the TEA trust architecture.

Normative TEA trust requirements remain defined in the TEA Core
Trust Architecture and related specifications.

## 1. Purpose

This profile defines how TEA uses Rekor as a transparency backend.

It is an implementation profile for the TEA transparency layer, not a replacement for the TEA trust architecture.

Rekor provides:

- transparency evidence  
- inclusion proofs  
- append-only log guarantees  

TEA still relies on its own trust model for:

- certificate validation  
- timestamp validation  
- DNS publication (TEA-native)  
- release semantics  
- publication authorization  

This profile preserves a strict separation:

- TEA = source of truth for artifacts and collections  
- Rekor = transparency witness for trust-relevant objects  

---

## 2. Scope

This profile applies to:

- short-lived TEA signing certificates  
- TEA collection objects  
- SBOM artifacts  
- attestations (provenance, VEX-like claims)  
- optionally signed discovery documents  

Rekor is NOT:

- the TEA artifact repository  
- the primary discovery mechanism  
- the trust anchor  

---

## 3. Core Rule: What Is Stored in Rekor

### 3.1 hashedrekord

Used for:

- certificates  
- signed collections  
- signed artifact blobs  
- discovery objects (optional)

Rekor stores:

- object hash  
- signature  
- verification material  

Rekor does NOT store authoritative TEA objects.

---

### 3.2 dsse

Used for:

- in-toto attestations  
- provenance  
- VEX-like claims  

Rekor stores:

- DSSE envelope  

---

### 3.3 TEA Rule Summary

| TEA Object | Rekor Storage |
|----------|--------------|
| Signing certificate | hash-oriented entry |
| Signed collection | hash-oriented entry |
| Signed artifact | hash-oriented entry |
| DSSE attestation | DSSE envelope |
| Discovery document | optional hash entry |

---

## 3.4 Cryptographic Binding Model (Normative)

TEA requires consistent binding between:

- signature  
- timestamp  
- transparency log entry  

The correct order:

```text
artifact → signature → timestamp(signature) → transparency log
```

Rekor MUST log:

- the digital signature  
- OR the timestamped signature object  

NOT:

- raw artifact hash alone  

Validation MUST ensure:

```text
TSTInfo.messageImprint == hash(signature)
```

AND

```text
Rekor_entry.object_hash == hash(signature OR timestamped_signature)
```

If these conditions fail:

- validation MUST fail  

---

## 4. Rekor Logging Requirements by Object Type

---

### 4.1 Short-Lived Signing Certificates

MUST be logged (recommended minimum).

Why:

- certificates are ephemeral  
- keys are short-lived  
- transparency preserves identity evidence  

Rule:

- log certificate hash  
- preserve full certificate in TEA  

---

### 4.2 TEA Collection

SHOULD be logged.

Reason:

- defines release  
- signed object  

Rekor:

- stores hash entry  
TEA:

- stores full object  

---

### 4.3 SBOM Artifacts

SHOULD be logged when independent authenticity is required.

---

### 4.4 Attestations (DSSE)

MUST use DSSE storage.

---

### 4.5 Discovery Document

MAY be logged.

Rekor MUST NOT replace:

- DNS-based discovery  
- TEA trust model  

---

### 4.6 Alignment with Timestamp Evidence

Rekor and TSA serve complementary roles:

| Layer | Role |
|------|------|
| Timestamp | proves *when* |
| Rekor | proves *publication* |

A TEA implementation SHOULD:

- log the same signature that is timestamped  
- or the timestamped signature object  

---

## 5. Transparency Coverage

### Minimum
- certificate  
- collection  

### Recommended
- SBOM  
- attestations  
- discovery  

### High Assurance
- all of the above  

---

## 6. What TEA Must Preserve

TEA MUST retain:

- certificates  
- collections  
- artifacts  
- signatures  
- timestamps  
- Rekor receipts  

AND:

- binding between all of them  

---

## 7. Validation Expectations

A TEA consumer MUST verify:

1. signature validity  
2. timestamp validity  
3. timestamp binding  
4. Rekor inclusion proof  
5. Rekor object binding  

---

## 8. Relationship to TEA Trust Anchors

TEA-native trust:

- certificate (identity)  
- timestamp (time)  
- DNS (distribution)  
- Rekor (transparency)  

Rekor provides:

👉 auditability  

---

## 9. Rekor Submission Model

### 9.1 Public Rekor

- no authentication required  
- open submission  

Implication:

> Anyone can submit entries  

---

### 9.2 Identity Model

Identity is derived from:

- signature  
- certificate  

NOT:

- account  

---

### 9.3 TEA Requirement

TEA MUST NOT trust Rekor entries based on presence alone.

Validation MUST rely on:

- signature  
- certificate  
- timestamp  
- binding rules  

---

### 9.4 Private Rekor

Deployments MAY:

- require authentication  
- restrict submission  

This does NOT change TEA validation rules.

---

## 10. Trusting Rekor as a Service

### 10.1 Principle

Rekor is:

👉 a verifiable transparency witness  

NOT:

👉 a root of trust  

---

### 10.2 Guarantees

Rekor provides:

- inclusion proofs  
- signed tree heads  
- append-only structure  

Rekor does NOT provide:

- identity trust  
- correctness  
- completeness  

---

### 10.3 Trust Anchors

Consumers MUST define:

- Rekor log public key  
- accepted service endpoints  

---

### 10.4 Multi-Log Model (Recommended)

Use ≥2 independent logs.

Benefits:

- reduces operator risk  
- aligns with TEA architecture  

---

### 10.5 Consistency Checks

Consumers SHOULD verify:

- log consistency  
- absence of forked views  

---

## 11. Failure Handling

| Condition | Result |
|----------|-------|
| invalid log signature | FAIL |
| invalid inclusion proof | FAIL |
| log unavailable | policy dependent |

---

## 12. Privacy Considerations

Logging may expose:

- hashes  
- metadata  

Implementations SHOULD:

- avoid sensitive payloads  
- prefer hash entries  

---

## 13. Final Rule

Rekor stores transparency evidence, not TEA objects.

However:

👉 Rekor entries MUST be cryptographically bound to TEA validation objects.

---

## 🎯 Final Statement

Rekor is trusted because:

- its outputs are verifiable  
- its behavior is auditable  

Not because:

- it enforces access control  
- it acts as a trust anchor  

---

## 🔥 Architectural Insight

TEA achieves trust through:

- no single trust anchor  
- no long-lived secrets  
- multiple independent verification layers  

Rekor is one of those layers — not the foundation.
