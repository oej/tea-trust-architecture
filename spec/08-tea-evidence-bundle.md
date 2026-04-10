# 📘 TEA Evidence Bundle Specification
**Version:** 1.1  
**Status:** Draft (Implementation-Ready)

---

## 1. Introduction

The TEA Evidence Bundle defines how cryptographic evidence associated with a signed object is:

- packaged  
- transported  
- validated  

It is a **core component of the TEA trust architecture**.

The bundle enables:

- long-term validation of TEA artefacts  
- offline verification  
- interoperability between TEA implementations  
- resilience when keys, certificates, or external services are no longer available  

---

## 2. Role in TEA Architecture

The TEA trust architecture separates:

- identity  
- integrity  
- time  
- visibility  
- authorization  

The Evidence Bundle is the mechanism that **binds these together** for validation.

> The bundle does not create trust — it preserves verifiable evidence.

---

## 3. Purpose

Modern supply chain security uses:

- short-lived keys  
- short-lived certificates  
- distributed trust anchors  

This introduces a fundamental challenge:

> How can a verifier validate a signature years later?

The TEA Evidence Bundle answers this by preserving:

- what was signed  
- who signed it (via certificate)  
- when it was signed (timestamp)  
- that it was publicly visible (transparency)  

---

## 4. Scope

A TEA Evidence Bundle applies to **exactly one signed TEA object**.

Examples:

- TEA collection (release definition)  
- TEA artefact (e.g., SBOM)  
- discovery document  
- DSSE attestation  

A TEA release typically contains multiple bundles:

- one per TEA collection  
- one per TEA artefact  
- one per attestation  

---

## 5. Core Design Principles

### 5.1 One Bundle Per Object

Each bundle corresponds to exactly one signed object.

**Rationale**

- avoids ambiguity  
- simplifies validation  
- ensures deterministic verification  

---

### 5.2 Detached but Bound

The bundle does NOT replace the original object.

- TEA storage → authoritative object  
- bundle → validation evidence  

**Rationale**

Separation allows:

- independent storage  
- independent transport  
- reuse of evidence  

---

### 5.3 Offline Validation

Bundles SHOULD contain enough information to validate without:

- contacting a TSA  
- contacting transparency systems  
- retrieving certificates externally  

**Rationale**

Long-term validation must not depend on:

- availability of services  
- persistence of infrastructure  

---

### 5.4 No Implicit Trust

The bundle itself does NOT establish trust.

A verifier MUST apply policy to determine:

- which certificates are trusted  
- which TSAs are trusted  
- which transparency systems are trusted  

---

## 6. Validation Model

The bundle supports the following validation chain:

```text
TEA object → signature → certificate → timestamp → transparency
```

Each layer MUST refer to the **same cryptographic object**.

---

## 7. Bundle Structure

```json
{
  "bundleVersion": "1.0",
  "object": { ... },
  "signature": { ... },
  "certificate": { ... },
  "timestamps": [ ... ],
  "transparency": [ ... ],
  "validationMaterial": { ... }
}
```

---

## 8. Object

Describes the signed TEA object.

```json
{
  "objectType": "tea-collection",
  "objectId": "collection-123",
  "digest": {
    "algorithm": "sha-256",
    "value": "BASE64URL..."
  }
}
```

### Requirements

- digest MUST match the exact bytes used for signing  
- objectType SHOULD be explicit  

---

## 9. Signature

```json
{
  "format": "jws-detached",
  "algorithm": "EdDSA",
  "value": "BASE64URL...",
  "signatureDigest": {
    "algorithm": "sha-256",
    "value": "BASE64URL..."
  }
}
```

### Why `signatureDigest` Exists

It enables:

- timestamp binding  
- transparency binding  

---

### Critical Principle

> All external evidence binds to the signature — not directly to the object.

---

## 10. Certificate

```json
{
  "format": "x509-pem",
  "certificate": "-----BEGIN CERTIFICATE----- ...",
  "chain": [ ... ]
}
```

### Requirements

- MUST be the signing certificate  
- MUST follow TEA certificate profile  
- MAY include chain (WebPKI)  

---

## 11. Timestamps

```json
[
  {
    "format": "rfc3161",
    "token": "BASE64...",
    "messageImprint": {
      "algorithm": "sha-256",
      "value": "..."
    }
  }
]
```

---

### 11.1 What a Timestamp Means

A timestamp (RFC 3161) is a **signed assertion by a Timestamp Authority (TSA)** that:

> A specific hash existed at a specific time.

---

### 11.2 What Is Being Timestamped

In TEA:

```text
messageImprint == hash(signature)
```

---

### 11.3 Why This Matters

Certificates are short-lived.

The timestamp proves:

> The signature existed while the certificate was valid.

---

### 11.4 Trust Model

A verifier MUST:

- validate TSA signature  
- trust TSA certificate (via trust store)  
- verify messageImprint  

---

## 12. Transparency Evidence

### 12.1 What Transparency Provides

Transparency logs provide:

- existence proof  
- ordering  
- auditability  

They DO NOT prevent attacks.

They enable:

> detection, attribution, and response

---

### 12.2 Multi-System Model

Supported systems:

- Rekor  
- Sigsum  
- SCITT  

---

### 12.3 Common Structure

```json
{
  "system": "rekor",
  "binding": {
    "type": "signature",
    "digest": {
      "algorithm": "sha-256",
      "value": "..."
    }
  },
  "verification": { ... }
}
```

---

### 12.4 Binding Rule (Normative)

Transparency MUST bind to:

- signature  
OR  
- timestamped signature  

MUST NOT bind to:

- raw artefact digest  

---

### Rationale

Binding to signature ensures:

- alignment with timestamp  
- consistent identity  
- resistance to substitution  

---

## 13. Validation Material

Optional but recommended:

- TSA certificates  
- transparency public keys  
- certificate digests  

---

## 14. Binding Rules (Normative)

A verifier MUST validate:

### 14.1 Object → Signature
Signature verifies against object.

### 14.2 Signature → Timestamp
Timestamp binds to signature.

### 14.3 Signature → Transparency
Transparency binds to signature.

### 14.4 Certificate → Signature
Certificate validates signature.

---

## 15. Short-Lived Certificate Model

TEA assumes:

- ephemeral keys  
- certificates ≤ 1 hour  

The bundle compensates by preserving:

- timestamp (time proof)  
- transparency (visibility proof)  

---

## 16. Profiles

### Minimal
- signature  
- certificate  

### TEA with the Trust Architecture
- timestamp REQUIRED  
- transparency SHOULD be present  

### High Assurance
- multiple TSAs  
- multiple transparency systems  

---

## 17. Validation Procedure

1. verify object digest  
2. verify signature  
3. validate certificate  
4. validate timestamp  
5. verify timestamp binding  
6. validate transparency  
7. verify transparency binding  
8. apply trust policy  

---

## 18. Error Handling

Validation MUST fail if:

- binding mismatch  
- invalid signature  
- invalid timestamp  
- invalid transparency evidence  

---

## 19. Extensibility

Unknown fields MUST be ignored.

Future formats MAY include:

- CBOR  
- COSE  
- SCITT-native receipts  

---

## 20. Key Architectural Principle

> All evidence layers MUST refer to the same cryptographic object (the signature).

---

## 21. Final Statement

The TEA Evidence Bundle enables:

- short-lived keys  
- long-term validation  
- offline verification  
- multi-system transparency  

It transforms:

> ephemeral trust signals  
into  
> durable, verifiable evidence
