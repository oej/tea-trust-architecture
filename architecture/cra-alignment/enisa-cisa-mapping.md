# TEA Alignment with ENISA Secure-by-Design and CISA Guidance

## Status

This document is informative.

It describes how the TEA Trust Architecture aligns with
external secure-by-design frameworks, including ENISA and CISA guidance.

It does not define normative protocol behavior.

## 1. Purpose

This document explains how the TEA security model aligns with:

- ENISA Secure by Design and Default (2026 draft)
- CISA Secure by Design principles (2023)

It highlights how TEA supports regulatory expectations, especially under the Cyber Resilience Act (CRA).

## 2. High-level alignment

Both ENISA and CISA emphasize:

- Secure development lifecycle
- Supply chain transparency
- Vulnerability handling
- Evidence and accountability

TEA provides a concrete technical model to implement these principles.

## 3. Mapping to ENISA Secure by Design

### 3.1 Lifecycle approach

ENISA emphasizes:
- security across the full lifecycle

TEA supports this by:
- defining a **commit process**
- enabling **long-term validation (10+ years)**
- preserving **historical state via evidence**

### 3.2 Software supply chain transparency

ENISA requires:
- visibility into components and dependencies

TEA enables this through:
- Evidence Bundles
- SBOM integration
- verifiable artifact provenance

### 3.3 Integrity and authenticity

ENISA requires:
- protection against tampering

TEA provides:
- cryptographic signatures
- canonical representations
- immutable commit model

### 3.4 Vulnerability management

ENISA highlights:
- tracking vulnerabilities over time

TEA enables:
- reconstruction of historical releases
- validation of affected components
- linkage between SBOM and evidence

## 4. Mapping to CISA Secure by Design

### 4.1 Ownership of security outcomes

CISA states:
- vendors must take responsibility

TEA enforces this by:
- requiring publishers to produce verifiable evidence
- making security properties auditable

### 4.2 Default security

CISA promotes:
- secure-by-default systems

TEA supports:
- validation-first consumption
- rejection of unverifiable artifacts

### 4.3 Transparency and accountability

CISA emphasizes:
- transparency in software behavior

TEA provides:
- transparency logs
- publicly verifiable records
- auditability of release events

## 5. Alignment with CRA (Cyber Resilience Act)

TEA directly supports CRA requirements:

### 5.1 Long-term support
- Evidence enables validation for 10+ years

### 5.2 SBOM requirements
- TEA integrates SBOMs into verifiable artifacts

### 5.3 Secure updates
- commit model ensures update integrity

### 5.4 Supply chain security
- evidence-based trust replaces implicit trust

## 6. Key contribution of TEA

ENISA and CISA describe *what* should be achieved.

TEA defines *how* to achieve it technically:

- Evidence-based trust model
- Commit-based release process
- Time-bound validation
- Transparency-backed verification

## 7. Summary

| Requirement | ENISA / CISA | TEA |
|------------|-------------|-----|
| Lifecycle security | Required | Commit + validation model |
| Supply chain transparency | Required | Evidence Bundles |
| Integrity | Required | Signatures + canonicalization |
| Long-term validation | Required | Timestamp-based model |
| Accountability | Required | Transparency logs |

## 8. Final statement

TEA operationalizes secure-by-design principles by turning them into:

> **verifiable, testable, and automatable security guarantees**
