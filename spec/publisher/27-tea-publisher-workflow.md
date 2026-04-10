📘 TEA Publisher Workflow Overview (Updated)

Product Setup, Release Publication, and Lifecycle Management

⸻

1. Purpose

This document defines the publisher-side workflow for:
 * setting up products and components
 * managing releases
 * preparing and publishing collections
 * handling artefacts and CLE
 * enforcing lifecycle rules and immutability

It provides a conceptual model of objects, states, and transitions used by TEA publisher implementations.

Core object definitions are specified in the TEA Consumer API. This document describes how those objects are created, updated, and published.

⸻

2. Core Principles

2.1 Separation of Concerns

The workflow separates:
 * product definition
 * release publication
 * trust establishment

⸻

2.2 Collection as the Release Statement

A collection is the authoritative, versioned statement describing:
 * which artefacts belong to a release
 * the metadata of that release

A release is considered published only when a collection is published.

⸻

2.3 Immutability After Publication

Once an object participates in a published release:
 * it MUST NOT be modified in a way that changes published meaning
 * it MUST remain available for long-term validation

⸻

2.4 Consumer Visibility

Consumers:
 * see only published objects
 * do not see draft or intermediate workflow states

⸻

3. Workflow Phases

The publisher workflow consists of two main phases:

⸻

3.1 Product Setup Phase

Defines long-lived objects:
 * Product
 * Component
 * ProductRelease
 * ComponentRelease
 * Identifiers (TEI, CPE, PURL, etc.)
 * CLE

Objects in this phase are initially mutable.

⸻

3.2 Release Publication Phase

Defines release-specific transparency:
 * Artefacts
 * Collections
 * Collection versions

This phase introduces:
 * signing
 * validation
 * approval
 * publication

⸻

4. Object State Model

4.1 Product, Component, and Releases

States:
 * draft
 * published
 * archived

Rules:
 * objects MAY be modified or deleted in draft
 * objects MUST NOT be deleted after published
 * archived indicates retained but inactive

⸻

4.2 Collection

States:
 * draft
 * readyForSigning
 * signed
 * published

Rules:
 * a collection becomes authoritative only in published
 * older published collections remain published
 * no superseded state exists

⸻

4.3 Artifact

States:
 * draft
 * published
 * archived

Rules:
 * draft artifacts are not visible to consumers
 * an artifact becomes published when referenced by a published collection
 * published artifacts MUST NOT be modified or deleted

⸻

5. Artifact Lifecycle

5.1 Upload

Artifacts are uploaded in draft state.

They:
 * MAY be modified or deleted
 * are not visible to consumers

⸻

5.2 Inclusion in Collection

Artifacts may be referenced by:
 * draft collections
 * published collections

⸻

5.3 Publication

An artifact transitions to published when:
 * it is referenced by at least one published collection

⸻

5.4 Immutability

Artifacts referenced by published collections:
 * MUST NOT be modified
 * MUST NOT be deleted

⸻

5.5 Garbage Collection

Implementations MAY delete artifacts if:
 * they are in draft state
 * they are not included in any collection within a configured time

Garbage collection MUST NOT remove:
 * artifacts referenced by published collections

⸻

6. Collection Workflow

6.1 Creation

A collection is created for:
 * a product release
 * or a component release

⸻

6.2 Preparation

The collection is populated with:
 * artifact references
 * metadata
 * version information
 * reason for the collection version

⸻

6.3 Signing Preparation

The collection transitions to:
 * readyForSigning

At this point:
 * the content MUST be deterministic
 * a canonical signing payload is generated

⸻

6.4 Signing

The collection is signed externally or internally.

After signing:
 * state becomes signed

⸻

6.5 Validation and Upload

The signed collection and evidence are uploaded.

The TEA service validates:
 * signatures
 * evidence

⸻

6.6 Publication

After approval:
 * the collection transitions to published
 * the associated release becomes published

⸻

6.7 Collection Versioning

If updates are required:
 * a new collection version is created
 * previous versions remain published

⸻

7. Approval and Commit

Publication requires:
 * explicit approval
 * authentication (e.g., MFA)

Implementations MAY require:
 * multi-party approval (e.g., 2-of-N)

Commit:
 * freezes the collection
 * makes it authoritative

⸻

8. CI/CD and Automation

8.1 Automation Scope

CI/CD MAY handle:
 * artifact creation
 * artifact upload
 * collection creation
 * collection preparation
 * signing
 * draft upload

⸻

8.2 Restricted Operations

CI/CD SHOULD NOT perform:
 * final publication (commit)

⸻

8.3 Human-Controlled Boundary

Publication MUST require:
 * human approval
 * authentication

⸻

9. Archival

Objects MAY transition to archived.

Archival:
 * is non-destructive
 * does not remove published data

Archived objects:
 * remain accessible as required

⸻

10. Logging and Audit

All workflow actions MUST be logged.

Each log entry MUST include:
 * actor identity
 * timestamp
 * action
 * object type
 * object identifier
 * result

Implementations SHOULD use standardized event identifiers.

⸻

11. Summary

The TEA publisher workflow:
 * separates setup from publication
 * uses collections as authoritative release statements
 * ensures immutability of published data
 * controls publication through approval
 * exposes only published data to consumers
 * supports long-term retention and audit
