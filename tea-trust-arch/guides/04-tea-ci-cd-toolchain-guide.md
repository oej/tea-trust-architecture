# 📘 TEA CI/CD Toolchain Guide

With Gated Publication, Trust-Model Enforcement, and Ephemeral Signing

---

## 1. Purpose

This guide defines a CI/CD workflow for TEA that:

- prepares artefacts and collections automatically  
- separates draft and commit phases  
- requires human approval for publication  
- enforces correct handling of trust models  
- ensures DNS publication is performed only when appropriate  
- enforces ephemeral key usage and multi-anchor trust validation  

---

## 2. Core Principle

CI/CD systems MAY prepare releases.

CI/CD systems MUST NOT:

- publish authoritative releases  
- publish trust anchors in DNS  

All trust-establishing actions occur at commit time under human control.

---

## 3. Trust Model Awareness in CI/CD

The trust model is defined at the **product level** and MUST be consistent across all releases.

Supported trust models:

- `tea-native`
- `webpki`

CI/CD MUST:

- retrieve and respect the product trust model  
- enforce behavior consistent with that model  

The trust model determines:

- certificate handling  
- timestamp requirements  
- transparency requirements  
- DNS publication behavior  

---

## 4. Key Distinction: DNS Publication Scope

DNS publication is not universal.

### Rule

- TEA-native → DNS MUST be used for trust anchor publication  
- WebPKI → DNS MUST NOT be used for trust anchoring  

This rule MUST be enforced in both CI/CD logic and TEA service policy.

---

## 5. CI/CD Workflow Overview

1. Build artefacts  
2. Generate signing material (ephemeral)  
3. Sign artefacts and collection  
4. Obtain timestamps and transparency proofs  
5. Construct evidence bundles (RECOMMENDED)  
6. Upload draft release  
7. (Optional) Upload DNS publication candidate  
8. Human commit with MFA  
9. Conditional DNS publication based on trust model  

---

## 6. CI/CD Phases

### 6.1 Preparation Phase (Automated)

- build artefacts  
- generate ephemeral keys  
- sign artefacts  
- create and sign collection  
- obtain timestamps  
- submit to transparency logs  
- upload draft  

### 6.2 Commit Phase (Human-Controlled)

- review release  
- approve publication (MFA)  
- optionally approve DNS publication  
- finalize release  

---

## 7. Stage — Generate Signing Material

### 7.1 TEA-Native Model

CI/CD generates:

- ephemeral Ed25519 key pair  
- short-lived self-signed X.509 certificate  

#### Ephemeral Key Requirements

Private keys:

- MUST be generated per signing event  
- MUST NOT be reused  
- MUST NOT be stored long-term  
- MUST be deleted immediately after signing  

---

### Certificate Requirements

The certificate MUST:

- be self-signed  
- use Ed25519  
- be short-lived (typically hours)  
- NOT include CN  

#### Subject Requirements

- O MUST contain legal entity name (if applicable)  
- OU OPTIONAL  
- C SHOULD be present  

Subject is informational only and MUST NOT be used for trust decisions.

---

### SAN Requirements (CRITICAL)

The certificate MUST contain:

```
<fingerprint>.<trust-domain>
```

Where:

- fingerprint = SHA-256(public key), lowercase hex  
- MUST match the public key  

Optional persistence SAN:

```
<fingerprint>.<persistence-domain>
```

Constraints:

- fingerprint MUST be identical across SAN entries  
- no additional SAN entries allowed  

---

### 7.2 WebPKI Model

CI/CD uses:

- CA-issued signing certificate  

CI/CD MUST NOT:

- generate DNS publication data  
- attempt DNS anchoring  

---

### 7.3 Key Lifecycle Enforcement

CI/CD systems MUST enforce:

1. key generation  
2. signing  
3. immediate key destruction  

Keys MUST NOT:

- be persisted  
- be exported  
- be reused  

---

### 7.4 Why Ephemeral Keys Are Safe

Ephemeral keys reduce risk because:

- compromise window is minimal  
- no long-term key storage is required  

Long-term validation is preserved through:

- timestamps (prove signing time)  
- transparency logs (prove existence)  
- DNS (TEA-native anchor distribution)  

---

## 8. Stage — Signing and Evidence

### 8.1 Artefact-Level Signing

Applies to:

- SBOMs  
- attestations  
- provenance  

Provides:

- integrity  
- origin  

---

### 8.2 Collection-Level Signing

Provides:

- release definition  
- binding of artefacts  

---

### 8.3 Combined Meaning

When both are valid:

> “This artefact is authentic AND part of this release.”

---

### 8.4 Timestamp Requirement (CRITICAL)

CI/CD MUST obtain timestamps for:

- collection signature (REQUIRED)  
- artefacts (RECOMMENDED)  

#### Timestamp Binding Rule

The timestamp MUST bind to the signature:

```
messageImprint = hash(signature)
```

The timestamp MUST satisfy:

```
timestamp ∈ [certificate.notBefore, certificate.notAfter]
```

This ensures:

- the signature was created while the certificate was valid  
- long-term validation remains possible after certificate expiration  

---

### 8.5 Transparency Requirement

CI/CD SHOULD submit:

