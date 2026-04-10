# 📄 TEA Core Security Specification (v1.0)

---

## 1. Scope

This specification defines how trust is established, expressed, and verified in TEA.

It applies to:

- TEA collections (release definitions)
- artefacts (e.g. SBOMs, attestations)
- digital signatures
- signing certificates
- DNS-based trust anchor publication (TEA-native)
- timestamp and transparency integration
- discovery integration

This document defines **security primitives and validation rules**.  
It does NOT define:

- TEA API structure (covered by OpenAPI specs)
- discovery document format (covered separately)
- evidence bundle structure (defined in TEA Evidence Bundle spec)

---

## 2. Trust Models

TEA supports two trust models.

### 2.1 TEA-Native (TAPS)

Characteristics:

- self-signed certificates
- identity derived from public key
- certificates published in DNS (CERT records)
- no CA hierarchy
- timestamps REQUIRED
- transparency REQUIRED

This model is designed for:

- long-term validation
- independence from external CAs
- CRA-aligned evidence preservation

---

### 2.2 WebPKI

Characteristics:

- certificates issued by public CA
- trust based on PKIX validation
- DNS MUST NOT be used for trust anchoring
- timestamps OPTIONAL (but RECOMMENDED)
- transparency OPTIONAL (policy dependent)

DNS MAY still be used for:

- policy signals (e.g. CAA)
- discovery

---

## 3. Identity Model

### 3.1 Canonical Identity

The identity of a signer is:

```text
SHA-256(public key)
```

This is the **only cryptographically relevant identity**.

---

### 3.2 DNS Encoding (TEA-Native)

The identity is encoded in DNS as:

```text
<fingerprint>.<trust-domain>
```

---

### 3.3 Identity Source

Identity MUST be derived exclusively from:

- the public key
- the fingerprint of that key

Identity MUST NOT be derived from:

- certificate subject fields
- DNS semantics beyond matching
- CA hierarchy

---

## 4. Certificate Profile

### 4.1 General

Certificates MUST:

- be X.509 (RFC 5280)
- be self-signed (TEA-native)
- be short-lived
- use Ed25519 (REQUIRED for TEA-native)

---

### 4.2 Subject

Subject fields are informational only:

- CN MUST NOT be present
- O MUST contain legal entity name (if applicable)
- OU OPTIONAL
- C SHOULD be present

Validation MUST NOT rely on subject values.

---

### 4.3 SAN (TEA-Native)

SAN DNS entries encode identity.

Required:

```text
<fingerprint>.<trust-domain>
```

Optional:

```text
<fingerprint>.<persistence-domain>
```

---

### 4.4 Constraints

- exactly one manufacturer SAN MUST be present
- at most one persistence SAN MAY be present
- fingerprint MUST match the public key
- no additional SAN entries are permitted

---

### 4.5 Validity

Certificates MUST:

- be short-lived (typically hours)
- not rely on revocation mechanisms

Long-term validity is achieved via:

- timestamps
- transparency evidence

---

## 5. DNS Publication

### 5.1 Requirement (TEA-Native)

Certificates MUST be published in DNS using CERT records.

---

### 5.2 Format

```text
<fingerprint>.<domain>. IN CERT PKIX 0 0 <base64-cert>
```

---

### 5.3 DNSSEC

- OPTIONAL
- if present → MUST be validated
- if absent → distribution is unauthenticated

---

### 5.4 WebPKI

DNS MUST NOT be used for trust anchoring.

DNS MAY be used for:

- policy enforcement (e.g. CAA)
- discovery

---

## 6. Signature Model

### 6.1 Types

- Detached signatures
- Inline signatures

---

### 6.2 Canonicalization

For JSON:

- RFC 8785 (JCS) MUST be used when canonicalization is required

---

### 6.3 Algorithms

- Ed25519 REQUIRED for TEA-native
- WebPKI follows PKIX ecosystem

---

### 6.4 Signature Semantics

A signature asserts:

> “This object was produced by the holder of this private key.”

---

## 7. Timestamp Model

### 7.1 Requirement (TEA-Native)

Timestamps MUST be used.

---

### 7.2 Binding Requirement

The timestamp MUST bind to the signature:

```text
messageImprint == hash(signature)
```

---

### 7.3 Purpose

Timestamps provide:

- proof of signing time
- validation after certificate expiration

---

## 8. Transparency Model

### 8.1 Requirement (TEA-Native)

Transparency evidence MUST be present.

Supported systems include:

- Sigsum
- Rekor
- SCITT (future)

---

### 8.2 Binding Requirement

Transparency evidence MUST bind to:

- the signature  
OR  
- the timestamped signature  

NOT:

- raw artifact hash alone

---

### 8.3 Role

Transparency provides:

- public auditability
- detection of hidden or backdated signatures

---

## 9. Multi-Anchor Trust Model

Trust is derived from independent components:

| Anchor | Role |
|------|------|
| Certificate | identity |
| Signature | integrity |
| Timestamp | time |
| DNS | distribution |
| Transparency | visibility |

No single component is sufficient.

---

## 10. Ephemeral Key Model

Private keys:

- MUST be ephemeral
- MUST NOT be stored after use

Lifecycle:

1. generate  
2. sign  
3. destroy  

---

## 11. Validation Model

Consumers MUST:

- verify signature
- validate certificate profile
- verify fingerprint matches identity

Consumers MUST (TEA-native):

- validate timestamp
- validate transparency
- verify binding between all evidence layers

Consumers SHOULD:

- validate DNS (if available)
- validate DNSSEC (if present)

---

## 12. Discovery

Discovery:

- provides service endpoints
- identifies publisher domain
- MAY include metadata

Discovery MUST NOT:

- establish trust
- override signature validation

---

## 13. CI/CD Alignment

CI/CD systems:

- MUST use ephemeral keys
- MUST NOT publish DNS records
- MUST NOT perform final release commit

Publication MUST require:

- human approval
- strong authentication (e.g. MFA)

---

## 14. Security Properties

### 14.1 No Long-Term Key Risk

- no long-lived signing keys
- no revocation dependency

---

### 14.2 DNS Independence

- validation does not depend on DNS availability
- DNS is used for distribution, not validation

---

### 14.3 Multi-Anchor Resilience

- compromise of one component does not break trust

---

## 15. Final Rules

- identity = public key
- SAN DNS names MUST encode fingerprint
- private keys MUST be ephemeral
- timestamps MUST bind to signature
- transparency MUST bind to signature or timestamped signature
- TEA-native MUST use DNS CERT records
- WebPKI MUST NOT use DNS for trust anchoring