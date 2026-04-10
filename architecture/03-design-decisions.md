# 📘 TEA Trust Architecture — Design Decisions
**Version:** 1.0  
**Status:** Draft (Non-Normative, Implementation-Ready)

---

## 1. Purpose

This document explains the key design decisions in the TEA trust architecture.

It provides:

- rationale for architectural choices  
- discussion of alternatives  
- explanation of tradeoffs  

This document is **non-normative**, but authoritative for understanding:

- security properties  
- intended usage  
- implementation expectations  

---

## 2. Design Philosophy

The TEA trust architecture is built on the following principles:

1. **Trust must be verifiable, not assumed**  
2. **No single component should be trusted completely**  
3. **Operational simplicity is a security feature**  
4. **Long-term validation must not depend on long-term private key protection**  
5. **Trust must survive infrastructure and organizational change**  

---

## 3. Separation of Discovery and Artefact Trust

### Decision

Discovery authorization and TEA artefact trust are explicitly separated.

---

### Rationale

Discovery answers:

> “Where should I connect?”

TEA artefact validation answers:

> “Can I trust this data?”

These are fundamentally different security questions.

Discovery is part of **trust bootstrap**, while artefact validation is part of **trust establishment**.

---

### Tradeoff

- increased implementation complexity  
- two validation flows  

---

### Rejected Alternative

Single-layer model where API endpoints are implicitly trusted.

---

### Reason for Rejection

This would make:

- infrastructure compromise  
- API compromise  

equivalent to **trust compromise**, which is unacceptable.

---

## 4. TEI as the Root of Discovery

### Decision

The **Transparency Exchange Identifier (TEI)** is the starting point for discovery.

---

### Rationale

TEI provides:

- a **manufacturer-controlled namespace**  
- decentralized identification  
- reuse of existing identifiers  
- independence from central registries  

Discovery becomes:

```
TEI → manufacturer domain → discovery → API endpoints
```

---

### Tradeoff

- requires TEI parsing and resolution logic  

---

### Rejected Alternative

Direct use of URLs without a stable identifier layer.

---

### Reason for Rejection

This would:

- couple identity to infrastructure  
- reduce portability  
- weaken long-term stability  

---

## 5. Public Key as Identity

### Decision

The **public key is the identity**.

Certificates are wrappers, not identity sources.

---

### Rationale

This:

- avoids dependence on CA naming  
- removes ambiguity in subject fields  
- simplifies trust reasoning  
- enables future format flexibility  

---

### Tradeoff

- explicit trust anchor handling required  
- identity derived from cryptographic material  

---

### Rejected Alternative

Identity based on:

- certificate subject  
- issuer hierarchy  

---

### Reason for Rejection

These approaches:

- mix naming and trust  
- introduce ambiguity  
- are error-prone  

---

## 6. Fingerprint-Derived SAN Names

### Decision

TEA-native certificates use fingerprint-derived SAN DNS names:

```
<fingerprint>.<trust-domain>
```

Optional persistence:

```
<fingerprint>.<persistence-domain>
```

---

### Rationale

Provides:

- deterministic identity binding  
- strong key-to-DNS linkage  
- simple validation logic  

---

### Tradeoff

- less human-readable names  
- requires fingerprint computation  

---

### Rejected Alternative

Arbitrary SAN naming.

---

### Reason for Rejection

Weakens identity binding and introduces ambiguity.

---

## 7. Use of X.509 as Wrapper

### Decision

X.509 is used as a **transport and metadata wrapper**, not identity.

---

### Rationale

Provides:

- widespread tooling support  
- validity intervals  
- compatibility with TSA and transparency  

---

### Tradeoff

- inherits PKI complexity  
- requires strict interpretation rules  

---

### Rejected Alternative

Raw public keys only.

---

### Reason for Rejection

Lacks:

- validity metadata  
- interoperability  
- standardized structure  

---

## 8. Subject Naming for Accountability

### Decision

Subject fields provide **accountability metadata**, not identity.

---

### Rationale

Separates:

- identity → public key  
- accountability → subject O  

---

### Rule

If legal entity exists:

- subject O SHOULD contain legal name  

---

### Tradeoff

- requires careful implementation discipline  

---

### Rejected Alternative

Subject-based identity.

---

### Reason for Rejection

Introduces ambiguity and weak trust guarantees.

---

## 9. Ephemeral Keys

### Decision

Use **ephemeral or short-lived signing keys**.

---

### Rationale

Benefits:

- minimal key exposure window  
- no long-term key storage  
- no revocation dependency  
- simplified CI/CD  

---

### Tradeoff

- frequent key generation  
- reliance on timestamps  

---

### Rejected Alternative

Long-lived signing keys.

---

### Reason for Rejection

High-value targets and operational risk.

---

## 10. Short-Lived Certificates

### Decision

Certificates MUST be **≤ 1 hour**.

---

### Rationale

- eliminates need for revocation  
- limits compromise window  
- aligns with ephemeral keys  

---

