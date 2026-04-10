# 📄 spec/cicd-authentication.md

# TEA CI/CD Authentication and Authorization Profile (v1.0)

---

## 1. Purpose

This document defines how CI/CD systems authenticate and are authorized when interacting with a TEA service.

It establishes:

* how pipelines obtain identities  
* how TEA services validate those identities  
* what CI/CD systems are allowed to do  
* what CI/CD systems MUST NOT be allowed to do  

---

## 2. Core Principle

> **CI/CD identity authorizes data submission, not trust establishment.**

CI/CD systems:

* MAY prepare and upload release data  
* MUST NOT establish trust  
* MUST NOT publish authoritative releases  

All trust-establishing actions remain:

* human-authorized  
* policy-controlled  
* auditable  

---

## 3. Separation of Identities (CRITICAL)

TEA defines two completely separate identities:

| Identity Type | Purpose | Lifetime |
|--------------|--------|----------|
| Signing identity | Signs artefacts and collections | Minutes–hours |
| CI/CD identity | Authenticates to TEA API | Short-lived or managed |

---

### Normative Requirement

Implementations MUST:

* treat CI/CD identity and signing identity as independent  
* MUST NOT derive trust from CI/CD identity  
* MUST NOT allow CI/CD identity to influence signature validation  

---

## 4. Supported Authentication Methods

TEA services MUST support at least one secure authentication mechanism.

### 4.1 OIDC Workload Identity (RECOMMENDED)

CI/CD platform issues a signed OIDC token.

TEA service:

* validates token  
* maps identity to authorization  

Advantages:

* no static secrets  
* short-lived tokens  
* strong binding to pipeline context  

---

### 4.2 Mutual TLS (mTLS)

CI/CD system authenticates using a client certificate.

Requirements:

* certificate MUST be issued by trusted CA  
* certificate identity MUST be mapped to TEA authorization  

---

### 4.3 Short-Lived Token via Identity Broker

CI/CD authenticates to a trusted system (e.g., Vault) and receives a short-lived token.

---

### 4.4 Static API Keys (NOT RECOMMENDED)

Allowed only for low-assurance environments.

Constraints:

* MUST be scoped  
* MUST be rotatable  
* MUST NOT allow commit operations  

---

## 5. OIDC Token Validation

When using OIDC, TEA services MUST perform the following validation.

---

### 5.1 Signature Validation

The TEA service MUST:

* verify JWT signature  
* use issuer JWKS  
* match `kid` to key  

Failure → MUST reject

---

### 5.2 Standard Claim Validation

The TEA service MUST validate:

* `iss` — matches trusted issuer  
* `aud` — matches TEA audience  
* `exp` — not expired  
* `nbf` — valid time window  
* `iat` — reasonable freshness  

Failure → MUST reject

---

### 5.3 Pipeline Identity Claims

The TEA service MUST validate claims identifying:

* project or repository  
* organization or namespace  
* branch, tag, or environment  
* workflow or pipeline identity  

---

### Example Policy

A TEA service MAY require:

* repository = `acme/widget`  
* ref = `refs/tags/v*`  
* workflow = `release`  
* environment = `production`  

---

### Normative Rule

A token that is valid cryptographically but does not match policy:

→ MUST be rejected

---

## 6. Token Exchange Model (RECOMMENDED)

Instead of using raw OIDC tokens directly:

1. CI/CD obtains OIDC token  
2. CI/CD sends token to TEA auth endpoint  
3. TEA validates token  
4. TEA issues short-lived TEA access token  

---

### Benefits

* tighter scope control  
* reduced exposure  
* simpler API authorization  

---

## 7. Authorization Model

---

### 7.1 Allowed Actions for CI/CD

CI/CD systems MAY:

* upload artefacts  
* upload TEA collection  
* upload signatures  
* upload timestamps  
* upload transparency evidence  

---

### 7.2 Forbidden Actions for CI/CD

CI/CD systems MUST NOT:

* commit releases  
* publish DNS trust anchors  
* modify trust models  
* override validation rules  
* bypass policy enforcement  

---

### 7.3 Commit Authorization

Only authorized actors MAY:

* finalize release  
* trigger DNS publication  

Requirements:

* strong authentication (e.g., MFA)  
* audit logging  
* explicit approval  

---

## 8. Tenant and Project Isolation

TEA services MUST:

* isolate projects/tenants  
* bind CI/CD identity to a specific project  
* prevent cross-project access  

---

### Normative Requirement

CI/CD identity MUST NOT:

* upload artefacts to other projects  
* access unrelated collections  

---

## 9. Token Properties

CI/CD tokens MUST be:

* short-lived (minutes preferred)  
* audience-restricted  
* scope-limited  
* non-reusable outside context  

---

### Recommended Constraints

* lifetime ≤ 10 minutes  
* single project scope  
* upload-only permissions  

---

## 10. Threat Model

---

### 10.1 Draft Injection

Threat:

* attacker uploads malicious draft data  

Mitigation:

* authenticated uploads  
* strict authorization  
* audit logging  

---

### 10.2 Privilege Escalation

Threat:

* CI/CD token used to commit release  

Mitigation:

* strict role separation  
* deny commit to CI/CD identities  

---

### 10.3 Token Leakage

Threat:

* token exposed in logs or environment  

Mitigation:

* short-lived tokens  
* no logging of secrets  
* minimal scope  

---

### 10.4 Cross-Tenant Access

Threat:

* pipeline accesses other project  

Mitigation:

* strict project binding  
* claim validation  

---

## 11. Audit Requirements

TEA services SHOULD log:

* CI/CD identity  
* project/tenant  
* timestamp of action  
* uploaded artefact digests  
* token issuer and subject  

---

## 12. Failure Handling

---

### MUST Reject

* invalid token signature  
* expired token  
* issuer mismatch  
* audience mismatch  
* policy mismatch  
* unauthorized action  

---

### SHOULD Reject

* suspicious token reuse  
* missing expected claims  

---

## 13. Minimal Implementation Requirements

TEA services MUST:

* validate authentication for all uploads  
* validate OIDC or equivalent identity  
* enforce authorization boundaries  
* prevent CI/CD from committing releases  

---

TEA services SHOULD:

* use OIDC workload identity  
* implement token exchange  
* enforce short token lifetimes  
* log all authentication events  

---

## 14. Example Flow (OIDC)

```text
CI/CD pipeline starts
→ obtains OIDC token from platform
→ sends token to TEA auth endpoint
→ TEA validates:
   - signature
   - issuer
   - audience
   - repository / workflow
→ TEA issues short-lived upload token
→ pipeline uploads draft artefacts
→ human reviews and commits
```

---

## 15. Final Rule

> **CI/CD systems may supply data, but must never be allowed to define trust.**

---

## ✅ Result

This profile ensures:

* secure pipeline authentication  
* strict separation of responsibilities  
* prevention of unauthorized publication  
* alignment with TEA trust architecture  
* compatibility with modern CI/CD platforms  

---