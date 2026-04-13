# 📘 TEA Trust Architecture — Compliance Documents
**Version:** 1.0  
**Status:** Early Draft (Normative, Trust Architecture Overlay)

---

## Status

This document defines how **publisher-scoped compliance documents** are handled in the **TEA Trust Architecture**.

It extends the core TEA compliance document model by defining:

- how compliance documents are represented as trustable objects
- how evidence bundles apply to compliance documents
- what compliance document validation does and does not prove
- how compliance documents are retrieved and validated independently of product releases

This document is intended to be used together with:

- `tea-core/compliance-documents.md`
- `tea-core/artifact.md`
- `spec/trust-architecture.md`
- `spec/evidence-bundle.md`
- `spec/evidence-validation.md`
- `profiles/x509-profile.md`

The key words **MUST**, **MUST NOT**, **SHOULD**, and **MAY** are to be interpreted as described in:

- RFC 2119
- RFC 8174

---

## Table of Contents

1. [Introduction](#1-introduction)  
2. [Scope and Design Principles](#2-scope-and-design-principles)  
3. [Compliance Documents as Trust Objects](#3-compliance-documents-as-trust-objects)  
4. [Publisher Scope and Non-Relationship to Products](#4-publisher-scope-and-non-relationship-to-products)  
5. [Evidence Bundle Model](#5-evidence-bundle-model)  
6. [Binding Rules](#6-binding-rules)  
7. [Retrieval and API Model](#7-retrieval-and-api-model)  
8. [Validation Semantics](#8-validation-semantics)  
9. [What Validation Proves and Does Not Prove](#9-what-validation-proves-and-does-not-prove)  
10. [Transparency Requirements](#10-transparency-requirements)  
11. [Operational Guidance](#11-operational-guidance)  
12. [Security Considerations](#12-security-considerations)  
13. [Normative References](#13-normative-references)  
14. [Informative References](#14-informative-references)  

---

## 1. Introduction

Core TEA defines compliance documents as **publisher-scoped resources**. They belong to the authority that controls the TEA domain, such as:

- a manufacturer
- an organization
- an open source project

They do **not** belong to:

- a specific product
- a specific product release
- a collection

The TEA Trust Architecture adds security and long-term verifiability to those documents.

The central design choice of this document is:

> A compliance document is handled as a standalone TEA artifact for trust purposes.

This means TEA does not introduce a separate cryptographic model for compliance documents. Instead, it reuses the same evidence model already used for other trustable TEA objects.

---

## 2. Scope and Design Principles

### 2.1 Scope

This specification applies to compliance documents that are exposed through TEA APIs and that a publisher wants to make verifiable over time.

### 2.2 Design principles

The design follows these principles:

1. **No separate trust mechanism for compliance documents**
2. **Reuse of the artifact and evidence bundle model**
3. **Publisher scope remains intact**
4. **Validation proves integrity, origin, and time — not legal truth**
5. **Compliance documents remain outside product collections**

### 2.3 Consequence

A compliance document may be distributed as:

- a standalone artifact only
- an artifact with detached signature
- an artifact with an evidence bundle

In TEA Trust Architecture mode, the preferred model is:

> compliance document artifact + evidence bundle

---

## 3. Compliance Documents as Trust Objects

A compliance document becomes a trust object when it is represented as an immutable artifact and associated with an evidence bundle.

Examples include:

- a PDF certificate
- a declaration of conformity
- a JSON policy statement
- a machine-readable compliance statement

For trust purposes, TEA treats the compliance document as:

```text
artifact bytes + evidence bundle
```

This gives the same core security properties as for other TEA artifacts:

- integrity
- origin authentication
- proof of existence in time
- optional transparency visibility

---

## 4. Publisher Scope and Non-Relationship to Products

This document does not change the core TEA scope rule:

> Compliance documents are publisher-scoped, not product-scoped.

Therefore:

- compliance documents MUST NOT be embedded into product collections as if they were release artifacts
- compliance documents MUST NOT be treated as evidence about a specific product release unless a separate, explicit application-layer policy says so
- a valid compliance document MUST NOT be interpreted as automatically applying to every product published by the same authority

This is a critical semantic boundary.

A compliance document may describe the publisher’s organizational status or certification posture, but TEA trust validation only proves that the document itself was published and protected according to the TEA trust architecture.

---

## 5. Evidence Bundle Model

### 5.1 Preferred model

A compliance document SHOULD use the same evidence bundle model as a standalone artifact.

The evidence bundle SHOULD contain:

- signature
- certificate
- timestamp
- transparency evidence
- any additional validation material required by the active TEA trust profile

### 5.2 Required model for TEA Trust Architecture compliance

If a compliance document is claimed to be handled under the TEA Trust Architecture, it MUST be distributable with an evidence bundle.

### 5.3 Detached model

A compliance document MAY also be made available with:

- detached signature only

However, detached signature alone is not sufficient for TEA Trust Architecture–grade long-term validation.

### 5.4 Recommended packaging model

The recommended retrieval forms are:

1. compliance document artifact only
2. compliance document artifact + detached signature
3. compliance document artifact + evidence bundle

The third form is the preferred form for trust-aware validation.

---

## 6. Binding Rules

### 6.1 Artifact binding

The signature MUST bind to the exact bytes of the compliance document artifact.

### 6.2 Timestamp binding

The timestamp MUST bind to the signature.

For RFC 3161 timestamps, this means:

```text
messageImprint = SHA-256(signature)
```

### 6.3 Transparency binding

Transparency evidence MUST bind to:

- the signature, or
- the timestamped signature

### 6.4 Evidence bundle integrity

If the evidence bundle is externally referenced, any referencing metadata MUST protect it using the normal TEA external-evidence rules, including canonical JSON digest rules where applicable.

### 6.5 No semantic binding claim

The evidence bundle proves the integrity and publication of the compliance document artifact itself.

It does **not** cryptographically prove that the claims written in the document are substantively true.

---

## 7. Retrieval and API Model

### 7.1 Publisher-scoped retrieval

Compliance documents are retrieved through publisher-scoped API resources, not through product collections.

Conceptually:

```text
GET /compliance-documents
GET /compliance-documents/{type}
```

### 7.2 Delivery modes

A TEA implementation SHOULD support these delivery modes:

#### Compliance document only

```text
application/pdf
application/json
application/xml
application/octet-stream
```

depending on the document format.

#### Compliance document + detached signature

```text
multipart/*
```

#### Compliance document + evidence bundle

```text
multipart/*
```

### 7.3 Evidence-friendly retrieval

A TEA trust-aware implementation SHOULD make it easy for a consumer to retrieve both:

- the compliance document artifact
- the evidence bundle required to validate it

---

## 8. Validation Semantics

### 8.1 Core validation steps

Validation of a compliance document under the TEA Trust Architecture follows the same pattern as standalone artifact validation:

1. retrieve the compliance document artifact
2. retrieve the associated evidence bundle
3. verify the artifact digest or direct signature target bytes
4. verify the signature
5. verify the certificate according to the active profile
6. verify the timestamp
7. verify required transparency evidence
8. apply local policy

### 8.2 Reuse of generic validation

TEA implementations SHOULD reuse the generic evidence validation logic for compliance documents rather than defining a separate validator.

### 8.3 Policy layer

After cryptographic validation succeeds, a consumer MAY apply policy regarding:

- whether the document type is relevant
- whether the issuer is expected
- whether the document is still operationally valid
- whether the document should be accepted for a given business process

Those policy decisions are outside the cryptographic core.

---

## 9. What Validation Proves and Does Not Prove

### 9.1 Validation proves

A successful TEA trust validation of a compliance document proves that:

- the artifact bytes have not been modified
- the document was signed by the corresponding private key
- the signature existed at the proven time
- required transparency evidence exists, if policy requires it

### 9.2 Validation does not prove

A successful validation does **not** prove that:

- the compliance claim is legally valid
- the certification remains current in a business or regulatory sense
- the document applies to a particular product
- the issuing organization is competent or accredited
- the contents are factually correct

This distinction is essential.

### 9.3 Plain-language interpretation

The strongest correct statement is:

> This exact compliance document artifact was published by this publisher-side signing context, existed at the validated time, and its evidence chain is intact.

It is **not** correct to conclude:

> Therefore the compliance claim is true.

---

## 10. Transparency Requirements

### 10.1 Same transparency model as other TEA trust objects

If a compliance document is handled under the TEA Trust Architecture, transparency requirements are the same as for other evidence-bundle-backed objects.

### 10.2 Current requirement

At least one transparency receipt from:

- Sigsum, or
- Rekor

MUST be included if the implementation claims TEA Trust Architecture compliance for the compliance document workflow.

### 10.3 Consumer capability

Consumer-side and third-party TEA services that validate compliance documents under the TEA Trust Architecture MUST support validation of both:

- Sigsum
- Rekor

SCITT MAY be supported in addition when relevant, but it is not the baseline requirement.

---

## 11. Operational Guidance

### 11.1 Recommended storage model

A TEA implementation SHOULD store:

- the compliance document artifact
- the evidence bundle
- the artifact digest
- compliance document metadata such as type

### 11.2 Metadata fields

A TEA implementation MAY also expose informational metadata such as:

- issuedBy
- issuedAt
- validUntil
- issuingBody
- reference number

Such fields are useful for operations, but they are not substitutes for evidence validation.

### 11.3 Expiry vs cryptographic validity

A compliance document may remain cryptographically valid even when its business or regulatory validity has expired.

Implementations SHOULD keep these concepts separate:

- cryptographic validity
- operational validity
- legal validity

---

## 12. Security Considerations

### 12.1 Scope confusion

The largest risk is semantic overreach.

Implementations and consumers MUST avoid interpreting a valid compliance document as proof that:

- every product of the authority is compliant
- a specific release is covered
- the document’s claims are legally or technically true

### 12.2 Artifact substitution

Compliance documents are vulnerable to the same artifact substitution risks as other TEA artifacts. This is mitigated by:

- digest verification
- signature verification
- evidence bundle validation

### 12.3 Long-term persistence

If compliance documents are expected to be auditable over long periods, the corresponding evidence bundles SHOULD be preserved just like other important TEA trust artifacts.

### 12.4 Separate publisher scope

Keeping compliance documents outside collections is an important security and semantics control. It prevents accidental product-level trust conclusions from organization-level documents.

---

## 13. Normative References

- RFC 2119 — Key words for use in RFCs to Indicate Requirement Levels
- RFC 8174 — Ambiguity of Uppercase vs Lowercase in RFC 2119 Key Words
- RFC 3161 — Time-Stamp Protocol
- RFC 5280 — Internet X.509 Public Key Infrastructure Certificate and CRL Profile
- RFC 8785 — JSON Canonicalization Scheme

---

## 14. Informative References

- `tea-core/compliance-documents.md`
- `tea-core/artifact.md`
- `spec/trust-architecture.md`
- `spec/evidence-bundle.md`
- `spec/evidence-validation.md`
- `profiles/x509-profile.md`

---