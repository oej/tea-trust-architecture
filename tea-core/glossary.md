# 📘 TEA Terminology (Glossary)
**Version:** 1.0  
**Status:** Normative (Terminology Reference)

---

## Status

This document defines the terminology used across:

- TEA Core specifications  
- TEA Trust Architecture specifications  

It is **normative for terminology only**, and serves as a reference to ensure:

- consistent interpretation  
- aligned language across specifications  
- reduced ambiguity  

---

## 1. Introduction

The TEA ecosystem introduces a set of concepts spanning:

- software supply chain transparency  
- cryptographic verification  
- long-term validation  
- distributed trust models  

This glossary provides **precise and minimal definitions** for those concepts.

---

## 2. Terms and Definitions

---

### Artifact

A binary or structured object distributed via TEA.

Examples include:

- SBOMs  
- firmware images  
- configuration files  

Artifacts are:

- immutable  
- identified by digest  
- validated using evidence bundles (in the Trust Architecture)

---

### Certificate

A digital document binding a public key to metadata such as:

- validity period  
- DNS identity  

In TEA:

- certificates are short-lived  
- act as a validity wrapper for keys  
- do not represent long-term identity  

---

### Certificate Authority (CA)

An entity that issues digital certificates binding public keys to identities.

CAs are used in:

- WebPKI  
- private PKI systems  

---

### Collection

A structured object that defines a release by grouping artifacts.

A collection:

- references artifacts  
- includes metadata  
- does not prove artifact authenticity  

---

### Compliance Document

A document describing compliance, certification, or regulatory status of a manufacturer or project.

Compliance documents:

- are not tied to a specific product or release  
- are associated with the domain owner  
- are treated as standalone artifacts in the TEA Trust Architecture  

---

### CPE (Common Platform Enumeration)

A standardized identifier format for IT products, platforms, and versions.

In TEA, CPE may be used as an identifier type in API queries and object metadata.

---

### CSAF (Common Security Advisory Framework)

A standard for machine-readable security advisories.

CSAF documents provide structured information about:

- vulnerabilities  
- affected products  
- remediation guidance  

---

### Discovery Document

A document retrieved via the TEA discovery process that defines:

- API endpoints  
- service capabilities  

Discovery documents may be signed and timestamped in the Trust Architecture.

---

### Evidence Bundle

A structured object that contains all cryptographic evidence required to validate a TEA object.

It includes:

- signature  
- certificate  
- timestamp(s)  
- transparency evidence (Sigsum or Rekor)  

Evidence bundles are the **primary unit of trust** in the TEA Trust Architecture.

Evidence bundles:

- MUST be immutable  
- MAY be external and referenced via SHA-256 digest  
- MAY be reused ONLY for artifacts  

---

### Evidence Reuse

The reuse of an evidence bundle across multiple TEA objects.

In TEA:

- Evidence reuse is allowed ONLY for artifacts  
- Evidence MUST NOT be reused for collections  

---

### PKI (Public Key Infrastructure)

A system for issuing, managing, and validating digital certificates.

TEA does not define or require a full PKI.

---

### Rekor

A transparency log implementation developed by the Sigstore project.

Rekor provides:

- append-only logging of signed artifacts  
- inclusion proofs  
- public auditability  

---

### SBOM (Software Bill of Materials)

A structured inventory of software components within a product.

SBOMs describe:

- components  
- dependencies  
- versions  
- identifiers  

---

### Sigstore

An open-source project providing tools and services for signing and verifying software artifacts.

Sigstore includes:

- Rekor (transparency log)  
- Fulcio (certificate authority)  
- Cosign (signing tool)  

---

### Sigsum

A transparency log system designed for:

- minimal trust assumptions  
- witness-based verification  

Sigsum uses:

- append-only logs  
- witness cosigning  
- cryptographic proofs of inclusion  

---

### TEA (Transparency Exchange API)

A specification for exchanging software transparency information across the software supply chain.

TEA defines:

- APIs for publishing and retrieving artifacts  
- collections representing releases  
- discovery mechanisms using TEI  

---

### TEA Artifact

See **Artifact**.

---

### TEA Collection

See **Collection**.

---

### TEA Service

A service implementing TEA APIs for:

- publishing  
- discovery  
- retrieval  

---

### TEI (Transparency Exchange Identifier)

A URI-based identifier used to locate TEA services and resources.

A TEI:

- identifies a product  
- is scoped to a domain  
- may include an optional version parameter  

---

### Timestamp Authority (TSA)

A service that issues cryptographic timestamps proving that data existed at a specific point in time.

---

### Transparency Log

An append-only log that provides public verifiability of signing events.

Supported systems:

- Sigsum  
- Rekor  

---

