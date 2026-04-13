# 📄 spec/api-authentication.md

# TEA API Authentication and Authorization Profile (v1.0)

---
## Status

This document defines authentication and authorization requirements for TEA APIs.

It applies to:

- Consumer API (read access)  
- Publisher API (write and commit operations)  

This specification is:

- **Normative** for API access control  
- Applicable to both **base TEA** and the **TEA Trust Architecture (overlay)**  

The key words **MUST**, **SHOULD**, and **MAY** are to be interpreted as described in:

- RFC 2119  
- RFC 8174  

---

## 1. Purpose

This document defines authentication and authorization requirements for TEA APIs.

It covers:

* Consumer API (read access)
* Publisher API (write and commit operations)

It aligns with:

* TEA Trust Architecture  
* CI/CD Authentication Profile  
* TEA Validation Policy  

---

## 2. Core Principle

> **Access to TEA APIs does not imply trust in artefacts.**

Authentication controls:

* who may read or write data  

Trust validation controls:

* whether data is correct and valid  

These MUST remain independent.

---

### Authentication vs Authorization

TEA distinguishes between:

- **Authentication** — who is making the request  
- **Authorization** — what that identity is allowed to do  

Authentication MAY be provided by:

- OAuth2 / OIDC tokens  
- Mutual TLS (mTLS)

Authorization is derived from:

- token claims (if present), or  
- the authenticated identity (token subject or client certificate)

Authentication alone does NOT grant permission to perform operations.

---

## 3. API Roles

TEA defines three distinct roles:

| Role | Description |
|------|------------|
| Consumer | Reads and validates data |
| Publisher (CI/CD) | Uploads draft data |
| Publisher (Human) | Commits and authorizes releases |

---

## 4. Consumer API Authentication

---

### 4.1 Default Model

The Consumer API SHOULD support:

* unauthenticated read access  

Rationale:

* TEA artefacts are intended for distribution  
* trust is established cryptographically, not via access control  

---

### 4.2 Optional Authentication

Consumer API MAY require authentication for:

* rate limiting  
* access control  
* premium or private feeds  

Supported methods:

* OAuth2 / OIDC  
* mTLS  

---

### 4.3 Critical Rule

> Consumers MUST NOT rely on API authentication as a trust signal.

Even authenticated responses:

* MUST be fully validated using TEA validation rules  

---

## 5. Publisher API Authentication

Publisher API requires strict authentication and authorization.

---

### 5.1 Identity Types

Publisher API supports two identity classes:

| Identity | Purpose |
|----------|--------|
| CI/CD identity | Upload draft data |
| Human identity | Commit and authorize releases |

---

### 5.2 Separation Requirement

Implementations MUST:

* strictly separate CI/CD and human identities  
* enforce different permissions  

---

## 6. CI/CD Authentication (Publisher API)

---

### 6.1 Required Model

CI/CD authentication MUST follow:

→ `spec/cicd-authentication.md`

---

### 6.2 Allowed Methods

* OIDC workload identity (RECOMMENDED)  
* mTLS  

---

### 6.3 Required Properties

CI/CD authentication MUST:

* be short-lived  
* be scoped to a project  
* be restricted to upload operations  

---

### 6.4 Allowed Operations

CI/CD MAY:

* upload artefacts  
* upload TEA collection  
* upload signatures  
* upload timestamps  
* upload transparency evidence  

---

### 6.5 Forbidden Operations

CI/CD MUST NOT:

* commit releases  
* publish DNS trust anchors  
* modify trust models  
* override validation rules  

---

## 7. Human Authentication (Publisher API)

---

### 7.1 Requirements

Commit operations MUST require:

* strong authentication (MFA REQUIRED)  
* identifiable user identity  
* authorization for specific project  

---

### 7.2 Allowed Operations

Human users MAY:

* review draft releases  
* commit releases  
* trigger DNS publication  
* approve trust model usage  

---

### 7.3 Audit Requirements

Commit operations MUST:

* record user identity  
* record timestamp  
* record release identifier  
* record approval decision  

---

## 8. Authorization Model

---

### 8.1 Role-Based Authorization

TEA services MUST implement role-based authorization:

| Role | Permissions |
|------|------------|
| Consumer | read-only |
| CI/CD | upload-only |
| Publisher | commit + approval |

---

### 8.2 Project Binding

All identities MUST be bound to:

* a specific project or tenant  

---

### Normative Requirement

An identity MUST NOT:

* access or modify other projects  

---

## 9. Token Handling

---

### 9.1 Token Properties

Tokens MUST be:

* short-lived  
* audience-restricted  
* scoped  
* non-reusable outside context  

---

### 9.2 Token Exchange (Recommended)

For OIDC:

1. CI/CD obtains OIDC token  
2. TEA validates token  
3. TEA issues short-lived internal token  

---

## 10. Endpoint Protection

---

### 10.1 Consumer API Endpoints

| Endpoint Type | Auth Requirement |
|--------------|-----------------|
| Read artefacts | MAY be public |
| Read collections | MAY be public |

---

### 10.2 Publisher API Endpoints

| Endpoint | Auth Required |
|----------|--------------|
| Upload artefact | REQUIRED |
| Upload collection | REQUIRED |
| Upload evidence | REQUIRED |
| Commit release | REQUIRED (human only) |
| DNS publish | REQUIRED (human only) |

---

## 11. Threat Model

---

### 11.1 Unauthorized Upload

Threat:

* attacker uploads draft data  

Mitigation:

* authenticated CI/CD identity  
* scoped permissions  

---

### 11.2 Unauthorized Commit

Threat:

* pipeline commits release  

Mitigation:

* human-only commit enforcement  
* MFA  

---

### 11.3 Token Leakage

Threat:

* token exposed  

Mitigation:

* short lifetime  
* minimal scope  

---

### 11.4 Cross-Tenant Access

Threat:

* project boundary violation  

Mitigation:

* strict project binding  

---

## 12. Failure Handling

---

### MUST Reject

* missing authentication  
* invalid token  
* unauthorized role  
* forbidden operation  

---

### SHOULD Reject

* suspicious activity  
* token misuse  

---

## 13. Minimal Requirements

TEA services MUST:

* authenticate all publisher API requests  
* enforce role separation  
* prevent CI/CD from committing releases  
* bind identities to projects  

---

TEA services SHOULD:

* support OIDC workload identity  
* implement token exchange  
* log all authentication events  

---

## 14. Final Rule

> **Authentication controls access — evidence establishes trust.**

Authorization controls which operations are permitted but does not establish trust in artefacts.

---

## ✅ Result

This model ensures:

* secure API access control  
* strict role separation  
* alignment with TEA trust architecture  
* compatibility with modern CI/CD systems  
* protection against unauthorized publication  

---