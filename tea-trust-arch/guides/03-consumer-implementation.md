# 📘 TEA Consumer Trust Architecture Implementation Guide

Validation of Discovery, Collections, Artefacts, and Lifecycle (CLE)

---

## 1. Purpose

This document defines how a consumer retrieves and validates TEA data, including:

- discovery of the correct TEA endpoint  
- validation of discovery authorization  
- retrieval of TEA collections and artefacts  
- validation of artefact authenticity and release binding  
- validation of lifecycle (CLE) state and history  
- long-term validation of evidence  

The goal is to ensure that a consumer can independently verify:

- who published the artefacts  
- that they were not modified  
- that they belong to a specific release  
- that they remain valid over time  
- what lifecycle state applies and how it evolved  

---

## 2. Core Trust Principle

A consumer MUST NOT trust:

- the network  
- the TEA service  
- the hosting provider  

A consumer MUST trust only:

- digital signatures  
- trust anchors  
- timestamps (TSA)  
- transparency evidence  
- DNS (context-dependent)  
- optionally DNSSEC  

> TEA validation depends on the consistency of independent evidence layers. No single mechanism establishes trust.

---

## 3. Trust Layers Overview

Consumers MUST treat the following layers separately:

### Discovery Trust
Determines which endpoint is authorized.

### Transport Trust
Ensures secure communication (TLS).

### Artefact Trust
Determines whether data is authentic and valid.

### Lifecycle Trust (CLE)
Determines lifecycle state and historical changes over time.

---

## 4. High-Level Validation Flow

A consumer MUST perform:

1. Retrieve discovery document  
2. Validate discovery signature  
3. Validate discovery timestamp (REQUIRED)  
4. Resolve trust model  
5. Resolve trust anchor  
6. Resolve TEA endpoint  
7. Retrieve TEA collection and artefacts  
8. Validate artefact signatures  
9. Validate collection signature  
10. Validate artefact-to-collection binding  
11. Validate timestamps  
12. Validate transparency  
13. Store validation evidence  
14. Retrieve lifecycle (CLE) documents (if applicable)  
15. Validate CLE signature, timestamp, and version chain  

Each step MUST succeed.

---

## 4.1 Evidence Bundle Support

A TEA consumer SHOULD support validation using TEA Evidence Bundles.

When an evidence bundle is available, the consumer SHOULD:

- use the bundle as the primary validation source  
- verify all included evidence:
  - signature  
  - certificate  
  - timestamp(s)  
  - transparency evidence  

The consumer MUST still validate:

- object digest  
- signature correctness  
- binding between all evidence layers  

Using an evidence bundle improves:

- offline validation  
- long-term verification  
- consistency across implementations  

---

## 5. Step 1 — Retrieve Discovery

```
GET https://<domain>/.well-known/tea
```

Requirements:

- TLS MUST be used  
- server certificate MUST be valid  

Failure:

- abort immediately  

---

## 6. Step 2 — Validate Discovery Document

The consumer MUST:

- parse JSON  
- validate schema  
- extract:
  - endpoints  
  - trust model  
  - signature  
  - timestamp  

### Canonicalization

- remove signature field  
- apply RFC 8785 (JCS)  

### Signature Validation

- verify signature  

### Timestamp Validation (REQUIRED)

The consumer MUST:

- verify TSA signature  
- verify timestamp integrity  
- verify timestamp within certificate validity  

### Transparency (Optional)

If transparency evidence is present:

- MUST be validated according to TEA transparency rules  

### Trust Model Resolution

- tea-native  
- webpki  

---

## 7. Step 3 — Resolve Discovery Trust Anchor

### 7.1 TEA-Native

The consumer MUST:

- resolve certificate via DNS CERT record  
- validate DNSSEC (if available)  

#### SAN Validation (CRITICAL)

The consumer MUST verify:

```
SAN = <fingerprint>.<domain>
```

Where:

```
fingerprint = SHA-256(public key)
```

Mismatch → MUST fail  

---

### 7.2 WebPKI

The consumer MUST:

- validate certificate chain (PKIX)  

#### CAA Validation (IMPORTANT)

The consumer SHOULD:

- query DNS CAA records  
- verify issuing CA is authorized  

If:
- CAA exists AND CA not authorized → SHOULD fail  

#### DNSSEC Strengthening

If DNSSEC is available:

- SHOULD validate CAA with DNSSEC  

---

## 8. Step 4 — Validate Discovery Authorization

If signature and timestamp are valid:

- endpoint is authorized  

Else:

- abort  

---

## 9. Step 5 — Retrieve Collection and Artefacts

Retrieve:

- TEA collection  
- artefacts  

All data MUST be treated as:

**UNTRUSTED**

---

## 10. Dual-Level Validation Model

Consumers MUST validate:

1. artefact-level signatures  
2. collection-level signature  

Both are required.

---

## 11. Step 6 — Validate Artefact Signatures

For each artefact:

- canonicalize (if applicable)  
- verify signature  
- resolve trust anchor  
- validate SAN fingerprint (TEA-native)  
- validate timestamp (REQUIRED for TEA-native)  
- validate transparency (if required by policy)  

Result:

- valid → authentic  
- invalid → reject  

---

## 12. Step 7 — Validate Collection Signature

The consumer MUST:

- canonicalize collection  
- verify signature  
- resolve trust anchor  
- validate SAN fingerprint  
- validate timestamp  
- validate transparency  

Result:

- valid → release defined  
- invalid → reject entire release  

---

