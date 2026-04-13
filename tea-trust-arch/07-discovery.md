# 📘 TEA Discovery Specification
**Version:** 1.0  
**Status:** Draft (Normative, Implementation-Ready)

---

## Status

This document defines the **TEA discovery mechanism**, including:

- how a client starts from a **TEI (Transparency Exchange Identifier)**
- how discovery endpoints are located
- how discovery metadata is structured and validated
- how trust is established for discovery responses

This specification applies to:

- **base TEA**
- **TEA with the Trust Architecture (overlay)**

The key words **MUST**, **SHOULD**, and **MAY** are to be interpreted as described in:

- RFC 2119
- RFC 8174

---

## Table of Contents

1. [Introduction](#1-introduction)  
2. [Transparency Exchange Identifier (TEI)](#2-transparency-exchange-identifier-tei)  
3. [Discovery Flow Overview](#3-discovery-flow-overview)  
4. [Discovery Endpoint Resolution](#4-discovery-endpoint-resolution)  
5. [Discovery Document](#5-discovery-document)  
6. [API Endpoints](#6-api-endpoints)  
7. [Transport Security](#7-transport-security)  
8. [Trust Models](#8-trust-models)  
9. [Discovery Signatures and Evidence](#9-discovery-signatures-and-evidence)  
10. [Timestamp Semantics](#10-timestamp-semantics)  
11. [Transparency Logs](#11-transparency-logs)  
12. [DNS and DNSSEC Considerations](#12-dns-and-dnssec-considerations)  
13. [Validation Process](#13-validation-process)  
14. [Error Conditions](#14-error-conditions)  
15. [Security Considerations](#15-security-considerations)  
16. [Normative References](#16-normative-references)  
17. [Informative References](#17-informative-references)  

---

## 1. Introduction

The TEA discovery mechanism provides a standardized way for a consumer to locate:

- TEA API endpoints
- trust metadata
- publisher-controlled service configuration

Discovery is the **entry point into a TEA ecosystem**.

Unlike many systems, TEA discovery is designed to support both:

- simple deployments (base TEA)
- strongly verifiable deployments (TEA Trust Architecture)

A key design goal is:

> Discovery should provide reliable service location while allowing independent verification of trust.

---

## 2. Transparency Exchange Identifier (TEI)

Discovery always begins with a **TEI (Transparency Exchange Identifier)**.

The TEI identifies a **product or service namespace**, not a specific release.

### 2.1 TEI format

A TEI is expressed as a URI:

```text
tei://<authority>/<type>/<base64url-identifier>
```

### 2.2 Example

```text
tei://example.com/product/YWJjMTIz
```

### 2.3 Semantics

- `<authority>`: DNS domain used for discovery
- `<type>`: identifier type (e.g. product)
- `<identifier>`: vendor-controlled identifier, base64url-encoded

### 2.4 Important property

The TEI deliberately reuses **vendor-controlled identifiers**.

TEA does not require creation of new identifiers when existing ones are available.

---

## 3. Discovery Flow Overview

The discovery process follows these steps:

1. **Start with TEI**
2. Extract the authority domain
3. Resolve DNS for the domain
4. Retrieve the `.well-known` discovery document
5. Validate transport security (TLS)
6. Optionally validate signature and evidence
7. Extract API endpoints

### 3.1 High-level flow

```text
TEI → DNS → HTTPS GET /.well-known/tea → Discovery Document → API Endpoints
```

---

## 4. Discovery Endpoint Resolution

The discovery document is located at:

```text
https://<authority>/.well-known/tea
```

### 4.1 DNS resolution

DNS resolution:

- MAY return IPv4 and/or IPv6
- MAY use modern DNS mechanisms such as:
  - HTTPS (SVCB) records
  - service binding records

These follow standard DNS resolution behavior.

### 4.2 Redirects

The discovery document MAY indicate API endpoints hosted on:

- the same domain
- a different domain

Important:

> Discovery and API hosting domains may differ.

Trust decisions must account for this separation.

---

## 5. Discovery Document

The discovery document is a JSON object describing:

- API endpoints
- supported features
- trust model indicators
- optional signature and evidence references

### 5.1 Example

```json
{
  "tei": "tei://example.com/product/YWJjMTIz",
  "apiEndpoints": {
    "consumer": "https://api.example.net/consumer",
    "publisher": "https://api.example.net/publisher"
  },
  "trustModel": "tea-trust",
  "signature": {
    "uri": "https://example.com/discovery.sig"
  },
  "evidenceBundle": {
    "uri": "https://example.com/discovery.bundle.json",
    "digest": {
      "algorithm": "sha-256",
      "value": "BASE64URL_DIGEST"
    }
  }
}
```

---

## 6. API Endpoints

The discovery document MUST define **API endpoints**.

Typical endpoints include:

- consumer API
- publisher API

### 6.1 Naming

The term **API endpoints** MUST be used instead of generic "endpoints" to avoid ambiguity.

### 6.2 Flexibility

Endpoints MAY:

- reside on different domains
- be hosted by third parties
- change over time

The discovery document is therefore the authoritative mapping.

---

## 7. Transport Security

### 7.1 TLS requirement

The discovery document MUST be retrieved over HTTPS.

TLS provides:

- confidentiality
- integrity
- server authentication (via WebPKI)

### 7.2 Important limitation

TLS only protects the **transport session**, not long-term trust.

Therefore:

> TLS is necessary but not sufficient for trust in TEA.

---

## 8. Trust Models

TEA supports multiple trust models.

### 8.1 Base TEA

- relies on TLS
- optional signatures
- no strict long-term validation requirements

### 8.2 TEA Trust Architecture

- requires signed discovery documents
- requires timestamps
- may include transparency evidence
- enables long-term validation

### 8.3 WebPKI considerations

Even in WebPKI mode:

- DNS MAY include CAA records
- DNS MAY be DNSSEC protected

This strengthens trust in certificate issuance.

---

## 9. Discovery Signatures and Evidence

### 9.1 Optional in base TEA

Discovery documents MAY include:

- detached signatures
- evidence bundles

### 9.2 Required in TEA Trust Architecture

In TEA with the Trust Architecture:

- discovery documents SHOULD be signed
- discovery MUST include a timestamp
- evidence bundles SHOULD be provided

### 9.3 Evidence bundle structure

The evidence bundle contains:

- signature
- certificate (containing public key)
- timestamp evidence
- optional transparency log inclusion proof

---

## 10. Timestamp Semantics

### 10.1 Requirement

In TEA with the Trust Architecture:

> Discovery responses MUST include a signed timestamp.

### 10.2 What a timestamp proves

A timestamp proves:

- the discovery document existed at a specific point in time
- the signature existed at that time

### 10.3 Trust model

Timestamps rely on:

- trusted timestamp authorities (TSAs)
- cryptographic binding to the signed content

### 10.4 Rationale

Timestamps:

- prevent backdating attacks
- support long-term validation
- provide temporal ordering of discovery states

---

## 11. Transparency Logs

### 11.1 Optional mechanism

Transparency logs MAY be used for discovery documents.

Supported models include:

- Rekor
- Sigsum
- SCITT

### 11.2 What transparency provides

Transparency logs provide:

- append-only logging
- public verifiability
- detection of equivocation

### 11.3 Trust model

Trust comes from:

- log integrity
- inclusion proofs
- witness models (e.g. Sigsum)

### 11.4 Important note

Transparency is **optional** and **profile-driven**, not mandatory.

---

## 12. DNS and DNSSEC Considerations

### 12.1 DNS role

DNS is used for:

- discovery entry point
- trust anchor publication (in TEA Trust Architecture)
- WebPKI strengthening via CAA records

### 12.2 DNSSEC

DNSSEC is:

- OPTIONAL
- RECOMMENDED

DNSSEC provides:

- authenticated DNS responses
- protection against DNS spoofing

### 12.3 Limitation

DNSSEC does not replace:

- signatures
- timestamps
- evidence bundles

---

## 13. Validation Process

A TEA consumer validates discovery as follows:

### 13.1 Base TEA

1. Resolve DNS
2. Fetch discovery document over HTTPS
3. Validate TLS certificate
4. Parse API endpoints

### 13.2 TEA Trust Architecture

1. Perform base TEA steps
2. Validate discovery signature
3. Validate timestamp
4. Validate evidence bundle (if present)
5. Optionally validate transparency inclusion
6. Apply policy checks

---

## 14. Error Conditions

Validation MUST fail when:

- TLS validation fails
- discovery document is malformed
- signature validation fails (when required)
- timestamp is missing or invalid
- evidence bundle digest mismatch occurs

Example error identifiers:

- `DISCOVERY_TLS_FAILURE`
- `DISCOVERY_SIGNATURE_INVALID`
- `DISCOVERY_TIMESTAMP_MISSING`
- `DISCOVERY_EVIDENCE_DIGEST_MISMATCH`

---

## 15. Security Considerations

Discovery is a critical trust boundary.

Common risks include:

### 15.1 Domain compromise

If the authority domain is compromised:

- discovery responses may be replaced
- endpoints may be redirected

Mitigation:

- signatures
- timestamps
- transparency logs

### 15.2 API endpoint substitution

A malicious discovery document could point to:

- attacker-controlled API endpoints

Mitigation:

- signed discovery
- evidence validation

### 15.3 DNS attacks

Without DNSSEC:

- DNS responses may be spoofed

Mitigation:

- DNSSEC (optional)
- signature validation

### 15.4 Trust confusion

Implementers must not assume:

- TLS alone is sufficient for long-term trust
- discovery implies artifact authenticity

---

## 16. Normative References

- RFC 2119 — Key words for use in RFCs
- RFC 8174 — Ambiguity of uppercase/lowercase requirement terms
- RFC 5280 — X.509 Public Key Infrastructure
- RFC 8555 — ACME (relevant for certificate issuance context)
- RFC 6844 — CAA Records
- RFC 4033–4035 — DNSSEC
- RFC 8785 — JSON Canonicalization Scheme

---

## 17. Informative References

- TEA Trust Architecture Core Specification
- TEA Evidence Bundle Specification
- TEA Evidence Validation Specification
- Rekor Transparency Log
- Sigsum Transparency Log
- IETF SCITT Architecture

---

## Final Statement

Discovery answers the question:

> **Where are the TEA services for this identifier?**

Trust architecture answers:

> **Can those answers be trusted over time?**

Both are required for a complete TEA system.
