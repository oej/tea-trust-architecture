# 📘 TEA Security Considerations

## Status

- **Version:** 1.0  
- **Status:** Draft (Normative, RFC-style)  
- **Scope:** TEA Trust Architecture  
- **Audience:** Implementers, security architects, auditors  

---

## Table of Contents

1. [Scope](#1-scope)  
2. [System Trust Boundaries](#2-system-trust-boundaries)  
3. [STRIDE Threat Analysis](#3-stride-threat-analysis)  
4. [Attacker Capability Matrix](#4-attacker-capability-matrix)  
5. [Key Security Properties](#5-key-security-properties)  
6. [Discovery-Specific Risks](#6-discovery-specific-risks)  
7. [Artefact Validation Risks](#7-artefact-validation-risks)  
8. [Timestamp Risks](#8-timestamp-risks)  
9. [Transparency Log Risks](#9-transparency-log-risks)  
10. [DNS Trust Model Risks](#10-dns-trust-model-risks)  
11. [WebPKI Model Risks](#11-webpki-model-risks)  
12. [Failure Containment](#12-failure-containment)  
13. [Residual Risks](#13-residual-risks)  
14. [Security Requirements Summary](#14-security-requirements-summary)  
15. [Dual-Level Signing Security Model](#15-dual-level-signing-security-model)  
16. [Final Security Statement](#16-final-security-statement)  

---

## 1. Scope

This document analyzes the security properties of the TEA architecture, covering:
* discovery
* artefact signing and validation
* lifecycle (CLE) documents and validation
* timestamping
* transparency logging
* DNS-based trust anchor publication
* WebPKI policy constraints
* long-term validation

The goal is to define:
* what threats are mitigated
* what threats remain
* how failures are contained

---

## 2. System Trust Boundaries

The TEA architecture explicitly separates trust across multiple independent components.

### 2.1 Trust Boundaries

The following boundaries MUST be considered independent:
1. Manufacturer domain  
2. TEA API service, which may be third-party hosted  
3. DNS infrastructure  
4. Transparency log  
5. Timestamp authority  
6. Consumer environment  

No single component is trusted to provide end-to-end integrity.

---

### 2.2 Trust Anchors

Trust is derived from a combination of independent anchors:
* certificate  
* signature  
* timestamp  
* transparency log  
* DNS publication  
* optionally DNSSEC  
* or WebPKI, depending on trust model  

---

### 2.3 Compositional Trust

TEA does not rely on a single hierarchical chain of trust.

Trust is established by combining independent signals.

---

## 3. STRIDE Threat Analysis

### 3.1 Spoofing

Mitigation includes:
* TLS validation  
* discovery signatures  
* certificate-based validation of artefacts and CLE documents  
* DNSSEC (optional)  
* WebPKI validation where applicable  

---

### 3.2 Tampering

Mitigation includes:
* signatures on collections, artefacts, and CLE documents  
* timestamps  
* transparency logs  

---

### 3.3 Repudiation

Mitigation includes:
* signatures  
* timestamps  
* transparency evidence  

---

### 3.4 Information Disclosure

TEA is not designed for confidentiality.

---

### 3.5 Denial of Service

Mitigation includes:
* caching  
* redundancy  

---

### 3.6 Elevation of Privilege

Mitigation includes:
* key control  
* publication authorization  
* lifecycle (CLE) publication controls equivalent to collections  

---

## 4. Attacker Capability Matrix

(unchanged)

---

## 5. Key Security Properties

### 5.1 Service Independence

(unchanged)

---

### 5.2 Ephemeral Key Model

(unchanged)

---

### 5.3 Transparency Enforcement

Provides:
* auditability  
* ordering  
* publication evidence  

Supported systems:
* Rekor  
* Sigsum  

SCITT MAY be supported in future implementations.

---

### 5.4 Time Integrity

(unchanged)

---

### 5.5 DNS and Organizational Resilience

(unchanged)

---

## 6. Discovery-Specific Risks

(unchanged)

---

## 7. Artefact Validation Risks

(unchanged)

---

## 8. Timestamp Risks

(unchanged)

---

## 9. Transparency Log Risks

(unchanged)

---

## 10. DNS Trust Model Risks

(unchanged)

---

## 11. WebPKI Model Risks

(unchanged)

---

## 12. Failure Containment

(unchanged)

---

## 13. Residual Risks

(unchanged)

---

## 14. Security Requirements Summary

### 14.1 Consumer Requirements

Consumers MUST:
* validate signatures  
* validate timestamps  
* validate certificate profile  
* validate binding  
* validate lifecycle (CLE) documents when present  
* support validation of both Sigsum and Rekor transparency systems  
* fail closed  

Consumers MUST be able to retrieve and validate previous versions of lifecycle (CLE) documents to support lifecycle change analysis.

---

### 14.2 Publisher Requirements

Publishers MUST:
* use short-lived keys  
* provide timestamps  
* publish DNS anchors  
* apply the same signing and authorization controls to lifecycle (CLE) documents as for collections  
* version lifecycle (CLE) documents  
* make previous lifecycle (CLE) versions accessible  

Publishers SHOULD:
* provide transparency  
* use multiple TSAs  

---

## 15. Dual-Level Signing Security Model

TEA uses:
* artefact-level signatures  
* collection-level signatures  

Lifecycle (CLE) documents MUST follow equivalent signing and validation rules.

---

## 16. Final Security Statement

TEA achieves security by:
* minimizing trust in infrastructure  
* using short-lived keys  
* combining independent trust anchors  

---

### Final Conclusion

TEA does not guarantee trusted content.

It guarantees:
* trusted delivery  
* verifiable integrity  
* auditable publication  

Lifecycle (CLE) information supports risk and compliance decisions but does not alter cryptographic validity.
