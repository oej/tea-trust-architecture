# 📄 profiles/high-assurance-profile.md

# TEA High Assurance Profile (v1.0)

---

## 1. Purpose

This document defines the **High Assurance Profile** for TEA.

It specifies **stricter validation and publication requirements** for:

- regulated environments (e.g., EU CRA)
- critical infrastructure
- long-term archival validation
- high-risk supply chains

This profile builds on the baseline TEA model and introduces **mandatory multi-anchor trust validation**.

---

## 2. Scope

This profile applies to:

- discovery
- consumer validation
- publication

It defines **mandatory requirements** beyond the base TEA specification.

---

## 3. Core Principle

> **High assurance requires multiple independent, verifiable trust anchors.**

No single mechanism (certificate, DNS, or signature alone) is sufficient.

---

## 4. Mandatory Trust Anchors

A compliant implementation MUST validate at least **three independent trust anchors**:

| Anchor | Purpose |
|--------|--------|
| Signature | integrity |
| Timestamp | time of existence |
| Certificate | identity context |
| DNS (TEA-native) | publication |
| Transparency | auditability |

---

### Rule

> At least **three anchors MUST be valid** for acceptance.

---

## 5. Discovery Requirements

---

### 5.1 Mandatory Controls

Discovery MUST:

- be signed  
- include a TSA timestamp  
- be schema-valid  

---

### 5.2 Transparency

Discovery MUST:

- be logged in a transparency system  
- provide verifiable inclusion proof  

---

### 5.3 DNS Validation (TEA-Native)

If TEA-native is used:

- discovery certificate MUST be published in DNS  
- DNSSEC MUST be validated  

---

### 5.4 Failure Conditions

Discovery MUST fail if:

- signature invalid  
- timestamp missing or invalid  
- DNSSEC validation fails (when TEA-native)  
- transparency inclusion missing  

---

## 6. Consumer Validation Requirements

---

### 6.1 Mandatory Checks

A consumer MUST:

1. validate collection signature  
2. validate collection timestamp  
3. verify artefact checksum binding  
4. require artefact signature  
5. validate artefact timestamp  
6. validate certificate validity at timestamp  
7. validate transparency inclusion  
8. validate trust anchor (DNS or PKI)  

---

### 6.2 DNSSEC Requirement (TEA-Native)

If TEA-native is used:

- DNSSEC validation MUST succeed  
- failure MUST result in rejection  

---

### 6.3 Transparency Requirement

Consumers MUST:

- verify inclusion proof  
- verify log signature or checkpoint  
- ensure log consistency  

---

### 6.4 Timestamp Requirement

Consumers MUST:

- verify TSA signature  
- validate TSA certificate chain  
- ensure timestamp is within certificate validity  

---

### 6.5 Multi-TSA Recommendation

Implementations SHOULD:

- use multiple TSA providers  
- compare timestamps for consistency  

---

## 7. Publication Requirements

---

### 7.1 Commit Control

Publication MUST:

- require strong authentication (MFA)  
- record approver identity  
- record timestamp of approval  
- freeze release state  

---

### 7.2 Evidence Validation at Commit

Before commit, the system MUST validate:

- all signatures  
- all timestamps  
- all certificates  
- transparency inclusion  
- DNS publication (TEA-native)  

---

### 7.3 DNS Publication (TEA-Native)

If TEA-native is used:

- certificate MUST be published in DNS  
- DNSSEC MUST be active and valid  
- publication MUST be authorized  

---

### 7.4 Transparency Submission

Publication MUST include:

- submission of artefacts and/or collection  
- receipt or inclusion proof  

---

## 8. Evidence Retention

---

### 8.1 Mandatory Retention

The following MUST be preserved:

- artefacts  
- artefact signatures  
- collection  
- collection signature  
- certificate  
- timestamp tokens  
- transparency receipts  

---

### 8.2 Retention Duration

Evidence MUST be retained for:

- at least 10 years  
- or as required by applicable regulation  

---

## 9. WebPKI Requirements

---

### 9.1 Certificate Validation

Consumers MUST:

- validate full PKIX chain  
- enforce certificate validity  

---

### 9.2 CAA Enforcement

Consumers MUST:

- perform CAA lookup  
- reject certificates issued by unauthorized CA  

---

### 9.3 DNS Role

| Element | Role |
|--------|------|
| DNS CERT | MUST NOT be used |
| DNSSEC | OPTIONAL |
| CAA | REQUIRED |
| A/AAAA | transport only |

---

## 10. TEA-Native Requirements

---

### 10.1 Certificate Profile

Certificates MUST:

- be self-signed  
- use Ed25519 (preferred)  
- include fingerprint-derived SAN  

---

### 10.2 Fingerprint Binding

Consumers MUST:

1. compute SHA-256(public key)  
2. verify SAN matches `<fingerprint>.<domain>`  

---

### 10.3 DNS Validation

Consumers MUST:

- resolve certificate from DNS  
- compare with provided certificate  
- validate DNSSEC  

---

## 11. Failure Handling

---

### 11.1 Hard Failures (MUST Reject)

- invalid signature  
- missing required signature  
- missing timestamp  
- invalid timestamp  
- certificate invalid at timestamp  
- missing transparency inclusion  
- DNSSEC validation failure (TEA-native)  
- CAA violation (WebPKI)  

---

### 11.2 No Partial Validation

> Partial validation MUST be treated as failure.

---

## 12. Security Enhancements

---

### 12.1 Ephemeral Key Enforcement

- keys MUST be short-lived  
- keys MUST NOT be reused  
- keys MUST be destroyed after use  

---

### 12.2 Audit Logging

Systems MUST log:

- validation results  
- trust anchors used  
- timestamps  
- transparency verification  
- DNS/DNSSEC status  
- approval events  

---

## 13. Security Guarantees

When this profile is followed, TEA provides:

- strong resistance to tampering  
- detection of unauthorized publication  
- long-term verifiability  
- audit-ready evidence  
- reduced reliance on centralized trust  

---

## 14. Limitations

Residual risks include:

- CA compromise (WebPKI)  
- DNS infrastructure compromise  
- TSA compromise  
- transparency operator trust  

These risks are mitigated but not eliminated.

---

## 15. Summary

The High Assurance Profile strengthens TEA by:

- requiring multiple independent trust anchors  
- enforcing timestamp and transparency validation  
- mandating DNSSEC in TEA-native deployments  
- enforcing strict publication controls  
- ensuring long-term evidence retention  

---

## 16. One-Line Takeaway

> **High assurance in TEA is achieved by combining multiple independent trust anchors and preserving verifiable evidence for long-term validation.**

---