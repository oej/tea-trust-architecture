# 📘 TEA Compliance Documents Specification (Core)
**Version:** 1.0  
**Status:** Draft (Core TEA Specification)

---

## Table of Contents

- [1. Introduction](#1-introduction)
- [2. Scope and Ownership](#2-scope-and-ownership)
- [3. Purpose of Compliance Documents](#3-purpose-of-compliance-documents)
- [4. Data Model and Identifier Usage](#4-data-model-and-identifier-usage)
- [5. Defined Compliance Document Types](#5-defined-compliance-document-types)
- [6. API Access Model](#6-api-access-model)
- [7. Relationship to Other TEA Concepts](#7-relationship-to-other-tea-concepts)
- [8. Representation and Distribution](#8-representation-and-distribution)
- [9. Interoperability Requirements](#9-interoperability-requirements)
- [10. Security Considerations](#10-security-considerations)
- [11. References](#11-references)

---

## 1. Introduction

TEA supports the exposure of **compliance documents** associated with a publisher.

Compliance documents represent:

- regulatory compliance  
- certification status  
- security and assurance frameworks  

This document defines how compliance documents are modeled and accessed within TEA.

---

## 2. Scope and Ownership

```text
Compliance documents are scoped to the authority (domain owner).
They are not associated with specific products, releases, or collections.
```

The authority may represent:

- a manufacturer  
- an organization  
- an open source project  

---

## 3. Purpose of Compliance Documents

Compliance documents provide:

- transparency regarding organizational compliance  
- machine-readable discovery of certifications  
- standardized references for regulatory and assurance frameworks  

---

## 4. Data Model and Identifier Usage

Compliance documents are represented using the shared identifier model in the TEA OpenAPI specification.

---

### Normative Requirement

```text
When idType is COMPLIANCE_DOCUMENT, the idValue MUST be one of the defined compliance document types in the TEA OpenAPI specification.
```

---

### Design Principle

```text
TEI identifies products.
Compliance documents describe the publisher.
```

---

## 5. Defined Compliance Document Types

The following compliance document types are defined:

```text
SOC_2_TYPE_I
SOC_2_TYPE_II
SOC_3
ISO_27001
ISO_27017
ISO_27018
ISO_27701
ISO_42001
PCI_DSS
HIPAA
FedRAMP
GDPR
CSA_STAR
NIST_800_53
NIST_800_171
CMMC
HITRUST
TISAX
CYBER_ESSENTIALS
CYBER_ESSENTIALS_PLUS
```

---

### Extensibility

```text
New compliance document types MUST be defined through updates to the TEA OpenAPI specification.
Implementations MUST NOT introduce proprietary or undefined values.
```

---

## 6. API Access Model

Compliance documents are retrieved independently of TEI-scoped resources.

---

### Conceptual Endpoints

```text
GET /compliance-documents
GET /compliance-documents/{type}
```

---

### Resolution Flow

```text
TEI → authority → discovery → API → compliance documents
```

---

## 7. Relationship to Other TEA Concepts

### 7.1 TEI

```text
TEI identifies a product.
Compliance documents are not product-scoped.
```

---

### 7.2 Collections

```text
Collections MUST NOT include compliance documents.
```

---

### 7.3 Artifacts

A compliance document MAY be:

- metadata only  
- represented as a retrievable artifact  
- both  

---

## 8. Representation and Distribution

Compliance documents MAY be:

- referenced as identifiers  
- retrieved as artifacts  
- exposed via metadata  

---

### Format Considerations

- JSON for metadata  
- binary formats (e.g., PDF) for documents  

---

## 9. Interoperability Requirements

```text
Implementations MUST use the defined compliance document types.
Consumers MUST correctly interpret these types.
Unknown types MUST be rejected.
```

---

## 10. Security Considerations

Compliance documents do not inherently provide:

- authenticity  
- integrity  
- trust  

---

### Important Distinction

```text
The presence of a compliance document does not imply verification.
```

If distributed as artifacts, validation MUST follow TEA trust architecture.

---

## 11. References

### SOC Frameworks

- AICPA / CIMA — SOC Reporting Framework  
  https://www.aicpa-cima.com

---

### ISO Standards

- ISO/IEC 27001 — Information Security Management  
- ISO/IEC 27017 — Cloud Security  
- ISO/IEC 27018 — Protection of PII in Cloud  
- ISO/IEC 27701 — Privacy Information Management  
- ISO/IEC 42001 — AI Management Systems  

https://www.iso.org

---

### Regulatory and Industry Standards

- PCI DSS — Payment Card Industry Security Standards Council  
  https://www.pcisecuritystandards.org  

- HIPAA — U.S. Department of Health & Human Services  
  https://www.hhs.gov  

- FedRAMP — U.S. Federal Risk and Authorization Management Program  
  https://www.fedramp.gov  

- GDPR — Regulation (EU) 2016/679  
  https://eur-lex.europa.eu  

---

### Security and Assurance Frameworks

- CSA STAR — Cloud Security Alliance  
  https://cloudsecurityalliance.org  

- NIST SP 800-53 — Security Controls  
- NIST SP 800-171 — Controlled Unclassified Information  
  https://csrc.nist.gov  

- CMMC — U.S. Department of Defense  
  https://dodcio.defense.gov  

- HITRUST — HITRUST Alliance  
  https://hitrustalliance.net  

- TISAX — ENX Association  
  https://enx.com  

---

### UK Cyber Essentials

- Cyber Essentials / Cyber Essentials Plus  
  UK National Cyber Security Centre (NCSC)  
  https://www.ncsc.gov.uk  

---
