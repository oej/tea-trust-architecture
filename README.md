# 📘 Transparency Exchange API (TEA)

## Status

The Transparency Exchange API (TEA) supports **automation of software and systems transparency for the software supply chain**.

It enables organizations to:

- publish and distribute **Software Bills of Materials (SBOMs)**  
- share **VEX (Vulnerability Exploitability eXchange)** information  
- expose software artifacts and related metadata  
- correlate components with known vulnerabilities  
- support compliance and regulatory reporting  

TEA is designed to support modern software supply chains, including:

- manufacturers  
- open source projects  
- integrators  
- operators and consumers  

---

## Purpose

TEA provides a standardized mechanism to enable:

- **machine-readable transparency data exchange**  
- **automation of vulnerability management workflows**  
- **traceability across products, components, and releases**  
- **consistent access to SBOM and security-related artifacts**  

This supports regulatory and operational requirements such as:

- EU Cyber Resilience Act (CRA)  
- vulnerability disclosure and handling processes  
- long-term software maintenance and auditability  

---

## Specification Structure

The TEA specification is composed of three main parts:

```text
tea-core/          → Core specification (identifiers, discovery, concepts)
OpenAPI            → Normative API and data model
tea-trust-arch/    → Trust architecture (optional overlay)
profiles/          → Trust profiles and cryptographic constraints
```

---

## 1. TEA Core Specification (`tea-core/`)

The `tea-core/` directory contains the **primary human-readable specification** for TEA.

It defines:

- the **Transparency Exchange Identifier (TEI)**  
- the **discovery mechanism**  
- the **conceptual data model**  
- the **API interaction model**  
- lifecycle and versioning concepts  
- compliance document handling  

These documents provide:

- explanatory context  
- architectural rationale  
- implementation guidance  

### Important role

```text
tea-core/ is the authoritative descriptive specification of TEA,
excluding the formal API schema.
```

Together, the documents in `tea-core/` form a **complete conceptual reference** for TEA.

---

## 2. OpenAPI Specification (Normative API + Data Model)

The OpenAPI specification (located in the repository under `spec/openapi.yaml`) is:

> **Normative for both the API behavior and the data model**

It defines:

### API behavior

- endpoints  
- request/response formats  
- filtering, pagination, and retrieval  

### Data structures

- products and product releases  
- components and component releases  
- collections  
- artifacts (including SBOM, VEX, binaries, documents)  
- compliance documents  
- enum types  
- lifecycle propagation using CLE (ECMA-428)  

### Key relationship

```text
tea-core/:
Explains the model

OpenAPI:
Defines the exact schema and wire format
```

Both are required for a complete implementation.

---

## 3. TEA Trust Architecture (`tea-trust-arch/`, `profiles/`)

The TEA Trust Architecture is an **optional overlay** that adds:

- signatures  
- certificates  
- timestamps  
- transparency logs (Sigsum, Rekor)  
- DNS-based trust anchoring  
- evidence bundles and validation  

This is defined in:

```text
tea-trust-arch/
profiles/
```

### Important distinction

```text
TEA Core:
Defines WHAT is published and HOW it is accessed

TEA Trust Architecture:
Ensures HOW data is delivered and validated cryptographically
```

---

### Trusted Delivery vs Trusted Content

The TEA Trust Architecture provides **trusted delivery**, not **trusted content**.

It enables a consumer to verify that:

- the artifact has not been modified  
- the artifact was published by a specific signing identity  
- the artifact existed at a provable point in time  
- the artifact is included in a transparency system (if applicable)  

However, it does **not** guarantee that:

- the contents of the artifact are correct  
- the SBOM is complete  
- vulnerability statements are accurate  
- compliance claims are valid  
- the publisher is trustworthy in a legal or operational sense  

### Interpretation

The strongest valid statement is:

```text
"This exact artifact was produced by this identity and existed at this time."
```

It is **not valid** to conclude:

```text
"This artifact is correct, complete, or trustworthy in its claims."
```

### Why this matters

This separation ensures that:

- TEA remains **technically verifiable without making semantic claims**  
- responsibility for correctness remains with the publisher  
- consumers can apply **independent policy and validation logic**  
- the system avoids false assurances about software security  

---

The trust architecture is not required to implement TEA, but is necessary for:

- long-term validation  
- regulatory compliance (e.g. CRA)  
- supply chain integrity assurance  

---

## Design Principles

TEA is designed around a strict separation of concerns:

### 1. Separation of data and trust

- Core specification contains **no cryptographic requirements**  
- Trust architecture is **fully decoupled**  

### 2. Automation-first design

- APIs enable machine-to-machine interaction  
- structured data supports automated processing  
- lifecycle tracking enables continuous monitoring  

### 3. Reuse of existing identifiers

- TEI allows reuse of manufacturer-defined identifiers  
- no requirement to introduce new identifier systems  

### 4. Lifecycle-first model

- releases are versioned and comparable  
- lifecycle states follow **CLE (ECMA-428)**  

### 5. Long-term operability

- data model is stable and independent of trust mechanisms  
- trust can evolve without breaking the core specification  

---

## Typical Workflows Supported by TEA

TEA enables automation of common software supply chain workflows:

### SBOM distribution

- publish SBOMs per release  
- retrieve SBOMs for validation or analysis  

### Vulnerability correlation

- link SBOM components to vulnerability databases  
- distribute VEX statements to clarify exploitability  

### Release tracking

- compare versions of collections  
- identify changes between releases  

### Compliance reporting

- publish organizational compliance documents  
- support audit and regulatory processes  

---

## When to Use Each Part

### Use TEA Core + OpenAPI

When you need:

- automation of transparency data exchange  
- interoperability across tools and organizations  
- lifecycle-aware software metadata  

### Add Trust Architecture

When you need:

- verifiable integrity  
- long-term auditability  
- regulatory compliance  
- supply chain security guarantees  

---

## Summary

TEA provides a complete model for **automated software transparency in the software supply chain**:

```text
TEI + Discovery        → locating services  
OpenAPI               → interacting with services and data structures  
tea-core/             → understanding the model and architecture  
tea-trust-arch/       → securing and validating the data (optional)  
```

This layered approach enables:

- automation at scale  
- interoperability across ecosystems  
- traceability and auditability  
- long-term evolution of both data and trust models
