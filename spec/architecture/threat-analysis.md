# TEA Threat Analysis (STRIDE)  

Full Security Assessment of the TEA Trust Architecture

## Status

This document is informative and provides a STRIDE-based threat analysis
of the TEA Trust Architecture.

Normative requirements derived from this analysis are specified in:
- TEA Core Trust Architecture
- Evidence Validation Specification
- Validation Policy Specification

---

## 1. Scope

This threat analysis applies to the three TEA trust domains:

1. Discovery — locating and trusting TEA service endpoints  
2. Consumer validation — verifying collections and artefacts  
3. Publication — ensuring authorized release of artefacts and collections  

It also covers cross-cutting dependencies:

* DNS and optional DNSSEC  
* WebPKI  
* Timestamp Authorities (TSAs, RFC 3161)  
* Transparency logs (e.g., Rekor, Sigsum; SCITT MAY be supported in future implementations)  
* CI/CD systems and approval workflows  

---

## 2. Methodology

This document applies the STRIDE threat model:

* **S — Spoofing**: Impersonation of identity  
* **T — Tampering**: Unauthorized modification  
* **R — Repudiation**: Denial of actions  
* **I — Information Disclosure**: Exposure of sensitive data  
* **D — Denial of Service**: Disruption of availability  
* **E — Elevation of Privilege**: Unauthorized escalation of control  

---

## 3. Assets and Trust Boundaries

### 3.1 Assets

The following assets are protected by the TEA trust architecture:

* discovery document  
* TEA collection  
* artefacts  
* signatures  
* certificates  
* timestamps  
* transparency receipts  
* DNS-published trust anchors  
* publication approval records  
* lifecycle (CLE) documents  

---

### 3.2 Trust Boundaries

Key trust boundaries include:

* consumer ↔ network  
* consumer ↔ TEA service  
* TEA service ↔ CI/CD system  
* TEA service ↔ DNS  
* TEA service ↔ TSA  
* TEA service ↔ transparency system  
* human approver ↔ commit workflow  

---

## 4. Architectural Security Principle

TEA security depends on the consistency of independent evidence layers:

* signatures  
* timestamps  
* transparency systems  
* DNS or PKI trust anchors  

A failure in one layer may be mitigated by others.

However:

> **The most critical failure mode is a validly signed but unauthorized release.**

Authorization at publication time is therefore the root of trust.

TEA ensures trusted delivery and verifiable provenance of artifacts, but does not guarantee that artifact content is free from vulnerabilities.

---

## 5. Discovery Threat Analysis

### 5.1 Spoofing

#### Threats
* DNS poisoning redirects to malicious TEA service  
* WebPKI mis-issuance enables attacker-controlled TLS endpoint  
* malicious `.well-known/tea` served over valid TLS  
* third-party TEA service impersonates manufacturer  
* replay of stale discovery document  

#### Impact
* incorrect endpoint selection  
* compromised trust bootstrap  
* attacker-controlled artefacts accepted  

#### Mitigations
* TLS validation REQUIRED  
* discovery signature REQUIRED  
* discovery timestamp REQUIRED  
* schema validation REQUIRED  
* DNS publication MAY support validation when DNS is used according to this trust model  
* DNSSEC strengthens DNS integrity when present  
* replay protection via timestamp validation  

#### Residual Risk
* WebPKI CA compromise  
* first-contact exposure prior to validation completion  

---

### 5.2 Tampering

#### Threats
* modification of discovery document in transit  
* CDN or proxy manipulation  
* replay of stale discovery content  

#### Mitigations
* TLS integrity protection  
* signature validation  
* timestamp prevents undetected replay  
* optional transparency logging enables audit  

#### Residual Risk
* parser inconsistencies  
* canonicalization mismatches  

---

### 5.3 Repudiation

#### Threats
* manufacturer denies discovery publication  

#### Mitigations
* signed discovery document  
* timestamp provides verifiable time  
* transparency logs provide audit trail  

#### Residual Risk
* compromise during short-lived key validity window  

---

### 5.4 Information Disclosure

Discovery data is typically public and low sensitivity.  
No significant additional risks introduced.

---

### 5.5 Denial of Service

#### Threats
* TEA service unavailability  
* DNS resolution failure  
* TSA dependency for discovery signing  

#### Mitigations
* caching of discovery documents  
* retry logic  
* pre-publication validation  

---

### 5.6 Elevation of Privilege

#### Threats
* unauthorized modification of discovery data at source  

#### Mitigations
* signature verification  
* controlled publication workflows  

---

## 6. Consumer Trust Threat Analysis

### 6.1 Spoofing

#### Threats
* forged certificates  
* attacker-controlled artefacts  
* substitution of valid but unrelated artefacts  

#### Mitigations
* signature validation  
* checksum binding inside signed collection  
* When DNS is used according to this trust model:
  * DNS publication REQUIRED  
  * DNSSEC strengthens authenticity  
* WebPKI:
  * PKIX validation REQUIRED  
  * DNS not a trust anchor  
  * CAA provides policy signal  

---

### 6.2 Tampering

#### Threats
* modification of artefacts or collections  
* substitution attacks  

#### Mitigations
* collection signature integrity  
* checksum binding  
* artefact signatures (when present)  
* timestamps protect temporal integrity  
* transparency logs provide visibility  

---

### 6.3 Repudiation

#### Threats
* publisher denies releasing artefact or collection  

#### Mitigations
* signed collections  
* timestamp provides verifiable signing time  
* transparency provides public auditability  

---

### 6.4 Information Disclosure

TEA does not inherently introduce new disclosure risks.  
Artefacts are typically intended for distribution.

