# 📘 **TEA Publisher Implementation Guide (Final, Expanded Edition)**  
**Creation, Signing, Validation, and Publication of TEA Releases and Lifecycle Data**

---

## **1. Purpose**

This document describes how to implement a **TEA publisher service** that manages the full lifecycle of software transparency data.

A TEA publisher implementation is responsible for:

- defining products, components, and releases  
- managing artefacts such as SBOMs and VEX documents  
- managing lifecycle (CLE) documents  
- assembling and signing collections  
- validating trust evidence  
- enforcing controlled publication workflows  
- maintaining auditability over time  

This document complements:

- the **TEA Publisher Workflow Overview** (lifecycle and state transitions)  
- the **TEA Consumer API specification** (normative data model)  

> This guide focuses on **how to implement behavior**, not how to define objects.

---

## **2. Why a Standardized Publisher API Matters**

A TEA publisher API is not just a convenience — it is an **interoperability layer for the software supply chain**.

### **2.1 Independent Tooling**

With a standardized API:

- SBOM generators can upload artefacts directly  
- signing tools can integrate without vendor-specific logic  
- lifecycle management systems can publish CLE updates  
- validation tools can be reused across implementations  

Without it:

- every implementation becomes isolated  
- tooling ecosystems fragment  

---

### **2.2 CI/CD Integration**

A TEA publisher fits naturally into modern pipelines:

1. build artefacts  
2. upload artefacts  
3. create collection  
4. prepare signing  
5. sign  
6. approve  
7. publish  
8. publish lifecycle updates (CLE)

A standardized API allows:

- full automation up to the approval boundary  
- reproducible release and lifecycle processes  

---

### **2.3 Internal vs External TEA Services**

Organizations may separate:

- **internal TEA service** → build-time workflows  
- **external TEA service** → public publication  

A standardized API allows:

- transfer of artefacts, collections, and CLE documents  
- interoperability across implementations  
- outsourcing publication to third-party providers  

---

### **2.4 Regulatory Alignment (CRA)**

The Cyber Resilience Act emphasizes:

- traceability  
- transparency before purchase  
- long-term availability  

A structured publisher API enables:

- auditable workflows  
- reproducible releases  
- verifiable lifecycle commitments  

---

## **3. Core Concept — What Defines a Release**

A key principle:

> A release is defined by a **published, signed collection**, not by the existence of artefacts.

Lifecycle (CLE) data:

- does not redefine a release  
- augments it over time  

This ensures:

- consistency  
- verifiability  
- resistance to partial or manipulated data  

---

## **4. Trust Models — Behavioral Enforcement**

Implementations must enforce consistent trust behavior per product.

---

### **4.1 TEA-Native (Evidence-Based Trust)**

The TEA-native model provides **self-contained long-term verification**.

A compliant implementation MUST require:

- artefact signatures  
- collection signature  
- timestamp  
- transparency receipt  
- DNS-based trust anchor  

For CLE:

- signature  
- timestamp  
- transparency (policy-driven)  
- DNS anchor (TEA-native)

These elements together provide:

| Property | Mechanism |
|--------|----------|
| Identity | Certificate |
| Ordering | Timestamp |
| Inclusion | Transparency log |
| Discovery | DNS |

---

### **4.2 WebPKI (Compatibility Model)**

This model relies on traditional PKI.

Implementation MUST:

- validate certificate chain  
- reject TEA-native evidence  

Implementation SHOULD:

- validate CAA records  
- support DNSSEC  

CLE follows the same trust model constraints.

---

## **5. Dual-Level Signing — Why It Matters**

TEA uses two signatures intentionally.

### **Artefact signature**

> “This artefact was produced by this publisher.”

### **Collection signature**

> “These artefacts together define a release.”

### **CLE signature**

> “This lifecycle statement is issued by this publisher at this time.”

Without collection signing:

- artefacts could be mixed  
- releases could be ambiguous  

Without CLE signing:

- lifecycle changes could be forged or disputed  

---

## **6. Canonicalization — Ensuring Deterministic Signatures**

JSON must be canonicalized before signing.

Solution:

- use **RFC 8785 canonicalization**  
- always sign canonical form  

Applies to:

- discovery  
- artefacts  
- collections  
- CLE documents  

---
## ** 7. Discovery Signing (Publisher Responsibility)**

The publisher MUST implement signing of the discovery document (`.well-known/tea`).

Discovery signing is required to establish **trust in endpoint selection**.

### Purpose

Discovery signing provides:

- authorization of API endpoints
- binding between manufacturer domain and TEA service
- trust bootstrap for all subsequent validation

### Requirements

A compliant implementation MUST:

- generate a short-lived signing key (≤24h)
- produce a self-signed certificate
- canonicalize discovery JSON (RFC 8785)
- sign the canonical form using Ed25519
- attach:
  - signature
  - signing certificate
  - timestamp (REQUIRED)

### Trust Model Behavior

For TEA-native:

