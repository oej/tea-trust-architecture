# 📘 TEA Glossary and Terminology (Normative)
**Version:** 1.2  
**Status:** Draft (Normative Reference)

---

## Table of Contents

- [1. Introduction](#1-introduction)
- [2. Normative Language](#2-normative-language)
- [3. Core Concepts](#3-core-concepts)
- [4. Identity Terms](#4-identity-terms)
- [5. Data Model Terms](#5-data-model-terms)
- [6. Enumeration Values](#6-enumeration-values)
- [7. Discovery Types](#7-discovery-types)
- [8. Trust and Evidence Terms](#8-trust-and-evidence-terms)
- [9. External Systems and Standards](#9-external-systems-and-standards)
- [10. Prohibited Terminology](#10-prohibited-terminology)
- [11. References](#11-references)

---

## 1. Introduction

This document defines normative terminology used across TEA specifications.

```text
All TEA specifications MUST use these terms consistently.
```

---

## 2. Normative Language

The key words:

```text
MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, MAY
```

are as defined in:

- RFC 2119  
- RFC 8174  

---

## 3. Core Concepts

### TEA

```text
A specification for publishing, discovering, and retrieving software supply chain metadata and artifacts.
```

---

### TEA Core

```text
The base specification covering identity, discovery, API, collections, and artifacts.
```

---

### TEA Trust Architecture

```text
An overlay adding signatures, timestamps, transparency, and trust anchors.
```

---

### Publisher (Authority)

```text
The entity controlling the domain used for discovery and publication.
```

---

### Consumer

```text
A system retrieving and validating TEA data.
```

---

## 4. Identity Terms

### TEI (Transparency Exchange Identifier)

```text
A URL-based identifier for a product, unique within a domain.
```

---

### Artifact Digest

```text
A SHA-256 hash identifying an artifact.
```

---

### Compliance Identifier

```text
An enumerated identifier describing a compliance document.
```

---

### Identity Domain

```text
A scope in which identifiers are defined (product, artifact, publisher).
```

---

## 5. Data Model Terms

### Artifact

```text
A binary or structured object that can be independently retrieved.
```

---

### Collection

```text
A versioned metadata document describing a release.
```

---

### Collection Version

```text
A specific revision of a collection.
```

---

### Release

```text
A version of a product identified by TEI.
```

---

### Lifecycle

```text
A standardized state of a product or release defined by CLE.
```

---

## 6. Enumeration Values

### 6.1 Compliance Document Types

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

### 6.2 Collection Update Reasons

```text
updated-vex-information
metadata-correction
spelling-fix
additional-context
other
```

---

### 6.3 Lifecycle Values (CLE / ECMA-428)

Examples:

```text
supported
end-of-support
end-of-security-updates
end-of-life
superseded
```

---

## 7. Discovery Types

```text
product
service
open-source-project
organization
```

---

## 8. Trust and Evidence Terms

### Signature

```text
A cryptographic operation using a private key from a key pair.
```

---

### Certificate

```text
An X.509 structure binding a public key to subject information.
```

---

### Timestamp

```text
A signed assertion proving that data existed at a specific time.
```

---

### TSA (Time Stamping Authority)

```text
A service that issues RFC 3161 timestamp tokens.
```

```text
Used for timestamping in the TEA trust architecture.
```

---

### Transparency Log

```text
An append-only system providing public visibility of signed data.
```

---

### Evidence Bundle

```text
A structured object containing signature, certificate, timestamp, and transparency evidence.
```

---

### Binding

```text
A cryptographic linkage between elements.
```

---

## 9. External Systems and Standards

### CA (Certificate Authority)

```text
An entity that issues and signs certificates.
```

---

### WebPKI

```text
The public certificate ecosystem used for TLS and HTTPS.
```

WebPKI includes:

- public Certificate Authorities  
- browser and operating system trust stores  
- certificate validation rules  

```text
WebPKI may be used as one option for document signing in the TEA trust architecture.
```

---

### PKI (Public Key Infrastructure)

```text
A general system for managing keys, certificates, and trust relationships.
```

---

### Rekor

```text
A transparency log system using Merkle trees and inclusion proofs.
```

```text
Used as a transparency system in the TEA trust architecture.
```

https://github.com/sigstore/rekor

---

### Sigsum

```text
A transparency log system using log signatures and witness cosigning.
```

```text
Used as a transparency system in the TEA trust architecture.
```

https://www.sigsum.org

---

### SCITT

```text
A framework for supply chain transparency using signed receipts.
```

https://datatracker.ietf.org/wg/scitt/

---

### DNSSEC

```text
A system for authenticated DNS data.
```

---

### CAA

```text
A DNS mechanism specifying allowed certificate authorities.
```

---

### X.509

```text
A standard for public key certificates.
```

---

### SHA-256

```text
A cryptographic hash function used for artifact identity.
```

---

## 10. Prohibited Terminology

### Artifact Identifier

```text
Artifacts are identified by digest only.
```

---

### Mutable Artifact

```text
Artifacts are immutable.
```

---

### Implicit Trust

```text
No object is trusted without validation.
```

---

## 11. References

- RFC 2119 — Normative Language  
- RFC 8174 — Normative Language Clarification  
- RFC 3986 — URI Syntax  
- RFC 4648 — Base64URL Encoding  
- RFC 5280 — X.509 Certificates  
- RFC 3161 — Time-Stamp Protocol  
- RFC 4033–4035 — DNSSEC  
- RFC 8659 — CAA  
- RFC 9110 — HTTP Semantics  
- FIPS 180-4 — SHA-256  
- ECMA-428 — Common Lifecycle Enumeration  

---