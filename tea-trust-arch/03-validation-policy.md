# 📄 spec/validation-policy.md  
# TEA Minimum Acceptable Validation Policy (v1.0)

---

## 1. Purpose

This document defines the minimum validation requirements for TEA consumers.

It establishes:
* what MUST be validated  
* what SHOULD be validated  
* how trust anchors are combined  
* how failures are handled  

This policy applies to all TEA trust models and explicitly distinguishes between:

* TEA (base model)  
* TEA with the trust architecture  

---

## 2. Policy Model

Validation in TEA is:

**Compositional, not hierarchical**

Trust is derived from multiple independent signals:

* certificate (identity)  
* signature (integrity)  
* timestamp (time)  
* DNS (publication, TEA-native)  
* transparency log (auditability)  

Validation MUST be complete.

> Partial validation MUST be treated as failure.

---

## 3. Architecture Profiles

TEA validation is defined across three architecture profiles:

---

### 3.1 TEA Base

Minimal TEA functionality without the trust architecture.

Characteristics:
* collection validation REQUIRED  
* artefact signatures OPTIONAL  
* timestamps OPTIONAL  
* transparency OPTIONAL  

---

### 3.2 TEA Trust Architecture (Baseline)

Defines the minimum acceptable secure deployment of TEA.

Characteristics:
* collection validation REQUIRED  
* artefact signatures REQUIRED  
* timestamp REQUIRED  
* timestamp MUST be signed by a trusted TSA  
* TSA certificate MUST chain to a trusted root in the local trust store  
* DNS validation REQUIRED for TEA-native  
* transparency SHOULD be validated  

---

### 3.3 TEA Trust Architecture (High Assurance)

Defines a stricter profile for regulated or long-term validation environments.

Characteristics:
* all baseline requirements  
* transparency REQUIRED  
* DNSSEC validation REQUIRED when available  
* multi-anchor validation REQUIRED  
* strict TSA validation REQUIRED  
* evidence retention REQUIRED  

---

## 4. Enforcement Levels

Within each architecture profile, validation strictness is defined as:

| Level | Name | Purpose |
|------|------|--------|
| L1 | Minimum | Minimum enforcement of selected profile |
| L2 | Recommended | Production-grade validation |
| L3 | Strict | Regulated / high-assurance validation |

---

## 5. Level 1 — Minimum Enforcement (MANDATORY)

A consumer MUST perform all checks in this section.

---

### 5.1 Collection Validation (MANDATORY)

Consumer MUST:

* verify collection signature  
* validate collection certificate according to trust model  
* validate collection timestamp (if required by profile)  
* extract artefact checksums  
* compute artefact digest  
* compare digest with collection  

Failure → MUST reject  

---

### 5.2 Artefact Signature Verification

TEA Base:
* artefact signatures OPTIONAL  

TEA with the trust architecture:
* artefact signatures MUST be present  
* artefact signatures MUST be verified  

Failure → MUST reject  

---

### 5.3 Certificate Validation

Consumer MUST verify:

* certificate structure is valid  
* signature algorithm is allowed  
* public key matches signature  
* validity period is well-formed  

TEA-native:
* self-signed certificate expected  
* Ed25519 expected  

WebPKI:
* PKIX validation REQUIRED  

Failure → MUST reject  

---

### 5.4 Fingerprint Consistency (TEA-Native)

Consumer MUST:

* compute SHA-256(public key)  
* verify that at least one SAN entry matches:

```text
<fingerprint>.<domain>
```

If multiple SANs exist:
* all MUST use the same fingerprint  
* at least one MUST correspond to a valid domain  

Failure → MUST reject  

---

### 5.5 Signature Coverage

Consumer MUST:

* apply correct canonicalization (raw or JCS)  
* verify signature over correct bytes  

Failure → MUST reject  

---

### 5.6 Timestamp Validation

TEA Base:
* OPTIONAL  

TEA with the trust architecture:
* MUST be present  
* MUST be validated  

Consumer MUST verify:

* timestamp signature is valid  
* TSA certificate chains to trusted root  
* TSA certificate validity  
* timestamp binds to signature  

```text
messageImprint == hash(signature)
```

* timestamp is within certificate validity window  

Failure → MUST reject  

---

## 6. Level 2 — Recommended Enforcement

---

### 6.1 DNS Validation (TEA-Native)

If DNS is used:

* SHOULD resolve certificate via DNS  
* SHOULD verify DNS-published certificate matches signing certificate  

If multiple SAN domains exist:
* SHOULD validate both trust and persistence domains  

Mismatch → SHOULD reject  

---

### 6.2 Transparency Validation

Consumer SHOULD:

* verify inclusion proof  
* verify log consistency  
* ensure entry matches signed object  

Failure → SHOULD reject  

---

### 6.3 Certificate Validity Window

