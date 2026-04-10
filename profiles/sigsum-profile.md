# 📘 TEA Trust Architecture — Sigsum Profile
**Version:** 1.0  
**Status:** Draft (Normative, Implementation-Ready)

---

## Status

This document defines a **TEA implementation profile** for using **Sigsum** as a transparency backend within the TEA trust architecture.

This specification is **implementation-ready** but subject to change based on implementation experience and community feedback.

The key words **MUST**, **SHOULD**, and **MAY** are to be interpreted as described in RFC 2119.

This document is intended to be used together with:

- the TEA Trust Architecture core specification  
- the TEA Evidence Bundle specification  
- the TEA Evidence Validation specification  
- the TEA timestamp validation specification  

---

## Table of Contents

1. [Purpose](#1-purpose)  
2. [Scope](#2-scope)  
3. [Relationship to the TEA Trust Architecture](#3-relationship-to-the-tea-trust-architecture)  
4. [Sigsum Security Model](#4-sigsum-security-model)  
5. [What Is Logged in Sigsum](#5-what-is-logged-in-sigsum)  
6. [Cryptographic Binding Model](#6-cryptographic-binding-model)  
7. [Logging Requirements by TEA Object Type](#7-logging-requirements-by-tea-object-type)  
8. [Verification Material and Evidence Bundles](#8-verification-material-and-evidence-bundles)  
9. [Validation Requirements](#9-validation-requirements)  
10. [Trusting Sigsum as a Service](#10-trusting-sigsum-as-a-service)  
11. [Failure Handling](#11-failure-handling)  
12. [Privacy Considerations](#12-privacy-considerations)  
13. [Profiles](#13-profiles)  
14. [Final Statement](#14-final-statement)  

---

## 1. Purpose

This profile defines how TEA uses **Sigsum** as a transparency backend.

It is an implementation profile for the TEA transparency layer, not a replacement for the TEA trust architecture.

Sigsum is designed to make a signer’s **key usage transparent**, and its logs record **signed checksums with minimal metadata** rather than acting as a general object repository.  [oai_citation:0‡git.sigsum.org](https://git.sigsum.org/sigsum/tree/doc/design.md?utm_source=chatgpt.com)

Within TEA, Sigsum provides:

- transparency evidence  
- inclusion proofs  
- append-only log guarantees  
- witness-cosigned checkpoints or tree heads for offline verification workflows  [oai_citation:1‡git.sigsum.org](https://git.sigsum.org/sigsum/tree/doc/design.md?utm_source=chatgpt.com)

TEA still relies on its own trust model for:

- certificate validation  
- timestamp validation  
- DNS publication in TEA-native mode  
- collection semantics  
- publication authorization  

This profile preserves a strict separation:

- **TEA** = source of truth for TEA artifacts and TEA collections  
- **Sigsum** = transparency witness for trust-relevant TEA objects  

---

## 2. Scope

This profile applies to the following TEA object types:

- short-lived TEA signing certificates  
- signed TEA collections  
- signed TEA artifacts  
- signed attestations  
- optionally signed discovery documents  

Sigsum is **not**:

- the TEA artifact repository  
- the primary discovery mechanism  
- a TEA trust anchor  
- a substitute for timestamps or evidence bundles  

---

## 3. Relationship to the TEA Trust Architecture

In the TEA trust architecture, transparency is one independent trust layer among several.

Sigsum therefore complements, but does not replace:

- signatures  
- certificates  
- timestamps  
- DNS or PKIX trust anchoring  
- publication authorization  

This profile follows the TEA design principle that **no single service is trusted completely**.

---

## 4. Sigsum Security Model

Sigsum logs are intended to make **key usage transparent** and are designed around simple parsing, constrained verification, and witness-based gossip/cosigning rather than rich object storage.  [oai_citation:2‡git.sigsum.org](https://git.sigsum.org/sigsum/tree/doc/design.md?utm_source=chatgpt.com)

For TEA, the important security properties are:

- the log records a cryptographically bound statement  
- the statement is included in an append-only structure  
- inclusion can be proven using a proof tied to a cosigned checkpoint or tree head  
- verification can be performed offline if the required proof material is preserved  [oai_citation:3‡git.sigsum.org](https://git.sigsum.org/sigsum/tree/doc/design.md?utm_source=chatgpt.com)

Sigsum does **not** establish:

- identity trust of the signer  
- correctness of the TEA artifact or collection  
- authorization of publication  
- completeness across all possible logs  

Those properties remain outside the scope of Sigsum and are handled by TEA itself.

---

## 5. What Is Logged in Sigsum

Sigsum is designed around logging **signed checksums** rather than storing arbitrary full objects or large metadata structures.  [oai_citation:4‡git.sigsum.org](https://git.sigsum.org/sigsum/tree/doc/design.md?utm_source=chatgpt.com)

Therefore, in TEA:

- Sigsum MUST be used to log a cryptographically bound representation of the signed object  
- Sigsum MUST NOT be treated as the authoritative repository for TEA artifacts, TEA collections, or certificates  
- TEA implementations MUST preserve the full signed object and its evidence outside Sigsum  

This means the authoritative TEA object remains in TEA-controlled storage, while Sigsum provides verifiable transparency evidence about that object.

---

## 6. Cryptographic Binding Model

### 6.1 Core Rule

Sigsum entries used by TEA MUST be bound to the same cryptographic object that the TEA validator evaluates.

The correct order is:

```text
artifact → signature → timestamp(signature) → Sigsum log
```

This aligns transparency with the TEA evidence model.

### 6.2 What Sigsum Logs

For TEA, Sigsum SHOULD log one of the following:

- the digital signature  
- the timestamped signature object  

Sigsum MUST NOT log:

- the raw artifact hash alone, when that would break binding to the signature and timestamp chain

### 6.3 Binding Requirements

A TEA implementation MUST ensure that:

```text
timestamp.messageImprint == SHA-256(signature)
```

and that the Sigsum transparency evidence corresponds to:

```text
SHA-256(signature)
```

or:

```text
SHA-256(timestamped_signature_object)
```

depending on the chosen profile.

If these bindings do not hold, validation MUST fail.

### 6.4 Rationale

The TEA trust architecture treats the **evidence bundle** as the atomic trust object.  
That means transparency must be aligned with the same signed object that timestamp validation evaluates.

Binding Sigsum to the raw artifact alone would weaken that model and create ambiguity about what exactly was logged.

---

## 7. Logging Requirements by TEA Object Type

### 7.1 Short-Lived Signing Certificates

Short-lived TEA signing certificates SHOULD be logged in Sigsum.

This is strongly recommended because TEA certificates are ephemeral and transparency preserves durable evidence that the signing identity wrapper existed.

For certificates:

- TEA MUST preserve the full certificate outside Sigsum  
- Sigsum provides transparency evidence about the logged certificate-related statement  

### 7.2 TEA Collections

Signed TEA collections SHOULD be logged in Sigsum.

Reason:

- the collection is the authoritative release statement  
- the collection is a trust-relevant signed object  
- logging improves auditability and detectability of misuse  

### 7.3 TEA Artifacts

Signed TEA artifacts SHOULD be logged in Sigsum when independent artifact authenticity matters.

This is especially important for:

- SBOMs  
- signed attestations  
- release-related artifacts distributed independently of collections  

### 7.4 Attestations

Structured attestations MAY be logged through the same signed-checksum model used by Sigsum, provided the TEA implementation preserves the full attestation object and can prove the binding from attestation to signature to log entry.

### 7.5 Discovery Documents

Signed discovery documents MAY be logged in Sigsum.

This is not a replacement for discovery authorization; it is optional additional publication evidence.

### 7.6 Minimum Recommended Coverage

A TEA implementation using Sigsum SHOULD log at least:

- the short-lived signing certificate  
- the signed TEA collection  

### 7.7 Recommended Coverage

A TEA implementation SHOULD additionally log:

- signed TEA artifacts  
- signed attestations  
- signed discovery documents where discovery auditability is desired  

### 7.8 High-Assurance Coverage

A high-assurance TEA deployment SHOULD log:

- every short-lived signing certificate  
- every signed TEA collection  
- every signed TEA artifact requiring independent authenticity  
- every signed discovery document  
- every trust-relevant attestation  

---

## 8. Verification Material and Evidence Bundles

Sigsum evidence MUST be preserved in the TEA evidence bundle.

At minimum, the evidence bundle SHOULD contain:

- the Sigsum inclusion proof  
- the relevant cosigned checkpoint or tree head  
- any required log identifier  
- any witness or cosigner information required by policy  
- the exact binding target digest  

This is important because TEA validation MUST remain possible without requiring the end user to query the log live after logging succeeded. Sigsum’s design supports offline verification when proof material is retained.  [oai_citation:5‡git.sigsum.org](https://git.sigsum.org/sigsum/commit/?h=beamer&id=fded435770ec49db0f7459ae1d0bb41fddda8c0f&utm_source=chatgpt.com)

A TEA implementation MUST preserve, outside Sigsum:

- the full TEA object  
- the signature  
- the certificate  
- timestamp tokens  
- the evidence bundle including Sigsum proof material  

---

## 9. Validation Requirements

A TEA consumer using Sigsum evidence MUST verify:

1. the TEA signature  
2. the TEA certificate according to the selected trust model  
3. timestamp validity  
4. timestamp binding to the signature  
5. Sigsum inclusion proof validity  
6. binding of the Sigsum proof to the same signature or timestamped signature object  
7. policy requirements for accepted logs and witnesses  

### 9.1 Offline Validation

TEA implementations SHOULD support offline validation of Sigsum evidence.

This requires preserving:

- inclusion proof  
- cosigned checkpoint or tree head  
- log identification and policy metadata  
- any required witness verification inputs  

### 9.2 Consistency Requirement

If multiple Sigsum proofs or checkpoints are available, consumers SHOULD validate consistency according to local policy.

### 9.3 Failure Condition

Any mismatch between:

- the signed object  
- the timestamp binding  
- the Sigsum binding  
- the preserved evidence bundle  

MUST result in validation failure.

---

## 10. Trusting Sigsum as a Service

### 10.1 Principle

Sigsum is trusted as a **verifiable transparency witness**, not as a root of trust.

### 10.2 What Must Be Trusted

A TEA implementation using Sigsum MUST define policy for:

- accepted Sigsum log public keys  
- accepted witness or cosigner public keys, where required  
- accepted service endpoints or deployments  
- required witness quorum or cosigning policy, where applicable  

### 10.3 What Must Not Be Assumed

A TEA implementation MUST NOT assume trust merely because:

- an entry exists in Sigsum  
- the log accepted a submission  
- the log is operated by a known party  

Presence alone is insufficient.  
Validation MUST still rely on:

- signature correctness  
- certificate validation  
- timestamp validation  
- cryptographic binding rules  

### 10.4 Multi-Log and Multi-Witness Models

TEA deployments MAY require:

- inclusion in more than one transparency log  
- witness or cosigner thresholds  
- independent operator diversity  

This is especially appropriate in high-assurance profiles.

---

## 11. Failure Handling

The following conditions MUST be handled as shown:

| Condition | Result |
|----------|--------|
| invalid Sigsum proof | FAIL |
| invalid checkpoint or tree head signature | FAIL |
| invalid witness/cosigner verification required by policy | FAIL |
| binding mismatch | FAIL |
| log unavailable but preserved proof material is sufficient | continue according to policy |
| live log unavailable and preserved proof material missing | policy dependent |

A TEA implementation MUST fail closed where the selected profile requires Sigsum validation and the required proof or binding cannot be established.

---

## 12. Privacy Considerations

Sigsum logs signed checksums with minimal metadata rather than arbitrary object bodies. That design helps reduce unnecessary data exposure compared with systems that store richer objects directly.  [oai_citation:6‡git.sigsum.org](https://git.sigsum.org/sigsum/tree/doc/design.md?utm_source=chatgpt.com)

However, TEA implementations SHOULD still assess whether logging a given signature-derived object reveals sensitive information through:

- correlation  
- metadata  
- predictable content relationships  

Where confidentiality matters, implementations SHOULD prefer the minimum sufficient logged binding object.

---

## 13. Profiles

### 13.1 Minimal

- log short-lived certificate  
- log signed collection  
- preserve proof material in evidence bundle  

### 13.2 Recommended

- log certificate  
- log signed collection  
- log independently signed TEA artifacts  
- preserve offline-verifiable Sigsum proof material  

### 13.3 High Assurance

- require Sigsum plus one additional independent transparency system, or multiple accepted Sigsum witness/cosigner policies  
- require preserved offline verification material  
- require strict binding validation  
- require policy-defined quorum or multi-log acceptance  

---

## 14. Final Statement

Sigsum provides transparency evidence in TEA by making trust-relevant key usage and signed statements publicly auditable through append-only logs and offline-verifiable proofs.  [oai_citation:7‡git.sigsum.org](https://git.sigsum.org/sigsum/tree/doc/design.md?utm_source=chatgpt.com)

In TEA, Sigsum is:

- a transparency witness  
- an audit mechanism  
- a verification layer  

It is **not**:

- the source of truth for TEA objects  
- a trust anchor  
- a substitute for timestamps, certificates, or publication authorization  

---

## Key Principle

> Sigsum is trusted because its outputs are verifiable and independently checkable, not because it is a central authority.