---

### 6.5 Denial of Service

#### Threats
* unavailability of TEA service  
* TSA or transparency service outage  

#### Mitigations
* evidence bundles enable offline validation  
* caching of artefacts and metadata  
* redundancy of external services  

---

### 6.6 Elevation of Privilege

#### Threats
* bypass of validation logic  

#### Mitigation

> **Partial validation is equivalent to validation failure and MUST NOT be accepted.**

---

### 6.7 Timestamp Role (Critical)

Timestamps are a core trust component:

* prove signature existed at a specific time  
* enable validation after certificate expiry  
* prevent backdating  

Validation MUST ensure:

* timestamp signature validity  
* timestamp within certificate validity window  
* correct binding to the signature  

---

### 6.8 Lifecycle (CLE) Integrity

#### Threats
* unauthorized modification of lifecycle data  
* inconsistent lifecycle history across versions  

#### Mitigations
* signed CLE documents  
* versioning of CLE data  
* retrieval of historical CLE versions for comparison  

#### Residual Risk
* delayed publication of lifecycle updates  

---

## 7. Publication Threat Analysis

### 7.1 Spoofing

#### Threats
* impersonation of publisher identity  

#### Mitigations
* authenticated commit process  
* signature validation  

---

### 7.2 Tampering

#### Threats
* modification of artefacts prior to publication  
* substitution of evidence  

#### Mitigations
* commit-time validation  
* timestamp verification  
* transparency verification  

---

### 7.3 Repudiation

#### Threats
* publisher denies release approval  

#### Mitigations
* collection signature  
* timestamp evidence  
* transparency logs  
* audit records  

---

### 7.4 Information Disclosure

No major TEA-specific risks beyond standard operational controls.

---

### 7.5 Denial of Service

#### Threats
* blocking publication process  
* dependency failures  

#### Mitigations
* retry logic  
* staging workflows  

---

### 7.6 Elevation of Privilege (Critical)

#### Threats
* CI/CD pipeline publishing without authorization  
* compromised approval workflow  
* bypass of commit controls  

#### Mitigations
* strict separation:
  * CI/CD prepares  
  * humans authorize  
  * TEA commits  
* MFA required for commit  
* audit logging  
* policy enforcement  

---

### 7.7 Ephemeral Key Model (Critical)

TEA relies on ephemeral signing keys:

* generated per signing event  
* destroyed immediately after use  

#### Threat

* reuse or retention of keys  

#### Impact

* breaks core security model  

#### Mitigation

> Retaining TEA-native signing keys beyond the signing window is a security violation.

---

### 7.8 Policy-Violating Certificate Lifetime

#### Threat
* long-lived certificates used in TEA-native  

#### Impact
* undermines ephemeral key model  

#### Mitigation
* strict certificate lifetime enforcement  

---

### 7.9 Lifecycle (CLE) Publication

#### Threats
* unauthorized lifecycle updates  
* unapproved lifecycle changes  

#### Mitigations
* same commit authorization model as collections  
* audit logging of lifecycle changes  
* versioned lifecycle documents  

---

## 8. Cross-Cutting System Risks

### 8.1 WebPKI Mis-Issuance

#### Risk
* CA issues unauthorized certificate  

#### Mitigation
* PKIX validation  
* CAA SHOULD be enforced in higher assurance profiles  

---

### 8.2 Timestamp Authorities (TSA)

#### Risk
* TSA compromise or failure  

#### Mitigation
* signature validation  
* trust anchor validation  
* timestamp within certificate validity  
* use of multiple TSAs  

---

### 8.3 Transparency Systems

Transparency systems:

* do NOT prevent unauthorized releases  
* DO provide:
  * auditability  
  * detection  
  * attribution  

#### Risks
* operator compromise  
* split-view attacks  

#### Mitigation
* inclusion proof validation  
* log public key distribution  
* independent log verification  

---

### 8.4 DNS and DNSSEC

#### Properties
* DNS publication REQUIRED when DNS is used according to this trust model  
* DNSSEC OPTIONAL  

#### Risk
* DNS manipulation without DNSSEC  

#### Mitigation
* signature validation  
* timestamp validation  

> DNS alone does not provide authenticity without DNSSEC.

---

### 8.5 Automated DNS Updates

#### Risk
* unauthorized DNS publication  

#### Mitigation
* commit-time authorization  
* validation of certificate properties  

---

### 8.6 Ephemeral Key Handling

#### Risk
* improper key lifecycle management  

#### Mitigation
* strict lifecycle enforcement  
* no key persistence  

---

## 9. Residual Risk Summary

Residual risks include:

* WebPKI CA compromise  
* DNS manipulation without DNSSEC  
* TSA compromise  
* transparency log compromise  
* insider misuse in publication workflow  

These risks are mitigated but not eliminated through:

* multi-anchor trust  
* redundancy  
* cross-validation  
* auditability  

---

## 10. Final Assessment

TEA minimizes reliance on:

* long-lived keys  
* centralized trust authorities  

It distributes trust across:

* time (timestamps)  
* infrastructure (DNS / PKI)  
* transparency systems  

---

## 11. Conclusion

TEA achieves long-term trust not by preserving keys or infrastructure, but by preserving verifiable evidence of correctness at the time of publication.

The architecture ensures:

* integrity through signatures and checksums  
* authenticity through keys and certificates  
* temporal validity through timestamps  
* auditability through transparency  
* correctness of intent through controlled publication  

The most critical requirement remains:

> **Authorization must be correct at publication time.**

If this holds, TEA provides strong, multi-layered security against software supply chain threats.
