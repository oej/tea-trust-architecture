# 📘 TEA Consumer API — Artefact Retrieval and Validation Material
**Version:** 1.0  
**Status:** Draft (Normative, Implementation-Ready)

---

# 1. Purpose

This document defines how a TEA Consumer API exposes TEA artefacts and associated validation material.

It standardizes three retrieval forms:

1. **artefact only**  
2. **artefact + detached signature**  
3. **artefact + evidence bundle**

The goal is to support:

- simple content retrieval  
- compatibility with existing detached-signature workflows  
- full TEA trust-architecture validation  
- reuse of artefacts and evidence bundles across multiple TEA collections  

---

# 2. Design Principles

## 2.1 Artefacts Are First-Class Objects

A TEA artefact MUST be retrievable independently of any TEA collection.

A TEA collection provides:

- release context  
- release binding  
- publisher release statement  

But it MUST NOT be required for independent artefact authenticity validation.

---

## 2.2 Evidence Bundle Is the Primary Trust Object

In TEA with the trust architecture, the preferred validation object is the **evidence bundle**.

The evidence bundle contains:

- signature  
- certificate  
- timestamp evidence  
- transparency evidence  

Detached signatures remain supported for compatibility, but they are not sufficient for full long-term TEA trust validation unless additional evidence is retrieved separately.

---

## 2.3 Retrieval Form Must Not Change Trust Semantics

Changing the transport form of an artefact MUST NOT change the validation meaning of the artefact.

For example:

- returning an artefact alone does not make it trustworthy  
- returning an artefact with a detached signature does not by itself provide long-term validation  
- returning an artefact with an evidence bundle provides the material needed for TEA trust-architecture validation  

---

# 3. Artefact Retrieval Forms

## 3.1 Artefact Only

An implementation MAY return the artefact by itself.

This form is useful for:

- simple download  
- caching  
- mirroring  
- legacy clients  

Examples include:

- PDF  
- CycloneDX JSON  
- SPDX JSON  
- XML  
- binary artefacts  

### Example

```http
GET /consumer/artifacts/{artifactId}
Accept: application/octet-stream
```

Response body:

```text
<raw artifact bytes>
```

---

## 3.2 Artefact + Detached Signature

An implementation MAY return an artefact together with a detached signature using a multipart response.

This form is useful for:

- compatibility with existing signing ecosystems  
- CMS / S/MIME detached signatures  
- detached JWS  
- other detached signature formats  

A detached signature response MUST clearly identify:

- which part is the artefact  
- which part is the signature  

### Example

```http
GET /consumer/artifacts/{artifactId}
Accept: multipart/mixed; profile="artifact+signature"
```

Example response structure:

```text
multipart/mixed
  part 1: artifact bytes
  part 2: detached signature
```

### Important Note

This retrieval form does not by itself provide complete TEA trust-architecture validation unless timestamp and transparency evidence are also available through other means.

---

## 3.3 Artefact + Evidence Bundle

An implementation using the TEA trust architecture SHOULD support returning an artefact together with its evidence bundle using a multipart response.

This form is the preferred retrieval method for:

- long-term validation  
- offline validation  
- simplified trust-aware consumption  

The multipart response MUST clearly identify:

- the artefact part  
- the evidence bundle part  

### Example

```http
GET /consumer/artifacts/{artifactId}
Accept: multipart/mixed; profile="artifact+evidence"
```

Example response structure:

```text
multipart/mixed
  part 1: artifact bytes
  part 2: evidence bundle JSON
```

---

# 4. Independent Evidence Bundle Retrieval

An implementation using the TEA trust architecture MUST support retrieval of an artefact evidence bundle independently of any TEA collection.

This is required because:

- artefacts may be reused across multiple collections  
- the same evidence bundle may be referenced from multiple collections  
- clients may wish to retrieve or cache validation material separately  

### Example

```http
GET /consumer/artifacts/{artifactId}/evidence
Accept: application/json
```

Response body:

```json
{
  "bundleVersion": "1.0",
  "object": { "...": "..." },
  "signature": { "...": "..." },
  "certificate": { "...": "..." },
  "timestamps": [ ... ],
  "transparency": [ ... ]
}
```

---

# 5. Multipart Response Requirements

## 5.1 General

When multipart responses are used, implementations MUST ensure that each part is unambiguously identified.

At minimum, the response MUST make it clear which part is:

- the TEA artefact  
- the detached signature or evidence bundle  

This MAY be achieved using:

- part ordering  
- content disposition names  
- documented profile conventions  

---

## 5.2 Artefact + Signature Multipart

A multipart artefact + detached signature response MUST include exactly:

- one artefact part  
- one detached signature part  

