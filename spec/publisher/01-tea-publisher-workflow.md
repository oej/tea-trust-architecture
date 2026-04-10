# 📘 TEA Publisher Workflow
**Version:** 1.0  
**Status:** Draft (Normative, Implementation-Ready)

---

# Table of Contents

1. [Introduction](#1-introduction)  
2. [Purpose](#2-purpose)  
3. [Core Principles](#3-core-principles)  
4. [Workflow Phases](#4-workflow-phases)  
5. [Object State Model](#5-object-state-model)  
6. [TEA Artifact Lifecycle](#6-tea-artifact-lifecycle)  
7. [TEA Collection Workflow](#7-tea-collection-workflow)  
8. [Approval and Commit](#8-approval-and-commit)  
9. [CI/CD and Automation](#9-cicd-and-automation)  
10. [Archival](#10-archival)  
11. [Logging and Audit](#11-logging-and-audit)  
12. [Relationship to Evidence Bundles](#12-relationship-to-evidence-bundles)  
13. [Security Considerations](#13-security-considerations)  
14. [Final Statement](#final-statement)  

---

# 1. Introduction

This document defines the **TEA publisher workflow**, including:

- product and component setup  
- release preparation  
- TEA collection creation and publication  
- TEA artifact lifecycle management  
- approval and commit semantics  

This specification describes the **publisher-side behavior** required to ensure:

- controlled release publication  
- integrity of published data  
- long-term auditability  

Core data structures are defined in the TEA Consumer API and related specifications.  
This document defines how those objects are created, transitioned, and published.

 [oai_citation:0‡27-tea-publisher-workflow.md](sediment://file_000000009cc472469ac457802b5ac882)

---

# 2. Purpose

The TEA publisher workflow ensures that:

- releases are intentional and authorized  
- artifacts and collections are immutable once published  
- trust establishment is consistent with the TEA trust architecture  
- publication is auditable and reproducible  

---

# 3. Core Principles

## 3.1 Separation of Concerns

The workflow separates:

- product and component definition  
- release publication  
- trust establishment  

---

## 3.2 TEA Collection as Release Statement

A **TEA collection** is the authoritative statement describing:

- which TEA artifacts belong to a release  
- the metadata of that release  

A release is considered published **only when a collection is published**.

---

## 3.3 Immutability After Publication

Once an object participates in a published release:

- it MUST NOT be modified in a way that changes its meaning  
- it MUST remain available for long-term validation  

---

## 3.4 Consumer Visibility

Consumers:

- MUST only see published objects  
- MUST NOT see draft or intermediate states  

---

## 3.5 Controlled Publication Boundary

Publication is a **controlled operation**.

> CI/CD prepares — humans authorize — TEA commits

---

# 4. Workflow Phases

The publisher workflow consists of two primary phases:

---

## 4.1 Product Setup Phase

Defines long-lived objects:

- Product  
- Component  
- ProductRelease  
- ComponentRelease  
- Identifiers (TEI, CPE, PURL, etc.)  
- CLE (lifecycle information)  

These objects:

- are initially mutable  
- define identity and lifecycle context  

---

## 4.2 Release Publication Phase

Defines release-specific objects:

- TEA artifacts  
- TEA collections  
- collection versions  

This phase introduces:

- signing  
- evidence generation  
- validation  
- approval  
- publication  

---

# 5. Object State Model

## 5.1 Product, Component, and Releases

States:

- `draft`  
- `published`  
- `archived`  

Rules:

- objects MAY be modified or deleted in `draft`  
- objects MUST NOT be deleted after `published`  
- `archived` indicates retained but inactive  

---

## 5.2 TEA Collection

States:

- `draft`  
- `readyForSigning`  
- `signed`  
- `published`  

Rules:

- a collection becomes authoritative only in `published`  
- previously published collections remain valid  
- collections are immutable once published  

---

## 5.3 TEA Artifact

States:

- `draft`  
- `published`  
- `archived`  

Rules:

- draft artifacts are not visible to consumers  
- an artifact becomes published when referenced by a published collection  
- published artifacts MUST NOT be modified or deleted  

---

# 6. TEA Artifact Lifecycle

## 6.1 Upload

Artifacts are uploaded in `draft` state.

They:

- MAY be modified or deleted  
- MUST NOT be visible to consumers  

---

## 6.2 Inclusion in Collection

Artifacts MAY be referenced by:

- draft collections  
- published collections  

---

## 6.3 Publication

An artifact transitions to `published` when:

- it is referenced by at least one published collection  

---

## 6.4 Immutability

Artifacts referenced by published collections:

- MUST NOT be modified  
- MUST NOT be deleted  

---

## 6.5 Garbage Collection

Implementations MAY remove artifacts if:

- they are in `draft`  
- they are not referenced within a configured time  

Garbage collection MUST NOT remove:

- artifacts referenced by published collections  

---

# 7. TEA Collection Workflow

## 7.1 Creation

A collection is created for:

- a product release  
- or a component release  

---

## 7.2 Preparation

The collection is populated with:

- artifact references  
- metadata  
- version information  
- change rationale  

---

## 7.3 Ready for Signing

The collection transitions to:

- `readyForSigning`

Requirements:

- content MUST be deterministic  
- canonical representation MUST be used (RFC 8785)  

---

## 7.4 Evidence Bundle Generation

Before signing completion, implementations MUST generate **evidence bundles** for:

- each TEA artifact  
- the TEA collection  

Evidence bundles MUST include:

- signature  
- certificate  
- timestamp(s)  
- transparency evidence  

---

## 7.5 Signing

The collection is signed.

After signing:

- state becomes `signed`  

---

## 7.6 Validation

The TEA service MUST validate:

- evidence bundles  
- binding consistency  
- required trust model constraints  

---

## 7.7 Publication

After approval:

- the collection transitions to `published`  
- the associated release becomes published  

---

## 7.8 Versioning

If updates are required:

- a new collection version MUST be created  
- previous versions MUST remain published  

---

# 8. Approval and Commit

Publication requires:

- explicit approval  
- strong authentication (e.g., MFA)  

Implementations MAY require:

- multi-party approval  

---

## 8.1 Commit Step

The commit step:

- freezes the collection  
- validates all evidence  
- enforces policy  
- records approver identity and time  

---

## 8.2 Normative Requirements

The commit operation MUST:

- validate all evidence bundles  
- verify all bindings  
- enforce trust model requirements  
- reject incomplete or invalid evidence  

---

# 9. CI/CD and Automation

## 9.1 Allowed Operations

CI/CD MAY perform:

- artifact creation  
- artifact upload  
- collection preparation  
- signing  
- evidence bundle generation  

---

## 9.2 Restricted Operations

CI/CD MUST NOT perform:

- final publication (commit)  

---

## 9.3 Human-Controlled Boundary

Publication MUST require:

- human approval  
- authentication  

---

# 10. Archival

Objects MAY transition to `archived`.

Archival:

- is non-destructive  
- does not remove published data  

Archived objects:

- MUST remain accessible  

---

# 11. Logging and Audit

All workflow actions MUST be logged.

Each log entry MUST include:

- actor identity  
- timestamp  
- action  
- object type  
- object identifier  
- result  

Implementations SHOULD use standardized event identifiers.

---

# 12. Relationship to Evidence Bundles

Evidence bundles are central to publication.

---

## 12.1 Role

Evidence bundles:

- provide verifiable trust material  
- enable long-term validation  
- support offline verification  

---

## 12.2 Publication Requirement

All published TEA artifacts MUST have:

- a valid evidence bundle  

---

## 12.3 Reuse

Evidence bundles:

- MAY be reused across collections  
- MUST refer only to TEA artifacts  

---

# 13. Security Considerations

---

## 13.1 Controlled Publication

Unauthorized publication MUST be prevented through:

- authentication  
- approval  
- commit validation  

---

## 13.2 Ephemeral Keys

Signing keys SHOULD be:

- short-lived  
- generated per release  

---

## 13.3 Evidence Integrity

All trust depends on:

- correct evidence bundle generation  
- strict validation during commit  

---

# Final Statement

The TEA publisher workflow ensures that:

- releases are intentional  
- publication is controlled  
- artifacts and collections are immutable  
- trust is established through verifiable evidence  

---

## Key Principle

> Publication is not complete until evidence is validated and the collection is committed.