### Tradeoff

- frequent issuance required  
- requires timestamp support  

---

### Rejected Alternative

Revocation-based lifecycle.

---

### Reason for Rejection

CRL/OCSP are:

- unreliable  
- inconsistently enforced  
- operationally complex  

---

## 11. DNS Publication (TAPS)

### Decision

TEA-native trust anchors MUST be published in DNS.

---

### Rationale

DNS provides:

- global distribution  
- domain binding  
- interoperability  

---

### Tradeoff

- DNS availability dependency  
- requires consumer validation logic  

---

### Rejected Alternative

No DNS publication.

---

### Reason for Rejection

Removes shared trust anchor distribution mechanism.

---

## 12. DNSSEC as Optional

### Decision

DNSSEC is optional.

---

### Rationale

- increases deployability  
- avoids adoption barriers  

---

### Tradeoff

- DNS may be unauthenticated  

---

### Rejected Alternative

Mandatory DNSSEC.

---

### Reason for Rejection

Too restrictive for real-world deployment.

---

## 13. Persistence Domains

### Decision

Optional second SAN for persistence domains.

---

### Rationale

Supports:

- bankruptcy  
- acquisition  
- long-term verification  

---

### Tradeoff

- additional coordination  

---

### Rejected Alternative

Single-domain dependence.

---

### Reason for Rejection

Fragile long-term model.

---

## 14. Canonical JSON (RFC 8785)

### Decision

Use RFC 8785 (JCS).

---

### Rationale

- deterministic signing  
- interoperability  

---

### Tradeoff

- strict implementation required  

---

## 15. Signature Models

### Decision

Support:

- detached signatures  
- inline signatures  

---

### Rationale

- flexibility  
- format compatibility  

---

### Tradeoff

- multiple validation paths  

---

## 16. Transparency Logs

### Decision

Transparency is REQUIRED in TEA-native trust models.

---

### Rationale

Provides:

- auditability  
- tamper detection  
- public visibility  

---

### Tradeoff

- dependency on external systems  

---

### Rejected Alternative

No transparency.

---

### Reason for Rejection

Weakens auditability and detection.

---

## 17. Timestamp as Trust Anchor

### Decision

Timestamps are **mandatory trust anchors**.

---

### Rationale

They prove:

- when a signature existed  
- that the certificate was valid  

This is critical for:

- short-lived certificates  
- long-term validation  

---

### Tradeoff

- TSA dependency  
- validation complexity  

---

### Additional Decision

Use multiple TSAs when possible.

---

## 18. Long-Term Validation Model

### Decision

Long-term validation relies on:

- timestamps  
- preserved evidence  
- CA/TSA chains  

---

### Rationale

Allows:

- ephemeral keys  
- durable verification  

---

### Tradeoff

- archival requirements  

---

## 19. Discovery Signing

### Decision

Discovery MUST be:

- signed  
- timestamped  

---

### Rationale

Discovery is the **trust bootstrap**.

---

### Tradeoff

- additional implementation effort  

---

### Rejected Alternative

Unsigned discovery.

---

### Reason for Rejection

Weakens endpoint authorization.

---

## 20. No Central Authority

### Decision

No central trust registry.

---

### Rationale

- decentralization  
- resilience  
- independence  

---

### Tradeoff

- explicit trust handling required  

---

## 21. Multiple Trust Models

### Decision

Support:

- TEA-native (TAPS)  
- WebPKI  

---

### Rationale

Covers:

- decentralized trust  
- enterprise integration  

---

### Tradeoff

- dual validation paths  

---

## 22. Service Provider Independence

### Decision

Service providers are NOT trust anchors.

---

### Rationale

- supports outsourcing  
- preserves trust independence  

---

## 23. Dual-Level Signing

### Decision

Separate:

- TEA artefact signatures  
- TEA collection signatures  

---

### Rationale

Prevents:

- misuse of artefacts  
- release forgery  

---

## 24. Time Validation Strategy

### Decision

Use bounded drift, not perfect time.

---

### Rationale

- realistic  
- robust  

---

## 25. Avoidance of GPG

### Decision

GPG is not used.

---

### Rationale

- poor CI/CD fit  
- unclear trust model  

---

## 26. Future-Proof Wrappers

### Decision

Support future formats:

- COSE  
- CBOR  

---

### Rationale

- flexibility  
- evolution  

---

## 27. Operational Simplicity

### Decision

Favor simple designs.

---

### Rationale

- fewer errors  
- broader adoption  

---

## 28. CRA Alignment

### Decision

Focus on lifecycle validation.

---

### Rationale

Supports:

- long-term evidence  
- auditability  
- compliance  

---

## 29. Final Design Summary

The TEA trust architecture:

- minimizes long-lived secrets  
- separates trust domains  
- uses public key identity  
- anchors trust in timestamps and transparency  
- supports decentralized validation  
- enables long-term verification  

---

## Final Statement

> Trust in TEA does not depend on who operates the system  
> but on what can be independently verified over time.
