# DNSSEC and CERT-Based Trust Anchor Distribution

## Status

This document is normative.

It defines the requirements for DNSSEC usage and DNS-based
trust anchor distribution in the TEA trust architecture.

All implementations using DNS-based trust anchors MUST comply
with this specification.

## 1. Role of DNSSEC

DNSSEC MAY be used by a TEA implementation as a mechanism for distributing trust anchor data.

DNSSEC provides:

- origin authentication of DNS data
- integrity protection of DNS responses

DNSSEC ensures that the data received:

- was published by the authoritative DNS zone, and
- has not been modified in transit

---

## 2. Security Properties Provided by DNSSEC

When DNSSEC validation succeeds, a TEA implementation can conclude:

- the DNS record originates from the domain owner
- the record content is intact and unaltered

This property is referred to as **authenticated data origin and integrity**.

---

## 3. Security Properties NOT Provided by DNSSEC

DNSSEC does NOT provide:

- trustworthiness of the published data
- validation of certificate semantics
- lifecycle state (active, revoked, deprecated)
- temporal ordering of events
- protection against malicious or compromised domain owners

Therefore:

> DNSSEC authenticates *delivery of data*, not *trust in that data*.

---

## 4. Separation of Responsibilities

In the TEA architecture, responsibilities are separated as follows:

- DNSSEC: authenticated distribution of trust anchor data
- TEA trust model: determination of whether a trust anchor is accepted
- Timestamp Authority (TSA): temporal binding of signatures
- Transparency system: ordering and auditability

A TEA implementation MUST NOT use DNSSEC alone to establish trust.

---

## 5. CERT Record Usage

If DNS-based distribution is used:

- trust anchors MUST be published using DNS CERT records
- CERT records MUST contain complete certificate objects
- DNS responses MUST be validated using DNSSEC before use

A TEA consumer MUST:

1. validate the DNSSEC chain of trust
2. extract the CERT record
3. parse the certificate
4. apply TEA trust validation rules independently

---

## 6. Trust Decision Requirements

A TEA implementation:

- MUST treat DNSSEC-provided data as untrusted input until validated by TEA rules
- MUST NOT infer trust solely from DNSSEC validation
- MUST combine DNSSEC data with other trust domains (signature, timestamp, transparency)

---

## 7. Optional Dependency

DNSSEC is an optional component.

A TEA implementation:

- MUST function correctly without DNSSEC
- MUST support validation using locally stored or bundled trust anchors

---

## 8. Threat Considerations

### 8.1 DNS Zone Compromise

If a DNS zone is compromised:

- an attacker may publish malicious trust anchors

Mitigation:

- TEA validation (signature, timestamp, transparency) MUST detect or constrain misuse

---

### 8.2 DNS Manipulation Without DNSSEC

If DNSSEC is not used:

- DNS responses MUST be treated as untrusted
- CERT records MUST NOT be relied upon without additional validation

---

### 8.3 Central Dependency Consideration

DNSSEC introduces a global trust dependency (root zone).

TEA limits this dependency by:

- making DNSSEC optional
- ensuring DNSSEC does not define trust decisions

---

## 9. Summary

DNSSEC in TEA:

- provides authenticated distribution of trust anchor data
- does not establish trust in that data
- is optional and non-authoritative for validation

Trust is established only through the combination of:

- publisher signatures
- timestamp validation
- transparency evidence
- TEA trust policies

---
11. DNS-Based Distribution and Publication Control

11.1 Role of DNS in TEA

DNS (with DNSSEC) is used in TEA as:
* a distribution mechanism for trust anchors and certificates
* a discovery mechanism for consumers

DNS MUST NOT be treated as a standalone source of trust.

Trust decisions MUST always be based on:
* signature validation
* certificate validation
* timestamp validation
* trust policy

⸻

11.2 Authenticated Distribution

When DNSSEC is used, it provides:
* integrity of DNS records
* origin authentication of the zone

DNSSEC ensures that:
* the data was not modified in transit
* the data originates from the authoritative zone

DNSSEC does NOT ensure that:
* the data is trustworthy
* the trust anchor should be accepted

Consumers MUST apply independent trust policy.

⸻

11.3 DNS Publication as a Policy Enforcement Point

Systems that publish TEA-related DNS records act as:

trust policy enforcement points

Before publishing any record, the system MUST validate:
* certificate correctness
* identity binding (SAN DNS match)
* signature validity
* timestamp validity

DNS publication MUST NOT be performed based on:
* certificate presence alone
* unauthenticated input
* CI/CD direct write without validation

⸻

11.4 DNS Publication Requirements

A DNS publication system MUST enforce the following:

Required (All Models)
* certificate is valid
* certificate contains valid public key
* SAN DNS matches DNS record name
* signature over artefact or collection is valid
* timestamp token is present and valid

⸻

Additional Requirements (DNS-Anchored Model)

For DNS-anchored deployments:
* transparency receipt SHOULD be present
* implementations MAY require transparency receipt

For CI/CD and ephemeral models:
* transparency SHOULD be treated as REQUIRED

⸻

Additional Requirements (WebPKI Model)

For WebPKI-based deployments:
* PKIX validation MUST succeed
* CAA validation SHOULD be performed

⸻

11.5 Separation of Duties

Implementations SHOULD separate:
* signing systems (CI/CD)
* DNS publication systems

A CI/CD system:
* MAY generate keys
* MAY sign artefacts
* MUST NOT have unrestricted DNS write access

DNS publication SHOULD be performed by:
* a controlled service
* a policy validation layer
* a release promotion step

⸻

11.6 Automated DNS Updates

If automated DNS updates are used, implementations MUST enforce:
* least privilege access
* restricted DNS scope (subdomain or record type)
* auditable changes
* short-lived credentials

CI/CD systems MUST NOT be granted:
* full DNS zone control
* ability to overwrite arbitrary trust anchors

⸻

11.7 Recommended DNS Scope Design

Implementations SHOULD separate:
* long-lived trust anchors
* release-specific signing certificates

Example:
* _tea.example.com → controlled trust anchors
* _tea-rel.example.com → automated release records

This reduces blast radius in case of compromise.

⸻

11.8 Security Impact

This model ensures:
* DNS cannot be used to silently introduce trust
* compromised CI/CD cannot redefine trust anchors
* all DNS-published material is backed by verifiable evidence

## 10. Normative Statement

A TEA implementation:

- MUST NOT treat DNSSEC as a trust authority
- MUST treat DNSSEC as a distribution mechanism only
- MUST validate all trust anchors independently of DNSSEC
