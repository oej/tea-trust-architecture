# 📘 TEA Collection Specification
**Version:** 1.0  
**Status:** Draft (Normative, Implementation-Ready)

---

## Status

This document defines the **TEA collection** object and explains how it is used in:

- **base TEA**
- **TEA with the Trust Architecture**

This specification is intended to be read together with:

- the TEA core OpenAPI specification
- the TEA Evidence Bundle specification
- the TEA Evidence Validation specification
- the TEA X.509 profile
- the TEA conformance specification

The key words **MUST**, **SHOULD**, and **MAY** are to be interpreted as described in:

- RFC 2119
- RFC 8174

This document is deliberately more explanatory than some of the other TEA specifications because the TEA collection sits at the boundary between:

- release modeling
- publisher workflow
- trust validation
- API interoperability

A reader needs to understand not only **what fields exist**, but also **what a collection means** and **what it does not mean**.

---

## Table of Contents

1. [Introduction](#1-introduction)  
2. [What a TEA Collection Is](#2-what-a-tea-collection-is)  
3. [What a TEA Collection Is Not](#3-what-a-tea-collection-is-not)  
4. [Base TEA vs TEA Trust Architecture](#4-base-tea-vs-tea-trust-architecture)  
5. [Core Collection Semantics](#5-core-collection-semantics)  
6. [Artifact References](#6-artifact-references)  
7. [Signatures, Detached Signatures, and Evidence Bundles](#7-signatures-detached-signatures-and-evidence-bundles)  
8. [Digest Rules](#8-digest-rules)  
9. [Canonicalization Rules](#9-canonicalization-rules)  
10. [Validation Semantics](#10-validation-semantics)  
11. [Reuse Rules](#11-reuse-rules)  
12. [Collection Versioning](#12-collection-versioning)  
13. [OpenAPI Impact and Required Changes](#13-openapi-impact-and-required-changes)  
14. [Recommended Data Model Shape](#14-recommended-data-model-shape)  
15. [Normative Requirements](#15-normative-requirements)  
16. [Error Conditions](#16-error-conditions)  
17. [Security Considerations](#17-security-considerations)  
18. [Normative References](#18-normative-references)  
19. [Informative References](#19-informative-references)  
20. [Final Statement](#20-final-statement)  

---

## 1. Introduction

A **TEA collection** is the authoritative publisher statement describing a release context.

At its core, a collection answers the question:

> **Which TEA artifacts belong to this release statement?**

A collection is important because TEA separates two ideas that are often confused in software supply-chain systems:

- **artifact authenticity**
- **release inclusion**

These are not the same thing.

An artifact may be authentic on its own and still not belong to a particular release.  
A collection may correctly list an artifact as part of a release even if the artifact itself is not independently signed.

Because of that, the collection has a distinct role in TEA:

- it is the **release statement**
- it binds artifacts to a release using digests
- it is versioned independently
- it may evolve over time even when artifact bytes do not change

In TEA with the Trust Architecture, the collection is still the release statement, but the trust model becomes stricter and more explicit.

---

## 2. What a TEA Collection Is

A TEA collection is a structured object that describes:

- release identity
- release metadata
- the set of referenced TEA artifacts
- the digests of those artifacts
- optional references to signatures and evidence material

The collection is the publisher’s statement that:

> these exact artifact bytes belong to this collection version and its release context

The most important security property of the collection is that it binds artifact bytes to release meaning.

That binding is achieved through:

- artifact references
- artifact digests
- collection signing, when present
- collection evidence, in TEA with the Trust Architecture

---

## 3. What a TEA Collection Is Not

A TEA collection is **not**:

- the artifact itself
- the artifact’s signature
- the artifact’s evidence bundle
- the transparency log
- the trust anchor

A collection does **not by itself** prove that an artifact is independently authentic.

That point is important enough to state plainly:

> A collection tells you that a publisher says an artifact belongs to a release.  
> It does not by itself prove that the artifact was independently signed or timestamped.

That proof, when required, comes from the artifact’s own evidence bundle.

Likewise, a collection is not a substitute for the TEA trust architecture.  
It is a core TEA object that can exist in both:

- base TEA
- TEA with the Trust Architecture

---

## 4. Base TEA vs TEA Trust Architecture

This specification must be read with a clear distinction between the two layers.

### 4.1 Base TEA

In base TEA, a collection provides:

- structured release description
- artifact references
- digests for binding exact bytes
- optional detached signatures or similar implementation-specific integrity material

Base TEA does **not** require:

- evidence bundles
- timestamps
- transparency
- X.509 profile compliance
- TEA-native DNS publication
- any specific trust model

Base TEA therefore allows lighter-weight deployments and compatibility with existing ecosystems.

### 4.2 TEA with the Trust Architecture

In TEA with the Trust Architecture, the collection remains the release statement, but additional trust requirements apply.

In that mode:

- the collection itself SHOULD have trust evidence
- artifacts in the collection MUST be validated through evidence bundles where required by profile
- timestamps become required by the trust model
- transparency may be required depending on profile
- certificate and signature rules become constrained by the trust architecture

Most importantly, TEA with the Trust Architecture introduces the principle that:

> **The evidence bundle is the primary trust object for an artifact.**

That means the collection still binds artifacts to a release, but the artifact’s authenticity and long-term verifiability come from the evidence bundle.

### 4.3 Why this separation matters

If this distinction is not kept clear, implementers will tend to make one of two mistakes:

- treating the collection as if it proves artifact authenticity
- forcing trust-architecture concepts into base TEA where they are supposed to remain optional

This specification avoids both mistakes by making the layering explicit.

---

## 5. Core Collection Semantics

A collection has three central semantics.

### 5.1 Release statement

A collection is the publisher’s statement about a release context.

### 5.2 Integrity map

A collection contains digests of artifacts and therefore acts as an integrity map for the listed objects.

### 5.3 Versioned meaning

A collection version may change without changing artifact bytes.

This is expected and legitimate. Examples include:

- updated lifecycle information
- corrected metadata
- updated references
- revised explanatory text
- new trust evidence references

That means:

> collection version is not the same thing as software version

This distinction is especially important for vulnerability and lifecycle workflows.

---

## 6. Artifact References

A collection references one or more TEA artifacts.

Each artifact reference MUST include enough information to identify:

- which artifact is being referenced
- which exact bytes are intended

At minimum, this requires:

- an artifact identifier or URI
- a digest of the artifact bytes

### 6.1 Minimal example

```json
{
  "artifactId": "sbom-cyclonedx-json",
  "uri": "https://publisher.example.com/artifacts/sbom.json",
  "digest": {
    "algorithm": "sha-256",
    "value": "BASE64URL_DIGEST"
  }
}
```

### 6.2 Why the digest matters

The URI tells the consumer **where to fetch** the artifact.

The digest tells the consumer **which bytes are intended**.

Without the digest, the collection would not securely bind the release statement to exact content.

### 6.3 Artifact retrieval outside collections

TEA artifacts may also be retrieved independently of a collection.

That is an important architectural feature.

A collection is not the only way an artifact exists in TEA.  
An artifact may be fetched directly by identity, and in TEA with the Trust Architecture that direct retrieval may include its evidence bundle.

The collection therefore does not “contain” the artifact in a storage sense.  
It references and binds it in a release context.

---

## 7. Signatures, Detached Signatures, and Evidence Bundles

This area is where earlier TEA thinking evolved the most, so it is worth being explicit.

### 7.1 In base TEA

Base TEA MAY support detached signatures associated with:

- the collection
- individual artifacts

These can be referenced using URLs or similar API fields.

This is useful for compatibility with existing systems such as:

- CMS / S/MIME detached signatures
- JWS detached signatures
- other legacy signing workflows

### 7.2 In TEA with the Trust Architecture

In TEA with the Trust Architecture, the **evidence bundle** becomes the main verification object.

An evidence bundle includes:

- the signature
- the signing certificate containing the public key
- timestamp evidence
- transparency evidence, when present
- supporting validation material

This means that for trust-aware validation, the collection should not be modeled as if the detached signature alone were the final trust artifact.

Instead:

- detached signatures remain allowed for compatibility
- evidence bundles become the preferred trust reference

### 7.3 Important consequence

The collection should be able to represent:

- no signature-related reference at all
- a detached signature reference
- an evidence bundle reference
- both, where compatibility requires it

### 7.4 Collection-level vs artifact-level evidence

This distinction is critical.

#### Artifact-level evidence
Artifact evidence bundles are reusable across collections, because the artifact is an immutable content object.

#### Collection-level evidence
Collection evidence is **not reusable across collections**, because each collection is a distinct release statement.

Even if two collections reference exactly the same artifacts, they remain different statements and therefore require independent collection-level trust evaluation.

---

## 8. Digest Rules

### 8.1 Single digest algorithm

For this version of TEA, all digests in the collection model MUST use:

```text
sha-256
```

No other digest algorithm is permitted in this version of the specification.

### 8.2 Why this is fixed

This is intentionally strict.

A single digest algorithm:

- improves interoperability
- reduces policy ambiguity
- avoids downgrade confusion
- simplifies validation logic
- makes conformance easier to test

### 8.3 Prohibited algorithms

The following MUST NOT be used in collection digests:

- MD5
- SHA-1
- SHA-512
- any unspecified algorithm

### 8.4 Digest encoding

Digest values MUST be encoded using base64url.

---

## 9. Canonicalization Rules

JSON is not a stable byte representation by default.

Whitespace, field ordering, and formatting differences can change the bytes without changing the logical content.

Therefore, whenever a digest is computed over a JSON object referenced from the collection, the digest MUST be computed over the canonical JSON form defined by:

- RFC 8785 — JSON Canonicalization Scheme (JCS)

### 9.1 Collection rule

If the collection itself is signed as JSON, the signed bytes MUST be the RFC 8785 canonical form.

### 9.2 External evidence bundle rule

If the collection references an external evidence bundle encoded as JSON, the digest in the collection MUST be computed over:

```text
SHA-256(JCS(evidenceBundle))
```

### 9.3 Why this matters

Without canonicalization, a referenced external JSON evidence bundle could be reformatted and incorrectly appear to have changed, or conversely, validators could disagree about the intended bytes.

---

## 10. Validation Semantics

A collection participates in validation in a specific and limited way.

### 10.1 What collection validation proves

Collection validation proves:

- the collection is structurally valid
- the referenced artifact digests match the intended artifact bytes
- if the collection is signed, the release statement is authentic
- if collection evidence is present, the release statement can be validated over time according to policy

### 10.2 What collection validation does not prove

Collection validation does **not by itself** prove:

- that an artifact is independently authentic
- that an artifact has its own timestamp
- that an artifact has transparency evidence
- that an artifact has an evidence bundle

Those properties must be evaluated through the artifact’s own evidence.

### 10.3 Combined trust conclusion

For TEA with the Trust Architecture, a strong consumer conclusion is only available when both are true:

- the collection correctly binds the artifact to the release
- the artifact’s evidence bundle validates successfully

That produces the full statement:

> This exact artifact is authentic, and this exact artifact belongs to this release statement.

---

## 11. Reuse Rules

### 11.1 Artifact reuse is allowed

The same artifact may appear in multiple collections.

This is expected behavior.

### 11.2 Artifact evidence reuse is allowed

An artifact’s evidence bundle may be reused across multiple collections, because the evidence bundle refers to the artifact as an immutable content object.

### 11.3 Collection evidence reuse is not allowed

Collection-level evidence MUST NOT be reused across collections.

This is because each collection is a distinct publisher statement with its own meaning and its own validation context.

### 11.4 Why this distinction exists

Artifacts are facts about content.  
Collections are statements about release composition.

Facts may be reused.  
Statements must be validated in their own context.

---

## 12. Collection Versioning

Collections are versioned independently.

A new collection version SHOULD be created whenever the publisher changes release meaning, including changes to:

- listed artifacts
- metadata
- lifecycle context
- references
- collection-level evidence references

A new collection version is not necessarily a new software release version.

This distinction is important for:

- lifecycle management
- VEX updates
- post-release metadata correction
- auditability

Older published collection versions remain valid historical release statements unless explicitly superseded by policy or lifecycle metadata.

---

## 13. OpenAPI Impact and Required Changes

This section is specifically included because the current OpenAPI collection definition predates some of the trust-architecture refinements.

### 13.1 What base TEA can keep unchanged

The current collection definition can continue to represent, at minimum:

- collection identity
- release metadata
- artifact references
- artifact digests
- optional detached signature URL fields

That remains acceptable for base TEA.

### 13.2 What TEA with the Trust Architecture requires in addition

To support TEA with the Trust Architecture properly, the collection model needs additional expressiveness.

At minimum, the OpenAPI model should support:

- artifact-level evidence bundle references
- optional collection-level evidence bundle reference
- digest protection for externally referenced evidence bundles
- explicit distinction between detached signatures and evidence bundles

### 13.3 Why the current detached-signature-only model is insufficient

A field that only points to a detached signature URL is not enough for TEA with the Trust Architecture, because the trust model requires more than the detached signature itself.

A trust-aware consumer may need:

- the signature
- the certificate
- timestamp evidence
- transparency evidence
- verification material for offline validation

Those belong together conceptually in the evidence bundle.

### 13.4 Required OpenAPI changes

The current OpenAPI collection definition should be updated so that it can express, for each artifact as needed:

- artifact identifier / URI
- artifact digest
- optional detached signature reference
- optional evidence bundle reference

It should also be able to express, at collection level as needed:

- optional collection detached signature reference
- optional collection evidence bundle reference

### 13.5 Digest protection requirement for detached external bundles

When an evidence bundle is referenced externally, the collection MUST carry:

- the bundle URI
- the SHA-256 digest of the canonical JSON representation of that bundle

This ensures that the collection binds not merely to “some file at a URL”, but to an exact external evidence object.

---

## 14. Recommended Data Model Shape

The exact OpenAPI form may vary, but the model should conceptually look like this.

### 14.1 Artifact entry with optional trust references

```json
{
  "artifactId": "sbom-cyclonedx-json",
  "uri": "https://publisher.example.com/artifacts/sbom.json",
  "digest": {
    "algorithm": "sha-256",
    "value": "BASE64URL_DIGEST"
  },
  "detachedSignature": {
    "uri": "https://publisher.example.com/artifacts/sbom.sig"
  },
  "evidenceBundle": {
    "uri": "https://publisher.example.com/evidence/sbom.bundle.json",
    "digest": {
      "algorithm": "sha-256",
      "value": "BASE64URL_BUNDLE_DIGEST"
    }
  }
}
```

### 14.2 Collection-level evidence reference

```json
{
  "collectionId": "release-2026.01",
  "version": "2",
  "artifacts": [ ... ],
  "evidenceBundle": {
    "uri": "https://publisher.example.com/evidence/collection.bundle.json",
    "digest": {
      "algorithm": "sha-256",
      "value": "BASE64URL_COLLECTION_BUNDLE_DIGEST"
    }
  }
}
```

### 14.3 Why this shape is useful

It allows:

- backwards-compatible detached-signature usage
- forward-looking evidence-bundle usage
- clean distinction between base TEA and trust-architecture enrichment
- reuse of artifact evidence across multiple collections
- strict binding of external evidence objects

---

## 15. Normative Requirements

### 15.1 Base TEA requirements

A conforming base TEA collection MUST:

- identify the collection
- include artifact references
- include SHA-256 artifact digests
- bind exact artifact bytes to the release statement

A conforming base TEA collection MAY:

- include detached signature references
- include collection signing material
- include evidence references

### 15.2 TEA Trust Architecture requirements

A collection used in TEA with the Trust Architecture SHOULD:

- support collection-level evidence references where collection trust is needed
- support artifact-level evidence references where artifacts are published with trust architecture semantics
- distinguish detached signatures from evidence bundles

A trust-aware implementation MUST:

- verify SHA-256 digests for external evidence bundle references
- use RFC 8785 canonicalization for JSON evidence bundles
- treat artifact evidence reuse as allowed
- treat collection evidence reuse as forbidden across different collections

### 15.3 Validation constraints

A trust-aware consumer MUST NOT assume that:

- a detached signature URL alone is sufficient for long-term validation
- a collection signature proves artifact authenticity
- a collection evidence bundle can be reused for another collection

---

## 16. Error Conditions

Validation MUST fail when:

- an artifact digest does not match the artifact bytes
- an external evidence bundle digest does not match the referenced bundle
- a required evidence bundle is missing
- canonicalization rules are violated
- collection evidence is incorrectly reused across collections
- a consumer attempts to treat collection binding as artifact authenticity proof

Recommended error identifiers include:

- `COLLECTION_ARTIFACT_DIGEST_MISMATCH`
- `COLLECTION_EVIDENCE_BUNDLE_DIGEST_MISMATCH`
- `COLLECTION_REQUIRED_EVIDENCE_MISSING`
- `COLLECTION_CANONICALIZATION_ERROR`
- `COLLECTION_EVIDENCE_REUSE_FORBIDDEN`
- `COLLECTION_TRUST_SCOPE_ERROR`

---

## 17. Security Considerations

The most common implementation mistake is to collapse too many trust meanings into the collection.

That must be avoided.

The collection is powerful because it binds release meaning to exact bytes.  
It becomes dangerous if implementers start assuming it also proves independent artifact authenticity when it does not.

Another important risk is external reference substitution.

If a collection references an external evidence bundle only by URL and not by digest, then an attacker may be able to replace the referenced object without changing the collection itself.

That is why the digest requirement for external evidence bundles is mandatory in TEA with the Trust Architecture.

Finally, the distinction between base TEA and TEA with the Trust Architecture must remain explicit.  
A base TEA deployment is allowed to be simpler.  
A trust-aware deployment is allowed to be stricter.  
The specification should support both without confusion.

---

## 18. Normative References

- RFC 2119 — Key words for use in RFCs to Indicate Requirement Levels
- RFC 8174 — Ambiguity of Uppercase vs Lowercase in RFC 2119 Key Words
- RFC 6234 — US Secure Hash Algorithms (SHA and SHA-based HMAC and HKDF)
- RFC 8785 — JSON Canonicalization Scheme (JCS)

---

## 19. Informative References

- TEA Evidence Bundle Specification
- TEA Evidence Validation Specification
- TEA Trust Architecture Core Specification
- TEA Publisher Workflow
- TEA Conformance Specification

---

## 20. Final Statement

A TEA collection defines:

> **what belongs to a release**

An artifact evidence bundle defines:

> **why the artifact can be trusted**

A collection evidence bundle, where used, defines:

> **why the release statement can be trusted**

These three ideas are related, but they are not interchangeable.

---

### Key Principle

> A collection binds artifacts to release meaning.  
> An evidence bundle binds trust to an object.