## 13. Step 8 — Validate Binding

The consumer MUST verify:

```
digest(artefact) == digest in collection
```

Mismatch → reject  

---

## 14. Combined Trust Decision

Trust only if:

- artefact signature valid  
- collection signature valid  
- binding valid  

---

## 14.1 Evidence Binding (CRITICAL)

The consumer MUST verify that all evidence refers to the same cryptographic object.

This includes:

- signature binds to object  
- timestamp binds to signature  
- transparency binds to signature or timestamped signature  

If any mismatch occurs:

→ validation MUST fail  

---

## 15. Step 9 — Timestamp Validation (DETAILED)

Requirement:

- TEA-native → MUST validate timestamp  
- WebPKI → SHOULD validate timestamp  

The consumer MUST verify:

- TSA signature  
- TSA certificate chain  
- timestamp integrity  
- timestamp within certificate validity  

### Binding Requirement

```
messageImprint == hash(signature)
```

---

## 16. Step 10 — Transparency Validation

The consumer MUST:

- verify transparency evidence according to the system:
  - Rekor → inclusion proof + log signature  
  - Sigsum → log + witness signatures  
  - SCITT → receipt verification  

- verify that transparency evidence binds to:
  - the signature, OR  
  - the timestamped signature  

Validation MUST fail if:

- binding does not match  
- evidence is invalid  

---

## 17. Long-Term Validation

Consumers MUST support validation after certificate expiry.

### Required Evidence

- signature  
- timestamp  
- TSA certificate chain  
- transparency evidence  

### Rule

If:

- certificate was valid at timestamp  

→ signature remains valid  

### Implication

Short-lived keys DO NOT limit long-term trust.

---

## 18. Lifecycle (CLE) Validation

Consumers MAY retrieve lifecycle (CLE) documents for:

- product  
- product release  
- component  
- component release  

### Requirements

For each CLE document, the consumer MUST:

- validate signature  
- validate timestamp  
- resolve trust anchor  
- validate SAN fingerprint (TEA-native)  
- validate transparency (if required by policy)  

### Version Chain Validation (CRITICAL)

Consumers MUST verify:

- version numbers are monotonic  
- previousVersion references are correct  
- no gaps or rewrites exist  

If:

- version chain is broken  

→ MUST reject lifecycle trust  

### Interpretation

CLE does NOT change:

- artefact authenticity  
- release integrity  

CLE DOES provide:

- lifecycle state (active, deprecated, EOL)  
- forward-looking commitments  
- audit trail of lifecycle changes  

Consumers MAY use CLE to:

- enforce policy (e.g. reject EOL products)  
- assess operational risk  
- support compliance decisions  

---

## 19. Trust Model Differences

### TEA-Native

- trust anchor: DNS CERT  
- DNSSEC: recommended  
- certificates: short-lived  
- timestamps: REQUIRED  
- transparency: REQUIRED  
- CLE: MUST follow same validation model  

---

### WebPKI

- trust anchor: CA ecosystem  
- DNS:
  - NOT trust anchor  
  - used for CAA policy  

- timestamps: SHOULD  
- transparency: policy dependent  
- CLE: MUST follow same validation model  

---

## 20. Error Handling

Consumers MUST fail closed.

### Errors

- DISCOVERY_INVALID  
- DISCOVERY_SIGNATURE_INVALID  
- DISCOVERY_TIMESTAMP_INVALID  
- TRUST_ANCHOR_NOT_FOUND  
- SAN_FINGERPRINT_MISMATCH  
- ARTEFACT_SIGNATURE_INVALID  
- COLLECTION_SIGNATURE_INVALID  
- BINDING_FAILED  
- TIMESTAMP_INVALID  
- TRANSPARENCY_INVALID  
- CLE_SIGNATURE_INVALID  
- CLE_VERSION_CHAIN_INVALID  
- CLE_TIMESTAMP_INVALID  

---

## 21. Logging

Consumers SHOULD log:

- domain  
- trust model  
- certificate fingerprints  
- timestamps  
- transparency results  
- validation outcomes  

---

## 22. Performance Considerations

Consumers MAY:

- cache DNS  
- cache trust anchors  
- cache transparency  

Consumers MUST:

- revalidate per release  

---

## 23. Security Requirements

Consumers MUST:

- validate both signature levels  
- validate binding  
- validate timestamps  
- validate transparency  

Consumers MUST NOT:

- trust transport alone  
- trust endpoints alone  
- skip validation  

---

## 24. Security Guarantees

If all validation succeeds:

- artefacts are authentic  
- release composition is correct  
- lifecycle state is authentic and auditable  
- tampering is detectable  
- historical validity is preserved  

---

## 25. Failure Scenarios

- service compromise → signatures prevent forgery  
- DNS attack → DNSSEC mitigates (if used)  
- CI/CD compromise → detected via signatures  
- TSA failure → mitigated via multi-TSA  
- transparency log compromise → mitigated via multi-log  

---

## 26. Minimal Consumer Profile

- TLS validation  
- collection signature validation  
- artefact signature validation  
- binding validation  

---

## 27. Recommended Consumer Profile

- DNSSEC validation  
- timestamp validation  
- transparency validation  
- audit logging  

---

## 28. High-Assurance Profile (CRA-aligned)

- full validation  
- long-term evidence storage  
- periodic re-validation  
- audit-grade logging  

---

## 🎯 Final Statement

A TEA consumer does not trust:

___where data came from___

A TEA consumer trusts:

___what can be proven___