- signing certificate  
- collection  
- artefacts (recommended)  

to one or more transparency systems:

- Rekor  
- Sigsum  
- SCITT (future-compatible)  

#### Submission Timing

Transparency submission SHOULD occur:

- before publication  
- ideally before or together with timestamping  

---

### 8.6 Evidence Bundle (RECOMMENDED)

CI/CD SHOULD construct a TEA Evidence Bundle containing:

- signature  
- certificate  
- timestamp(s)  
- transparency evidence  

Benefits:

- offline validation  
- long-term verification  
- portability  

---

## 9. Stage — Upload Draft Release

CI/CD uploads:

- artefacts  
- TEA collection  
- signatures  
- certificates  
- timestamps  
- transparency receipts  
- evidence bundles (if used)  

---

### Artefact State Constraints

CI/CD MUST ensure:

- artefacts NOT included in a collection MUST NOT be published  
- artefacts included in a published collection MUST NOT be modified or deleted  

TEA services MAY:

- delete unused artefacts after a configured retention period  

---

### Conditional Upload

If TEA-native:

- MAY upload DNS publication candidate  

If WebPKI:

- MUST NOT upload DNS data  

---

## 10. Stage — DNS Publication Candidate

### Purpose

CI/CD MAY prepare DNS data but MUST NOT publish it.

---

### TEA-Native

Candidate MUST contain:

- signing certificate  

---

### WebPKI

DNS candidate MUST NOT exist  

---

## 11. Stage — Commit Phase

A human with MFA MUST:

- review release  
- approve publication  
- approve DNS publication (if applicable)  

---

### Multi-Party Approval (OPTIONAL)

Implementations MAY require:

- multiple approvers (e.g. 2-of-N)

Recommended for high-assurance environments.

---

## 12. Commit-Time DNS Logic

System MUST validate:

- trust model consistency  
- DNS eligibility  

---

### TEA-Native

- publish signing certificate  

---

### WebPKI

- DNS publication MUST be rejected  

---

## 13. Validation Before DNS Publication

System MUST verify:

- certificate matches signing key  
- SAN format is correct  
- fingerprint matches public key  
- certificate validity window  
- timestamp validity  
- transparency evidence (if required)  

---

### Fingerprint Validation (CRITICAL)

System MUST recompute:

```
SHA-256(public key)
```

Mismatch → reject  

---

## 14. Discovery Interaction

If TEA-native:

- DNS MUST be published before or with discovery  

If WebPKI:

- discovery MUST NOT reference DNS  

---

### WebPKI DNS Policy (CAA)

CI/CD SHOULD:

- verify DNS CAA records authorize the issuing CA  

If DNSSEC is available:

- SHOULD validate CAA with DNSSEC  

---

## 15. Validation Policy

CI/CD pipelines MUST fail closed.

If any required step fails:

- signing  
- timestamping  
- transparency  
- validation checks  

→ the release MUST NOT proceed  

---

## 16. Failure Handling

### DNS Violations

System MUST reject and log:

- DNS_PUBLICATION_NOT_ALLOWED_FOR_WEBPKI  
- DNS_CERT_TYPE_INVALID  
- DNS_SAN_MISMATCH  
- DNS_CERT_DOES_NOT_MATCH_SIGNING_KEY  
- SAN_FINGERPRINT_MISMATCH  

---

### Additional Failures

- EPHEMERAL_KEY_REUSE_DETECTED  
- MISSING_TIMESTAMP  
- TRANSPARENCY_SUBMISSION_FAILED  
- AUTHORIZATION_FAILED  

---

## 17. Audit Logging

CI/CD systems MUST log:

- user or system identity  
- timestamp  
- release identifier  
- operation type  

Implementations SHOULD:

- use standardized event identifiers  
- support audit export  

---

## 18. Security Implications

### 18.1 No Trust Confusion

- DNS used only for TEA-native  
- WebPKI remains separate  

---

### 18.2 CI/CD Containment

- CI/CD cannot establish trust  
- human approval required  

---

### 18.3 Ephemeral Key Model

- no long-term key risk  
- minimal exposure window  

---

### 18.4 Multi-Anchor Trust

Trust is based on:

- certificate  
- timestamp  
- DNS  
- transparency log  

---

## 19. Minimal Implementation Rules

CI/CD MUST:

- respect product trust model  
- enforce DNS restrictions  
- never publish DNS  
- use ephemeral keys  

---

## 20. Recommended Implementation Rules

CI/CD SHOULD:

- validate trust model early  
- fail on mismatch  
- log trust decisions  
- separate DNS candidate generation  
- generate evidence bundles  

---

## 21. Final Rules (Authoritative)

- trust model is defined per product, not per release  
- DNS publication is allowed only for TEA-native  
- WebPKI certificates MUST NEVER be published in DNS  
- private keys MUST be ephemeral and MUST NOT be retained  
- SAN MUST contain fingerprint-derived DNS name  
- timestamp MUST prove certificate validity at signing time  

---

## ✅ Result

This CI/CD model:

- enforces correct trust separation  
- removes long-term key risks  
- enables strong supply chain validation  
- aligns with CRA-style lifecycle requirements  

---