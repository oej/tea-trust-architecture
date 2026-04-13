# 📄 architecture/cra-alignment.md

# TEA Security Architecture – CRA Alignment (v1.1)

---

## 1. Introduction

The Transparency Exchange API (TEA) security architecture is designed to support compliance with the EU Cyber Resilience Act (CRA).

The CRA establishes requirements for:

- secure development and production processes  
- lifecycle security and update management  
- software transparency (including SBOMs)  
- vulnerability handling and remediation  
- long-term availability of software artifacts and updates  
- verifiable integrity and authenticity  

TEA provides a **technical trust architecture** that operationalizes these requirements through:

- cryptographic evidence  
- structured release definitions  
- verifiable publication processes  
- long-term validation mechanisms  

---

## 2. CRA Core Requirements (Interpretation)

The CRA (including Annex I essential requirements) requires that manufacturers:

- ensure **security throughout the product lifecycle**  
- provide and maintain **software bill of materials (SBOM)**  
- implement **vulnerability handling and coordinated disclosure**  
- guarantee **availability of updates and security fixes**  
- ensure **integrity and authenticity of software**  
- maintain **traceability of components and releases**  

These requirements are **process-oriented**, but require **technical enforcement mechanisms** to be effective.

---

## 3. TEA Trust Architecture Alignment

TEA aligns with CRA through three interconnected trust domains:

| TEA Domain | CRA Concern |
|-----------|------------|
| Discovery | Correct service identification |
| Consumer Validation | Integrity, authenticity, traceability |
| Publication | Authorized release and accountability |

---

### 3.1 Lifecycle Management

**CRA Requirement:**  
Security must be ensured across the entire lifecycle of the product.

**TEA Alignment:**

TEA introduces a **structured release model**:

- collections define release composition  
- artefacts are bound via signed checksums  
- lifecycle updates (e.g., VEX, metadata corrections) are versioned as new collections  

TEA enables:

- validation at any point in time  
- separation of artefact identity from release context  
- support for continuous lifecycle updates without altering artefact bytes  

---

### 3.2 Long-Term Availability and Verifiability

**CRA Requirement:**  
Software artifacts and updates must remain available and verifiable for extended periods (≥10 years).

**TEA Alignment:**

TEA provides **evidence-based long-term validation**:

- timestamped signatures prove existence at signing time  
- transparency logs provide durable publication evidence  
- evidence bundles enable offline validation  

Key property:

> **Validation depends on preserved evidence, not on live infrastructure.**

This ensures:

- independence from certificate revocation systems  
- resilience to CA, DNS, or service outages  
- support for regulatory audits years after release  

---

### 3.3 Integrity and Authenticity

**CRA Requirement:**  
Software must be protected against tampering and unauthorized modification.

**TEA Alignment:**

TEA enforces integrity and authenticity through:

- artefact signatures (authenticity of artefacts)  
- collection signatures (publisher-approved release composition)  
- checksum binding (exact byte-level integrity)  
- timestamp validation (temporal correctness)  

Validation is **multi-layered and compositional**, not dependent on a single control.

---

### 3.4 SBOM and Transparency

**CRA Requirement:**  
Manufacturers must provide SBOMs and ensure transparency of components.

**TEA Alignment:**

TEA treats SBOMs as **first-class artefacts**:

- SBOMs can be signed and timestamped  
- SBOMs are bound to releases via collections  
- SBOM integrity is verifiable over time  

TEA also supports:

- linking SBOM components to vulnerability data  
- associating SBOMs with lifecycle updates (e.g., VEX)  

---

### 3.5 Vulnerability Handling and Updates

**CRA Requirement:**  
Manufacturers must manage vulnerabilities and provide timely updates.

**TEA Alignment:**

TEA enables:

- signed publication of vulnerability-related artefacts (e.g., VEX)  
- traceability between vulnerabilities, components, and releases  
- verification that updates are authentic and authorized  

Important distinction:

- **cryptographic validity ≠ lifecycle suitability**  

TEA separates:

- validity (cryptographic correctness)  
- lifecycle state (e.g., supported, end-of-life)  

---

### 3.6 Supply Chain Security

**CRA Requirement:**  
Supply chains must be secured and verifiable.

**TEA Alignment:**

TEA provides:

- verifiable provenance through artefact signatures  
- release-level integrity through signed collections  
- auditability via transparency logs  
- detection of tampering and backdating via timestamps  

This supports:

- traceability across dependencies  
- reproducible validation of supply chain artifacts  

---

### 3.7 Publication Authorization (Critical for CRA)

**CRA Requirement:**  
Manufacturers must ensure that released software reflects authorized intent.

**TEA Alignment:**

TEA introduces a **controlled publication model**:

- CI/CD systems prepare releases but cannot finalize them  
- publication requires explicit authorization (e.g., MFA)  
- commit step records approver identity and time  
- release state becomes immutable after commit  

Key property:

> **A valid signature alone is insufficient — publication must be authorized.**

This directly addresses a critical CRA risk:

- validly signed but unauthorized releases  

---

## 4. Key Advantages for CRA Compliance

---

### 4.1 Evidence-Based Trust (Not Revocation-Based)

TEA avoids reliance on revocation infrastructure by:

- using timestamps to prove signing-time validity  
- enabling validation after certificate expiry  

---

### 4.2 Long-Term Offline Validation

TEA enables:

- validation without network access  
- audit verification years after release  
- independence from external services  

---

### 4.3 Distributed Trust Model

Trust is distributed across:

- signatures  
- timestamps  
- DNS / PKI  
- transparency logs  

This reduces:

- single points of failure  
- systemic risk  

---

### 4.4 Strong Auditability

TEA provides:

- verifiable publication history  
- immutable evidence chains  
- traceable release decisions  

This supports:

- regulatory audits  
- forensic analysis  
- compliance verification  

---

## 5. Gaps in Existing Guidance

Current guidance (ENISA, CISA):

- emphasizes process but lacks **technical enforcement models**  
- does not define **long-term validation mechanisms**  
- does not specify **timestamp-based trust models**  
- does not address **publication authorization as a trust boundary**  

TEA fills these gaps by providing:

- a concrete evidence model  
- a compositional trust architecture  
- explicit validation rules  

---

## 6. Key Insight

> **CRA compliance requires not only secure processes, but verifiable evidence that those processes were followed.**

TEA provides:

- cryptographic proof of integrity  
- temporal proof of correctness  
- audit proof of publication  

---

## 7. Summary

TEA translates CRA requirements into a concrete, enforceable technical architecture by:

- enabling lifecycle validation of software artefacts  
- supporting long-term evidence preservation  
- ensuring verifiable integrity, authenticity, and provenance  
- enforcing controlled and auditable publication  

The architecture achieves long-term trust not by preserving infrastructure or keys, but by preserving **verifiable evidence of correctness at the time of publication**.

---