### TAPS (Trust Anchor Publication Service)

A mechanism for publishing trust anchors using DNS.

---

### Trust Anchor

A root of trust used to validate certificates or signatures.

---

### UUID (Universally Unique Identifier)

A standardized 128-bit identifier used to uniquely identify TEA objects such as:

- products  
- product releases  
- components  
- component releases  
- collections  
- artifacts  

---

### VEX (Vulnerability Exploitability eXchange)

A document format describing the exploitability status of vulnerabilities in software.

VEX documents indicate whether a vulnerability:

- is exploitable  
- is not exploitable  
- has mitigations  

---

### WebPKI (Web Public Key Infrastructure)

A global system of certificate authorities used to establish trust in TLS connections.

In TEA:

- WebPKI MAY be used as a signing model  
- When WebPKI is used, evidence bundles are not included  

---

### X.509

A standard defining the format of public key certificates.

X.509 certificates are used to:

- bind public keys to identities  
- define validity periods  
- support cryptographic verification  

---

## 3. References

- RFC 2119 — Key words for use in RFCs to Indicate Requirement Levels  
  https://www.rfc-editor.org/rfc/rfc2119  

- RFC 8174 — Ambiguity of Uppercase vs Lowercase in RFC 2119 Keywords  
  https://www.rfc-editor.org/rfc/rfc8174  

- RFC 3986 — Uniform Resource Identifier (URI): Generic Syntax  
  https://www.rfc-editor.org/rfc/rfc3986  

- RFC 4648 — Base64URL Encoding  
  https://www.rfc-editor.org/rfc/rfc4648  

- RFC 5280 — Internet X.509 Public Key Infrastructure Certificate and CRL Profile  
  https://www.rfc-editor.org/rfc/rfc5280  

- RFC 3161 — Time-Stamp Protocol (TSP)  
  https://www.rfc-editor.org/rfc/rfc3161  

- RFC 4033–4035 — DNS Security Extensions (DNSSEC)  
  https://www.rfc-editor.org/rfc/rfc4033  
  https://www.rfc-editor.org/rfc/rfc4034  
  https://www.rfc-editor.org/rfc/rfc4035  

- RFC 8659 — DNS Certification Authority Authorization (CAA) Resource Record  
  https://www.rfc-editor.org/rfc/rfc8659  

- RFC 9110 — HTTP Semantics  
  https://www.rfc-editor.org/rfc/rfc9110  

- FIPS 180-4 — Secure Hash Standard (SHA-256)  
  https://csrc.nist.gov/publications/detail/fips/180/4/final  

- ECMA-428 — Common Lifecycle Enumeration (CLE)  
  https://ecma-international.org/publications-and-standards/standards/ecma-428/  

- ECMA-424 — CycloneDX (Software Bill of Materials)  
  https://ecma-international.org/publications-and-standards/standards/ecma-424/  

- ECMA-427 — Package URL (PURL)  
  https://ecma-international.org/publications-and-standards/standards/ecma-427/

## 4. Alphabetical Index

- [Artifact](#artifact)  
- [Certificate](#certificate)  
- [Certificate Authority (CA)](#certificate-authority-ca)  
- [Collection](#collection)  
- [Compliance Document](#compliance-document)  
- [CSAF (Common Security Advisory Framework)](#csaf-common-security-advisory-framework)  
- [Discovery Document](#discovery-document)  
- [Evidence Bundle](#evidence-bundle)  
- [Evidence Reuse](#evidence-reuse)  
- [PKI (Public Key Infrastructure)](#pki-public-key-infrastructure)  
- [Rekor](#rekor)  
- [SBOM (Software Bill of Materials)](#sbom-software-bill-of-materials)  
- [Sigstore](#sigstore)  
- [Sigsum](#sigsum)  
- [TEA (Transparency Exchange API)](#tea-transparency-exchange-api)  
- [TEA Artifact](#tea-artifact)  
- [TEA Collection](#tea-collection)  
- [TEA Service](#tea-service)  
- [TEI (Transparency Exchange Identifier)](#tei-transparency-exchange-identifier)  
- [Timestamp Authority (TSA)](#timestamp-authority-tsa)  
- [Transparency Log](#transparency-log)  
- [TAPS (Trust Anchor Publication Service)](#taps-trust-anchor-publication-service)  
- [Trust Anchor](#trust-anchor)  
- [VEX (Vulnerability Exploitability eXchange)](#vex-vulnerability-exploitability-exchange)  
- [WebPKI (Web Public Key Infrastructure)](#webpki-web-public-key-infrastructure)  
- [X.509](#x509)  

---

## Final Note

This glossary is intentionally:

- concise  
- consistent  
- aligned with TEA specifications  

Normative behavior is defined in the respective specification documents.
