# 📄 architecture/taps-architecture.md

# TEA Trust Anchor Publication Service (TAPS) Architecture (v1.0)

---

## 1. Purpose

The Trust Anchor Publication Service (TAPS) defines how **TEA-native trust anchors** are published, discovered, and validated.

Its purpose is to:

- provide a **publisher-controlled trust anchor mechanism**
- enable **independent verification without centralized PKI**
- support **ephemeral key usage**
- ensure **long-term verifiability of signatures**

TAPS is a core component of the TEA trust architecture.

---

## 2. Concept Overview

In traditional PKI:

```text
Trust anchor = Certificate Authority (CA)
```

In TEA-native:

```text
Trust anchor = Publisher’s certificate published in DNS
```

---

### Key Idea

> **The publisher directly publishes its own signing certificate as the trust anchor.**

This eliminates dependency on:

- external certificate authorities  
- long-lived trust chains  
- revocation infrastructure  

---

## 3. Core Model

---

### 3.1 Identity Model

In TEA-native:

- identity = public key  
- certificate = validity wrapper  
- DNS = publication channel  

---

### 3.2 Fingerprint-Derived Naming

Each signing certificate MUST include a SAN DNS name:

```text
<fingerprint>.<trust-domain>
```

Where:

```text
fingerprint = lowercase hex SHA-256(public key)
```

---

### Optional Persistence SAN

```text
<fingerprint>.<persistence-domain>
```

Purpose:

- long-term accessibility  
- resilience to domain loss or organizational changes  

---

### Key Property

> **The DNS name is derived from the key — not assigned arbitrarily.**

This prevents:

- identity spoofing  
- namespace squatting  

---

## 4. Trust Anchor Publication

---

### 4.1 DNS CERT Records

Certificates are published using DNS CERT records:

```text
<fingerprint>.<trust-domain>. IN CERT PKIX 0 0 <base64-certificate>
```

---

### 4.2 Requirements

For TEA-native:

- DNS publication is **REQUIRED**
- DNSSEC is **OPTIONAL**
- certificate MUST match fingerprint-derived name  

---

### 4.3 DNSSEC Role

| Mode | Security Property |
|------|------------------|
| DNS only | publication |
| DNS + DNSSEC | authenticated publication |

---

### Critical Rule

> DNS without DNSSEC MUST NOT be treated as an authenticated trust anchor.

However:

- DNS publication remains **required** as a discovery mechanism  

---

## 5. Trust Model

---

### 5.1 How Trust is Established

A consumer validates:

1. signature  
2. timestamp  
3. certificate validity at signing time  
4. fingerprint → SAN binding  
5. DNS publication of certificate  
6. DNSSEC (if required by policy)  

---

### Trust Composition

```text
Trust = signature + timestamp + certificate + DNS (+ DNSSEC) + transparency
```

---

### 5.2 Role of DNS

DNS provides:

> "This certificate is published under this identity"

DNS does NOT provide:

- proof of correct key usage  
- proof of authorization  
- proof of integrity (without DNSSEC)  

---

## 6. Ephemeral Key Model

---

### 6.1 Key Lifecycle

TEA-native relies on ephemeral keys:

- generated per signing event  
- used once  
- destroyed immediately after use  

---

### 6.2 Certificate Lifetime

Certificates MUST be:

- short-lived (recommended ≤ 24 hours)  
- tightly bound to signing event  

---

### Key Insight

> **Long-term trust is derived from evidence, not from persistent keys.**

---

## 7. Evidence Integration

TAPS does not operate in isolation.

It is combined with:

---

### 7.1 Timestamp

Provides:

- proof of signing time  
- validation after certificate expiry  

---

### 7.2 Transparency

Provides:

- auditability  
- detection of misuse  
- proof of publication  

---

### 7.3 Evidence Bundle

A complete validation set includes:

- artefact  
- signature  
- certificate  
- timestamp  
- transparency receipt  
- DNS publication  

---

## 8. Consumer Validation

---

### 8.1 Required Steps (TEA-Native)

A compliant consumer MUST:

1. extract certificate  
2. compute public key fingerprint  
3. verify SAN matches `<fingerprint>.<domain>`  
4. resolve certificate via DNS  
5. compare DNS certificate with provided certificate  
6. validate signature  
7. validate timestamp  
8. verify certificate validity at timestamp  
9. validate DNSSEC (if required by policy)  
10. validate transparency (if required by policy)  

---

### 8.2 Failure Conditions

Validation MUST fail if:

- fingerprint mismatch  
- certificate not published in DNS  
- signature invalid  
- timestamp invalid  
- certificate invalid at timestamp  

---

## 9. Comparison with WebPKI

---

### TEA-Native vs WebPKI

| Aspect | TEA-Native (TAPS) | WebPKI |
|--------|------------------|--------|
| Trust anchor | DNS-published certificate | CA hierarchy |
| Key lifetime | short-lived | often long-lived |
| Revocation | not required | required |
| Identity binding | fingerprint-derived | CA-issued |
| Transparency | recommended | optional |
| DNS role | required | policy-only |

---

### Key Difference

> TEA-native shifts trust from centralized authorities to **publisher-controlled, evidence-backed validation**.

---

## 10. Security Properties

---

### 10.1 Strengths

- no dependency on external CA issuance  
- no revocation dependency  
- minimal key exposure window  
- strong alignment with evidence-based validation  
- resilient to infrastructure changes  

---

### 10.2 Risks

- DNS spoofing (without DNSSEC)  
- incorrect certificate publication  
- failure to validate fingerprint binding  
- improper key handling  

---

### Mitigations

- DNSSEC where available  
- strict validation rules  
- transparency logging  
- timestamp enforcement  
- ephemeral key discipline  

---

## 11. Operational Considerations

---

### 11.1 DNS Management

- ensure correct CERT record publication  
- maintain domain control  
- optionally deploy DNSSEC  

---

### 11.2 Key Management

- generate keys in secure environment  
- avoid reuse  
- delete immediately after signing  

---

### 11.3 Monitoring

- monitor DNS integrity  
- monitor transparency logs  
- audit publication events  

---

## 12. Critical Rules

---

### Rule 1

> The SAN DNS name MUST be derived from the public key fingerprint.

---

### Rule 2

> The certificate MUST be published in DNS.

---

### Rule 3

> DNS alone MUST NOT be treated as an authenticated trust anchor without DNSSEC.

---

### Rule 4

> Trust MUST be anchored in timestamped signatures, not in certificate lifetime.

---

### Rule 5

> Private keys MUST be ephemeral and MUST be destroyed after use.

---

## 13. Summary

TAPS provides a **decentralized trust anchor model** for TEA by:

- publishing certificates directly in DNS  
- binding identity to public key fingerprints  
- enabling ephemeral key usage  
- integrating with timestamps and transparency  

The result is:

- simplified trust infrastructure  
- strong long-term verifiability  
- alignment with modern supply chain security requirements  

---

## 14. One-Line Takeaway

> **TAPS replaces centralized certificate authorities with publisher-controlled, DNS-published trust anchors, backed by timestamps and transparency for long-term verification.**

---