If more than one detached signature is returned, the relationship between them MUST be explicitly defined.

---

## 5.3 Artefact + Evidence Bundle Multipart

A multipart artefact + evidence bundle response MUST include exactly:

- one artefact part  
- one evidence bundle part  

The evidence bundle part MUST correspond to the returned artefact.

Mismatch between artefact and evidence bundle MUST be treated as a validation failure.

---

# 6. Validation Behavior

## 6.1 Artefact-Only Retrieval

If a client retrieves only the artefact:

- no trust conclusion may be made from transport alone  
- the client MAY later retrieve detached signature or evidence bundle material separately  

---

## 6.2 Artefact + Detached Signature

If a client retrieves an artefact together with a detached signature:

- the client MAY verify integrity and signature correctness  
- the client MUST NOT assume long-term validity unless timestamp and other required evidence are also validated  

---

## 6.3 Artefact + Evidence Bundle

If a client retrieves an artefact together with an evidence bundle:

- the client SHOULD validate the artefact against the evidence bundle  
- the client MAY validate offline if local trust anchors and policy permit  
- the client MAY later validate release inclusion through a TEA collection  

---

# 7. Relationship to TEA Collections

A TEA collection answers:

> “Does this artefact belong to this release?”

An artefact evidence bundle answers:

> “Is this artefact authentic and verifiable over time?”

These are different questions and MUST remain separate.

Therefore:

- artefact validation MUST NOT require a collection  
- collection inclusion validation MUST use the TEA collection  
- the same artefact and evidence bundle MAY be reused in multiple collections  

---

# 8. OpenAPI Modeling Guidance

The Consumer API SHOULD model at least the following operations.

## 8.1 Retrieve Artefact

```http
GET /consumer/artifacts/{artifactId}
```

Supported response forms MAY include:

- raw artefact  
- multipart artefact + detached signature  
- multipart artefact + evidence bundle  

---

## 8.2 Retrieve Evidence Bundle

```http
GET /consumer/artifacts/{artifactId}/evidence
```

Response:

- JSON evidence bundle  

---

## 8.3 Retrieve Detached Signature (Optional)

```http
GET /consumer/artifacts/{artifactId}/signature
```

Response:

- detached signature object  

This endpoint is OPTIONAL and primarily useful for compatibility scenarios.

---

# 9. Conformance Requirements

## 9.1 Base TEA

A base TEA implementation:

- MUST support artefact retrieval  
- MAY support detached signature retrieval  
- MAY support multipart artefact + detached signature  

---

## 9.2 TEA with the Trust Architecture

An implementation using the TEA trust architecture:

- MUST support independent evidence bundle retrieval for artefacts  
- SHOULD support multipart artefact + evidence bundle retrieval  
- MAY support detached signature retrieval for compatibility  

---

## 9.3 High-Assurance Profiles

A high-assurance implementation:

- SHOULD support artefact + evidence bundle multipart retrieval  
- SHOULD support bundle caching and reuse  
- SHOULD support validation without live TSA or transparency access  

---

# 10. Error Handling

Implementations SHOULD define clear errors for:

- artefact not found  
- evidence bundle not found  
- multipart profile unsupported  
- artefact and evidence bundle mismatch  
- detached signature and artefact mismatch  

Example error identifiers:

- `ARTIFACT_NOT_FOUND`
- `EVIDENCE_BUNDLE_NOT_FOUND`
- `UNSUPPORTED_RETRIEVAL_PROFILE`
- `ARTIFACT_EVIDENCE_MISMATCH`
- `ARTIFACT_SIGNATURE_MISMATCH`

---

# 11. Security Considerations

## 11.1 Transport vs Trust

TLS protects transport confidentiality and integrity, but it MUST NOT be treated as the trust basis for artefact authenticity.

---

## 11.2 Detached Signatures Are Incomplete for Long-Term Trust

Detached signatures support integrity and signature verification, but do not by themselves provide:

- signing-time proof  
- public visibility proof  
- long-term validation  

---

## 11.3 Evidence Bundle Reuse

Because artefacts may be reused across multiple TEA collections, evidence bundles SHOULD be treated as reusable immutable validation objects.

Implementations SHOULD preserve:

- artefact bytes  
- evidence bundle  
- stable digests and references  

---

# 12. Final Statement

The TEA Consumer API MUST treat artefacts as independently retrievable objects.

It MAY return them in simple or compatibility-oriented forms, but in TEA with the trust architecture the preferred retrieval model is:

> **artefact + evidence bundle**

This enables:

- independent authenticity validation  
- offline verification  
- long-term trust  

without requiring immediate access to a TEA collection.

---
