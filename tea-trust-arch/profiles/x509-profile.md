# 📘 TEA Trust Architecture — X.509 Certificate Profile
**Version:** 1.0  
**Status:** Draft (Normative, Implementation-Ready)

---

## Status

This document defines the **X.509 certificate profile** used by the TEA Trust Architecture.

It specifies how certificates are used to bind short-lived public keys to TEA signing operations, DNS publication, and long-term validation evidence.

This specification is intended to be used together with:

- the TEA Trust Architecture core specification
- the TEA Evidence Bundle specification
- the TEA Evidence Validation specification
- the TEA Discovery specification
- the TEA Conformance specification
- the Sigsum profile, when Sigsum transparency is used

The key words **MUST**, **MUST NOT**, **SHOULD**, and **MAY** are to be interpreted as described in:

- RFC 2119
- RFC 8174

---

## Table of Contents

1. [Purpose](#1-purpose)  
2. [Scope](#2-scope)  
3. [Design Principles](#3-design-principles)  
4. [Identity Model](#4-identity-model)  
5. [Terminology Clarification](#5-terminology-clarification)  
6. [Certificate Roles](#6-certificate-roles)  
7. [General Profile Requirements](#7-general-profile-requirements)  
8. [Subject Name Requirements](#8-subject-name-requirements)  
9. [SAN Requirements](#9-san-requirements)  
10. [Key Usage and Extensions](#10-key-usage-and-extensions)  
11. [Algorithm Requirements](#11-algorithm-requirements)  
12. [Validity Period](#12-validity-period)  
13. [Key Reuse Prohibition](#13-key-reuse-prohibition)  
14. [Encoding and Publication](#14-encoding-and-publication)  
15. [Validation Rules](#15-validation-rules)  
16. [DNS and Policy Considerations](#16-dns-and-policy-considerations)  
17. [Alignment with Sigsum Usage](#17-alignment-with-sigsum-usage)  
18. [Security Considerations](#18-security-considerations)  
19. [Examples](#19-examples)  
20. [Normative References](#20-normative-references)  
21. [Informative References](#21-informative-references)  
22. [Final Statement](#22-final-statement)  

---

## 1. Purpose

This document defines how X.509 certificates are used in the TEA Trust Architecture.

The profile is designed to support:

- short-lived signing certificates
- ephemeral signing keys
- deterministic validation behavior
- DNS-based publication in TEA-native deployments
- long-term validation using timestamps and optional transparency evidence

This profile does **not** use certificate subject naming as the source of trust identity.

---

## 2. Scope

This profile applies to X.509 certificates containing public keys used for:

- TEA artifact signing
- TEA collection signing
- discovery signing
- publication of TEA-native trust anchors in DNS

This profile applies to:

- **TEA-native trust model**
- **WebPKI trust model with TEA trust overlay**

It does not redefine general PKIX behavior beyond what is necessary for TEA.

---

## 3. Design Principles

The TEA X.509 profile is based on the following principles:

1. **The public key is the identity**
2. **The private key performs signing**
3. **The certificate is a short-lived validity wrapper**
4. **Trust must not depend on long-lived private keys**
5. **Evidence, not certificate longevity, provides long-term trust**
6. **Key reuse is forbidden**
7. **DNS provides publication and policy context, not universal trust by itself**
8. **Ed25519-only simplifies interoperability and aligns with Sigsum usage**

---

## 4. Identity Model

In TEA:

> **The public key is the identity.**

The certificate provides:

- a validity interval
- a standard container format
- accountability metadata
- a DNS-linked expression of key identity through SAN

The trust identity is derived from:

```text
SHA-256(public key)
```

The fingerprint-derived identity is then expressed in DNS SAN form.

The certificate subject is **not** the trust identity.

---

## 5. Terminology Clarification

In this specification:

- signing is performed using the **private key** of a key pair
- the certificate contains the corresponding **public key**
- the certificate does **not** perform cryptographic operations

All references such as:

> “certificate used for signing”

MUST be interpreted as:

> “certificate containing the public key corresponding to the private key used for signing”

---

## 6. Certificate Roles

Certificates are used to bind a public key to TEA signing operations for:

- TEA artifact signing
- TEA collection signing
- discovery signing

In TEA-native mode, certificates are also published in DNS as trust-anchor distribution objects.

The same certificate profile applies across these roles.

---

## 7. General Profile Requirements

Certificates MUST:

- be X.509 version 3
- conform to RFC 5280 unless this profile states otherwise
- contain an Ed25519 public key
- be short-lived
- contain SAN DNS entries as defined by this profile
- contain no unrelated identities

Certificates MUST NOT:

- rely on Common Name for trust identity
- encode multiple unrelated key identities
- be reused across different signing events or release contexts

---

## 8. Subject Name Requirements

The subject field is used for accountability metadata, not trust identity.

The subject MAY include:

- `O` (organization)
- `OU` (organizational unit)
- `C` (country)

If a legal entity exists, `O` SHOULD contain the legal name of that entity.

The subject MUST NOT be used as a trust anchor or identity source.

The `CN` field:

- SHOULD NOT be used
- MUST be ignored by consumers for trust decisions

---

## 9. SAN Requirements

### 9.1 Primary SAN

Certificates MUST contain exactly one **primary SAN DNS entry**.

The primary SAN:

- MUST be under the manufacturer-controlled domain
- MUST encode the fingerprint-derived identity

Example:

```text
<fingerprint>.tea.example.com
```

### 9.2 Optional Secondary SAN

Certificates MAY include one **secondary SAN DNS entry** for continuity or long-term access.

The secondary SAN:

- MUST encode the same fingerprint-derived identity
- MAY be under:
  - the manufacturer-controlled domain, or
  - an independent domain

If the secondary SAN is under the same organization’s control, it SHOULD use:

- a separate domain or subdomain, and
- separate infrastructure or operational control boundaries

Examples:

```text
<fingerprint>.backup.example.net
<fingerprint>.longterm.example.com
```

### 9.3 Constraints

The following constraints apply:

- maximum of two SAN DNS entries
- exactly one primary SAN
- at most one secondary SAN
- both SAN entries MUST refer to the same public key identity

### 9.4 Rationale

The optional secondary SAN provides resilience against:

- infrastructure loss
- DNS migration
- organizational restructuring
- long-term access failures

---

## 10. Key Usage and Extensions

Certificates MUST include:

- `digitalSignature` in Key Usage

No other key usages are required by this profile.

Extended Key Usage is not required by this profile.

If Extended Key Usage is present, it MUST NOT contradict the certificate’s intended signing use.

Unnecessary or misleading extensions SHOULD NOT be included.

---

## 11. Algorithm Requirements

### 11.1 Allowed Public Key Algorithm

Certificates MUST contain an:

```text
Ed25519
```

public key.

No other public key algorithm is permitted in this version of the specification.

### 11.2 Signature Algorithm Rationale

Ed25519 is mandated because it provides:

- a compact key and signature format
- widespread modern library support
- deterministic interoperability
- compatibility with Sigsum’s key model
- reduced implementation complexity
- reduced downgrade ambiguity

### 11.3 Hash Function for Identity Derivation

The fingerprint used for identity derivation and SAN construction MUST be:

```text
SHA-256(public key)
```

No other digest algorithm is permitted for this purpose in this version of the specification.

---

## 12. Validity Period

Certificates MUST have a lifetime of:

```text
less than or equal to 1 hour
```

Shorter lifetimes are encouraged where operationally feasible.

### 12.1 Rationale

This requirement:

- minimizes exposure from key compromise
- eliminates practical dependence on revocation
- reinforces the ephemeral signing model
- shifts long-term trust to timestamps and preserved evidence

---

## 13. Key Reuse Prohibition

### 13.1 Requirement

A key pair MUST be single-use.

This means:

- the private key MUST be used only for a single signing event or release context
- the public key MUST NOT appear in multiple certificates over time
- the same key pair MUST NOT be reintroduced later in a new certificate

### 13.2 Fingerprint Uniqueness

The fingerprint:

```text
SHA-256(public key)
```

MUST be treated as a unique identifier for a single signing event.

Previously used fingerprints MUST NOT be reused.

### 13.3 Publication API Enforcement

Implementations of the Publication API MUST:

- retain a record of previously used public key fingerprints
- reject any attempt to publish or commit a new certificate with a known fingerprint
- perform this check before commit and before any TEA-native DNS trust-anchor publication

### 13.4 Rationale

This requirement prevents:

- replay of old signing identities
- ambiguity in transparency evidence
- confusion about key lifecycle
- erosion of the ephemeral-key security model

---

## 14. Encoding and Publication

Certificates MUST be encoded in DER.

### 14.1 TEA-native Publication

In TEA-native mode, certificates MUST be published in DNS using:

- CERT records, as specified for certificate storage in DNS

DNS publication is a trust-anchor distribution mechanism in TEA-native deployments.

### 14.2 WebPKI

In WebPKI mode, certificates follow standard CA issuance and PKIX validation rules.

The TEA Trust Architecture does not alter the underlying CA issuance model, but overlays it with TEA evidence requirements.

---

## 15. Validation Rules

Consumers and validators MUST:

- validate certificate structure according to RFC 5280
- validate the certificate validity interval
- verify that the public key in the certificate corresponds to the private key used to generate the signature
- verify SAN constraints according to this profile
- ignore Common Name for trust identity
- enforce Ed25519-only acceptance
- enforce key reuse prohibition where the implementation has publication or ecosystem history knowledge

Consumers MUST NOT rely solely on certificate validity for long-term trust.

Long-term trust requires:

- timestamp validation
- evidence validation
- optional transparency validation according to policy

---

## 16. DNS and Policy Considerations

### 16.1 TEA-native

In TEA-native mode:

- DNS is used as a trust-anchor distribution mechanism
- DNS publication is REQUIRED
- DNSSEC is OPTIONAL but RECOMMENDED

DNSSEC strengthens trust-anchor distribution by providing authenticated DNS responses.

### 16.2 WebPKI

In WebPKI mode:

- DNS is **not** a TEA trust anchor
- DNS remains relevant for policy through **CAA records**
- DNSSEC strengthens the reliability of CAA evaluation when present

This distinction is important:

> In WebPKI mode, DNS supports issuance policy, but does not replace PKIX trust anchoring.

### 16.3 CAA

Implementations using WebPKI SHOULD evaluate:

- Certification Authority Authorization (CAA) records

as part of issuance-policy enforcement where applicable.

---

## 17. Alignment with Sigsum Usage

Sigsum is optional in the TEA ecosystem, but this certificate profile is intentionally aligned with Sigsum usage.

### 17.1 Conditional Requirement

When Sigsum transparency is used:

- the same Ed25519 key pair used for TEA signing MUST be the key identity represented in the Sigsum transparency evidence
- the certificate MUST contain the public key corresponding to that signing key

### 17.2 Why this alignment matters

This provides:

- a single cryptographic identity across signing and transparency
- simpler binding validation
- reduced ambiguity in evidence interpretation

### 17.3 Transparency independence

This profile does **not** require Sigsum.

Other transparency systems, such as:

- Rekor
- SCITT

remain allowed by the TEA Trust Architecture.

However, this certificate profile is constrained to Ed25519 so that Sigsum usage is always compatible when selected.

---

## 18. Security Considerations

This profile improves security by:

- limiting certificate lifetime
- forbidding key reuse
- removing algorithm ambiguity
- separating trust identity from subject naming
- enabling DNS-backed publication in TEA-native mode
- supporting policy reinforcement through CAA in WebPKI mode

The profile intentionally trades flexibility for clarity and deterministic behavior.

That trade-off is acceptable because TEA prioritizes:

- verifiability
- interoperability
- long-term auditability

over broad algorithm agility.

---

## 19. Examples

### 19.1 Primary SAN only

```text
ab12cd34ef56.tea.example.com
```

### 19.2 Primary and secondary SAN

```text
Primary:   ab12cd34ef56.tea.example.com
Secondary: ab12cd34ef56.backup.example.net
```

### 19.3 Identity derivation

```text
fingerprint = SHA-256(public key)
SAN        = <fingerprint>.<domain>
```

---

## 20. Normative References

- RFC 2119 — Key words for use in RFCs to Indicate Requirement Levels
- RFC 8174 — Ambiguity of Uppercase vs Lowercase in RFC 2119 Key Words
- RFC 5280 — Internet X.509 Public Key Infrastructure Certificate and CRL Profile
- RFC 8032 — Edwards-Curve Digital Signature Algorithm (EdDSA)
- RFC 8410 — Algorithm Identifiers for Ed25519, Ed448, X25519, and X448 for Use in the Internet X.509 Public Key Infrastructure
- RFC 6234 — US Secure Hash Algorithms (SHA and SHA-based HMAC and HKDF)
- RFC 4033 — DNS Security Introduction and Requirements
- RFC 4034 — Resource Records for the DNS Security Extensions
- RFC 4035 — Protocol Modifications for the DNS Security Extensions
- RFC 4398 — Storing Certificates in the Domain Name System (DNS)
- RFC 8659 — DNS Certification Authority Authorization (CAA) Resource Record

---

## 21. Informative References

- TEA Trust Architecture Core Specification
- TEA Evidence Bundle Specification
- TEA Evidence Validation Specification
- TEA Discovery Specification
- TEA Conformance Specification
- TEA Sigsum Profile
- Sigsum Project Documentation
- Rekor Project Documentation
- IETF SCITT Working Group Materials

---

## 22. Final Statement

This profile enforces a clear and deterministic model:

- one algorithm
- one key identity
- one short-lived certificate
- one signing event
- evidence-based long-term trust

### Key Principle

> One key, one identity, one moment in time — preserved through verifiable evidence.