Consumer SHOULD:

* verify current time within validity  
OR  
* verify timestamp within validity  

Failure → SHOULD reject  

---

### 6.4 WebPKI DNS Policy Checks

Consumer SHOULD:

* perform CAA lookup  
* verify issuing CA authorization  

Failure handling:

* unauthorized CA → SHOULD reject  
* missing CAA → MAY accept  

---

### 6.5 Evidence Bundle Support

Consumers SHOULD support validation using evidence bundles containing:

* signatures  
* certificates  
* timestamps  
* transparency evidence  

---

## 7. Level 3 — Strict / High Assurance

---

### 7.1 DNSSEC Validation (TEA-Native)

If DNSSEC is present:

* MUST validate DNSSEC chain  

Failure → MUST reject  

---

### 7.2 Timestamp Assurance

Consumer MUST:

* verify full TSA certificate chain  
* verify trusted TSA policy  

---

### 7.3 Transparency Strict Mode

Consumer MUST:

* require transparency inclusion  
* verify proofs cryptographically  

---

### 7.4 Multi-Anchor Requirement

At least three independent trust signals MUST validate, including:

* signature  
* certificate validation  
* timestamp  
* transparency (if required)  
* DNS publication (TEA-native)  

Signature + certificate alone are insufficient  

---

### 7.5 Persistence Validation

If persistence SAN exists:

* SHOULD validate publication under persistence domain  

---

### 7.6 WebPKI Policy Enforcement

Consumer MUST:

* enforce CAA validation  
* reject certificates from unauthorized CA  

---

## 8. Trust Model-Specific Rules

---

### 8.1 TEA-Native

Consumer MUST:

* validate SAN fingerprint model  
* validate certificate as self-signed  
* treat DNS as publication mechanism  

---

### 8.2 WebPKI

Consumer MUST:

* validate PKIX certificate chain  
* verify signature  

Consumer MUST NOT:

* use DNS CERT records as trust anchors  

---

### 8.3 DNS Policy Signals (WebPKI)

Consumer SHOULD consider:

* CAA records  

---

## 9. Failure Handling

---

### 9.1 Hard Failures (MUST Reject)

* invalid collection signature  
* invalid artefact signature (if required)  
* missing required signature  
* fingerprint mismatch  
* invalid certificate  
* invalid timestamp (when required)  

---

### 9.2 Conditional Failures

| Condition | L1 | L2 | L3 |
|----------|----|----|----|
| Missing DNS | OK | warn | warn |
| Missing timestamp | OK | warn | fail |
| Missing transparency | OK | warn | fail |
| DNSSEC failure | OK | warn | fail |
| CAA violation | OK | SHOULD fail | MUST fail |
| Missing CAA | OK | OK | OK |

---

### 9.3 Logging Requirements

Consumers SHOULD log:

* trust model  
* validation level  
* failed anchors  
* timestamp validation  
* DNS/DNSSEC status  
* CAA evaluation  

---

## 10. Validation Flow (Reference)

1. load collection  
2. validate collection signature  
3. validate collection timestamp  
4. extract artefact metadata  
5. load artefact  
6. detect signature type  
7. extract signature  
8. load certificate  
9. validate certificate  
10. compute fingerprint (TEA-native)  
11. verify SAN binding  
12. verify artefact signature  
13. validate DNS (if used)  
14. validate timestamp  
15. validate transparency  
16. validate CAA (WebPKI)  

---

## 11. Minimum Acceptance Rule

An artefact is acceptable only if:

### TEA Base
* collection validation succeeds  

### TEA with the Trust Architecture
* collection validation succeeds  
* artefact signature is valid  
* certificate validation succeeds  
* fingerprint binding is correct (TEA-native)  
* timestamp validation succeeds  

---

## 12. Security Rationale

---

### 12.1 Why Profiles?
* separates base TEA from trust architecture  
* enables consistent deployments  

---

### 12.2 Why Levels?
* supports gradual adoption  
* enables stricter validation where required  

---

### 12.3 Why Compositional Trust?
* avoids single point of failure  
* avoids CA dependency  
* increases resilience  

---

### 12.4 Why Ephemeral Keys?
* eliminates long-term key compromise  
* simplifies operations  

---

### 12.5 DNS in WebPKI

DNS provides policy signals, not trust anchors.

CAA:
* restricts CA issuance  
* reduces mis-issuance risk  

---

## 13. Final Rule

Consumers MUST NOT accept artefacts unless:

* collection validation succeeds  
* required signatures are valid  
* certificate validation succeeds  
* fingerprint binding is correct (TEA-native)  

---

## ✅ Result

This validation policy defines:

* enforceable validation logic  
* multi-anchor trust model  
* correct DNS handling across trust models  
* alignment with TEA trust architecture  
* CRA-compatible validation structure
