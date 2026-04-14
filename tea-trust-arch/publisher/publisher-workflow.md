# TEA Trust Architecture — Publisher Workflow

## Status

- **Status**: Draft / Informational
- **Normative reference**: Publisher OpenAPI specification (to be defined)
- **Purpose**: Describe intended publisher workflows and guide implementation
- **Audience**: Software publishers, CI/CD engineers, security engineers, compliance teams

---

## Table of Contents

1. [Overview](#overview)
2. [Core Principles](#core-principles)
3. [Key Concepts](#key-concepts)
4. [Workflow Phases](#workflow-phases)
5. [Artifact Lifecycle](#artifact-lifecycle)
6. [Collection Lifecycle](#collection-lifecycle)
7. [CLE Lifecycle](#cle-lifecycle)
8. [Compliance Documents](#compliance-documents)
9. [Evidence and Validation](#evidence-and-validation)
10. [Commit and Publication](#commit-and-publication)
11. [Real-World Scenarios](#real-world-scenarios)
12. [Summary](#summary)

---

## Overview

This document describes how a publisher is expected to:

- prepare release artefacts  
- assemble collections  
- manage lifecycle statements (CLE)  
- associate compliance documentation  
- perform signing and validation  
- publish versioned data  

It is intended to:

- guide implementation of publisher systems  
- inform the design of the publisher OpenAPI  
- provide a shared mental model across stakeholders  

The **publisher OpenAPI specification will define the normative behavior**.

---

## Core Principles

### Stable Release Identity

A `productRelease` or `componentRelease` represents a **stable release identity**.

It typically corresponds to:

- a version (e.g. `1.2.3`)
- a release event
- a defined set of deliverables

This identity is expected to remain stable over time.

---

### Versioned Publication Streams

Several objects evolve over time independently of the release identity:

- collections  
- artefacts  
- CLE documents  
- compliance-document references  

New versions of these may be published without introducing a new software release.

---

### Immutability of Published Versions

Once published:

- a collection version is not modified  
- an artifact version is not modified  
- a CLE version is not modified  
- evidence bundles remain unchanged  

Updates are represented as **new versions**.

---

### Separation of Concerns

Typical separation:

- CI/CD prepares and signs  
- publisher system validates and stages  
- human approval gates publication  
- commit phase performs publication  

---

## Key Concepts

### Artifact

An artifact is a versioned object associated with a release.

Examples include:

- SBOM (CycloneDX, SPDX)  
- VEX documents  
- binaries  
- container references  

Artifacts are typically:

- signed  
- timestamped  
- logged in transparency systems  

---

### Collection

A collection is an **authoritative statement about a release**.

It aggregates:

- artifact references (by digest)  
- metadata  
- optional compliance references  

Consumers typically validate collections to understand the release.

---

### CLE (Common Lifecycle Enumeration)

CLE expresses lifecycle information such as:

- active  
- deprecated  
- end-of-life  
- vulnerable / mitigated  

CLE evolves over time and reflects operational reality rather than release creation.

---

### Compliance Documents

Compliance may be represented through:

- identifiers (e.g. ISO27001, SOC2)  
- document references  
- optionally as artifacts  

---

## Workflow Phases

### 1. Preparation (CI/CD)

Typical steps:

- build artifacts  
- generate SBOM  
- optionally generate VEX  
- compute digests  
- prepare signing inputs  

Example:

```text
build → sbom.json → vex.json → compute sha256
```

---

### 2. Artifact Creation

Artifacts are:

- prepared (raw or canonicalized JSON)  
- signed  
- timestamped  
- optionally logged  

Example:

```bash
sign-objects.sh --mode jcs sbom.json
```

---

### 3. Artifact Validation

Publisher systems typically validate:

- signature integrity  
- certificate validity  
- timestamp plausibility  
- transparency inclusion  

---

### 4. Collection Assembly

Collections are constructed using:

- artifact digests  
- release metadata  
- optional compliance references  

Example:

```json
{
  "artifacts": [
    {
      "type": "sbom",
      "digest": "sha256:abc123..."
    }
  ]
}
```

---

### 5. Collection Signing

The collection is:

- canonicalized  
- signed  
- timestamped  
- optionally logged  

---

### 6. Approval

A human approval step is commonly introduced to:

- confirm release correctness  
- validate compliance  
- approve publication  

---

### 7. Commit

Commit represents the transition from staged data to published data.

This may include:

- publishing collection versions  
- publishing artifact versions  
- publishing CLE updates  
- updating DNS trust anchors  

---

## Artifact Lifecycle

Artifacts are generally treated as immutable once published.

However, new versions may be introduced.

### Example: SBOM correction

```text
artifact: sbom.json
  v1 → initial version
  v2 → corrected version
```

A subsequent collection version may reference the corrected artifact.

---

## Collection Lifecycle

Collections evolve over time for a given release.

### Typical triggers

- VEX updates  
- corrected SBOM  
- additional artifacts  
- compliance updates  

### Example

```text
productRelease: 1.2.3

collection v1 → initial
collection v2 → SBOM corrected
collection v3 → VEX added
```

---

## CLE Lifecycle

CLE documents evolve independently of releases.

### Example

```text
CLE v1 → active
CLE v2 → vulnerable
CLE v3 → mitigated
```

Each version reflects a new lifecycle state.

---

## Compliance Documents

Compliance may be updated over time.

### Example

```text
collection v1 → no compliance
collection v2 → ISO27001 reference added
```

Or represented as artifact:

```text
artifact: iso27001-cert.pdf
collection references artifact
```

---

## Evidence and Validation

Typical elements:

- signature  
- timestamp  
- transparency proof  

Validation typically includes:

- signature verification  
- certificate validation  
- timestamp checks  
- inclusion proof verification  

---

## Commit and Publication

Commit is the point where data becomes visible to consumers.

Publication results in:

- new collection versions  
- new artifact versions  
- new CLE versions  

Previous versions remain accessible.

---

## Real-World Scenarios

### Missing artifact

```text
collection v1 → firmware only
collection v2 → firmware + SBOM
```

---

### VEX update

```text
collection v1 → no vulnerabilities
collection v2 → VEX added
```

---

### SBOM correction

```text
sbom v1 → incomplete
sbom v2 → corrected
collection v2 → references sbom v2
```

---

### Compliance update

```text
collection v1 → no compliance
collection v2 → ISO27001 reference
```

---

### Lifecycle change

```text
CLE v1 → active
CLE v2 → end-of-life
```

---

## Summary

This workflow describes a model where:

- release identities remain stable  
- collections, artifacts, CLE, and compliance evolve over time  
- updates are expressed as new versions  
- publication is controlled and auditable  

The publisher OpenAPI specification will formalize these concepts into a normative interface.