- discovery signing certificate MAY be published in DNS
- DNS validation MAY be applied by consumers

For WebPKI:

- TLS validation provides the primary trust anchor
- discovery signature still protects integrity and authorization

### Separation of Concerns

Discovery signing is **independent** from:

- artefact signing
- collection signing
- CLE signing

Each serves a different trust purpose.

### Reference

The detailed discovery signing workflow is defined in:

- TEA Trust Architecture — End-to-End Example
- Discovery specification


## **8. Certificate Design — Identity and Continuity**

Certificates act as **identity anchors**, not just cryptographic wrappers.

### Required:

- exactly one manufacturer-controlled SAN DNS  

### Optional:

- one third-party SAN DNS  

Applies to:

- artefact signing  
- collection signing  
- CLE signing  

---

## **9. Key Management — Short-Lived by Design**

Keys should be:

- ephemeral  
- short-lived (hours to ≤24h)  

Applies to:

- artefact signing keys  
- collection signing keys  
- CLE signing keys  

---

## **10. Evidence — Making Trust Durable**

### Transparency

Provides proof that data was published.

### Timestamp

Provides proof of when.

Together:

- ensure long-term validation  
- protect against backdating or suppression  

Applies equally to CLE.

---

## **11. Validation — Where Trust is Enforced**

Validation is the most critical responsibility.

The implementation MUST reject:

- invalid signatures  
- mismatched payloads  
- missing evidence  
- incorrect certificates  
- invalid CLE version chains  

This is where:

> trust becomes enforceable, not assumed  

---

## **12. Artifact Lifecycle — Controlled Exposure**

Artifacts must not be exposed prematurely.

### Draft stage
- uploaded  
- internal only  

### Published stage
- included in published collection  
- visible to consumers  

---

## **13. CLE Lifecycle Management**

CLE introduces a **versioned lifecycle stream**.

Rules:

- each CLE document MUST include a version  
- updates MUST reference previous version  
- history MUST be preserved  
- no overwriting allowed  

---

### Example

```text
v1 → published
v2 → extends support
v3 → marks end-of-life
```

All versions remain accessible.

---

## **14. Garbage Collection — Managing Unused Data**

Implementations MAY:

- delete draft artefacts  

Implementations MAY:

- delete unreferenced draft CLE documents  

MUST NOT:

- delete published artefacts  
- delete published CLE history  

---

## **15. Collection Workflow — Step-by-Step**

1. create draft collection  
2. add artefacts  
3. mark ready for signing  
4. retrieve canonical payload  
5. sign externally  
6. upload signed collection  
7. validate  
8. approve  
9. publish  

---

## **16. CLE Workflow — Step-by-Step**

1. create draft CLE document  
2. assign version and previousVersion  
3. canonicalize payload  
4. sign externally  
5. timestamp  
6. add transparency proof  
7. upload signed CLE  
8. validate  
9. approve  
10. publish  

---

## **17. Approval and Commit — The Trust Boundary**

Everything before commit can be automated.

Applies to:

- collections  
- CLE documents  

Commit:

- MUST require authentication  
- MUST require authorization  
- SHOULD support multi-party approval  

---

## **18. DNS Trust Anchoring (TEA-Native)**

Certificates are published via DNS CERT.

Applies to:

- artefact signing certificates  
- collection signing certificates  
- CLE signing certificates  

---

## **19. Discovery Interaction**

Discovery must:

- use HTTPS (TLS 1.3)  
- align with trust model  

---

## **20. Archival — Long-Term Retention**

Objects may be archived:

- artefacts  
- collections  
- CLE documents  

---

## **21. Logging and Audit — Full Traceability**

All actions MUST be logged.

---

### **21.1 Audit Event Identifiers**

Examples:

- TEA-PUB-ARTIFACT-UPLOAD  
- TEA-PUB-COLLECTION-PUBLISH  
- TEA-PUB-CLE-PUBLISH  
- TEA-PUB-COMMIT  

---

## **22. Webhooks — Event-Driven Integration**

Include CLE-related events.

---

### Example

```json
{
  "event": "cle.readyForSigning",
  "entityId": "example-product@1.0.0",
  "version": 2
}
```

---

## **23. Error Handling — Fail Closed**

The system MUST reject operations on:

### Validation errors
- invalid signatures  
- invalid evidence  
- invalid CLE version chain  

### Authorization errors
- insufficient permissions  
- missing approvals  

### State errors
- invalid transitions  

---

## **24. Security Guarantees**

If correctly implemented:

- artefacts are authentic  
- releases are well-defined  
- lifecycle state is authentic and versioned  
- trust is verifiable  
- workflows are controlled  
- actions are auditable  

---

## **Final Statement**

A TEA publisher is not just an API.

It is a **system of record for software transparency**, where:

- trust is created through signatures  
- integrity is enforced through validation  
- publication is controlled through approval  
- lifecycle is tracked through CLE  
- and everything is auditable
