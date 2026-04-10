# 📘 **TEA Publisher Implementation Guide (Final, Expanded Edition)**  
**Creation, Signing, Validation, and Publication of TEA Releases**

---

## **1. Purpose**

This document describes how to implement a **TEA publisher service** that manages the full lifecycle of software transparency data.

A TEA publisher implementation is responsible for:

- defining products, components, and releases  
- managing artefacts such as SBOMs and VEX documents  
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

A standardized API allows:

- full automation up to the approval boundary  
- reproducible release processes  

---

### **2.3 Internal vs External TEA Services**

Organizations may separate:

- **internal TEA service** → build-time workflows  
- **external TEA service** → public publication  

A standardized API allows:

- transfer of artefacts and collections  
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
- verifiable publication  

---

## **3. Core Concept — What Defines a Release**

A key principle:

> A release is defined by a **published, signed collection**, not by the existence of artefacts.

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

---

## **5. Dual-Level Signing — Why It Matters**

TEA uses two signatures intentionally.

### **Artefact signature**

> “This artefact was produced by this publisher.”

### **Collection signature**

> “These artefacts together define a release.”

Without collection signing:

- artefacts could be mixed  
- releases could be ambiguous  

---

## **6. Canonicalization — Ensuring Deterministic Signatures**

JSON must be canonicalized before signing.

Example:

Two JSON documents may be logically identical but produce different signatures due to:

- whitespace  
- field order  

Solution:

- use **RFC 8785 canonicalization**  
- always sign canonical form  

---

## **7. Certificate Design — Identity and Continuity**

Certificates act as **identity anchors**, not just cryptographic wrappers.

### Required:

- exactly one manufacturer-controlled SAN DNS  

### Optional:

- one third-party SAN DNS  

Example:

```
SAN:
  manufacturer.example.com
  archive.example.net   (optional)
```

This enables:

- primary trust anchor  
- long-term availability via third party  

---

## **8. Key Management — Short-Lived by Design**

Keys should be:

- ephemeral  
- short-lived (hours to ≤24h)  

Why:

- eliminates revocation complexity  
- limits exposure window  
- aligns with modern signing practices  

---

## **9. Evidence — Making Trust Durable**

### Transparency

Provides proof that data was published.

### Timestamp

Provides proof of when.

Together:

- ensure long-term validation  
- protect against backdating or suppression  

---

## **10. Validation — Where Trust is Enforced**

Validation is the most critical responsibility.

The implementation MUST reject:

- invalid signatures  
- mismatched payloads  
- missing evidence  
- incorrect certificates  

This is where:

> trust becomes enforceable, not assumed  

---

## **11. Artifact Lifecycle — Controlled Exposure**

Artifacts must not be exposed prematurely.

### Draft stage
- uploaded  
- internal only  

### Published stage
- included in published collection  
- visible to consumers  

---

### Example

```text
Upload SBOM → draft → not visible
Add to collection → still draft
Publish collection → SBOM becomes published
```

---

## **12. Garbage Collection — Managing Unused Data**

Implementations MAY:

- delete draft artefacts after a retention period  

Example:

```text
Artifact uploaded → never used → deleted after 7 days
```

MUST NOT:

- delete published artefacts  

---

## **13. Collection Workflow — Step-by-Step**

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

## **14. Approval and Commit — The Trust Boundary**

Everything before commit can be automated.

Commit:

- MUST require authentication  
- MUST require authorization  
- SHOULD support multi-party approval  

Example:

```text
CI prepares → human approves → system commits
```

---

## **15. DNS Trust Anchoring (TEA-Native)**

Certificates are published via DNS CERT.

Requirements:

- SAN must match DNS name  
- DNSSEC SHOULD be enabled  

---

## **16. Discovery Interaction**

Discovery must:

- use HTTPS (TLS 1.3)  
- align with trust model  

> Discovery structure is defined separately.

---

## **17. Archival — Long-Term Retention**

Objects may be archived.

Archival means:

- retained  
- not active  
- still accessible  

---

## **18. Logging and Audit — Full Traceability**

All actions MUST be logged.

Example log entry:

```json
{
  "eventId": "TEA-PUB-COLLECTION-PUBLISH",
  "actor": "alice@example.com",
  "timestamp": "2026-04-07T16:00:00Z",
  "objectId": "col-123",
  "result": "success"
}
```

---

## **19. Audit Event Identifiers**

Standard identifiers enable interoperability.

Examples:

- TEA-PUB-ARTIFACT-UPLOAD  
- TEA-PUB-COLLECTION-PUBLISH  
- TEA-PUB-COMMIT  

---

## **20. Webhooks — Event-Driven Integration**

Webhooks allow external systems to react to events.

---

### Example: Signing workflow

```json
{
  "event": "collection.readyForSigning",
  "collectionId": "col-123"
}
```

---

### Example: Authorization error webhook

```json
{
  "event": "authorization.error",
  "timestamp": "2026-04-07T16:05:00Z",
  "actor": "ci-system",
  "action": "collection.publish",
  "objectId": "col-123",
  "reason": "insufficient privileges",
  "requiredRole": "release-approver"
}
```

---

### Example: Approval required

```json
{
  "event": "collection.approvalRequired",
  "collectionId": "col-123"
}
```

---

## **21. Error Handling — Fail Closed**

The system MUST reject operations on:

### Validation errors
- invalid signatures  
- invalid evidence  

### Authorization errors
- insufficient permissions  
- missing approvals  
- missing MFA  

### State errors
- invalid transitions  

---

### Example authorization failure

```text
Attempt: publish collection
User: CI system
Result: denied
Reason: requires human approval
```

---

### Requirements

Errors MUST:

- be returned to caller  
- be logged  
- trigger webhook if configured  

---

## **22. Security Guarantees**

If correctly implemented:

- artefacts are authentic  
- releases are well-defined  
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
- and everything is auditable
