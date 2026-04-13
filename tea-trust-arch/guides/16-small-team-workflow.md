# 📘 TEA Implementation Guide  
## Small Company / Open Source Project  
### (Ephemeral TEA-Native Model)


## Status

This document is informative and provides a recommended implementation
workflow for small teams and open source projects using the TEA trust architecture.

Normative requirements are defined in the TEA Core Trust Architecture
and related specifications.

---

## 1. Goal

This guide explains how a small team or open source project can implement **TEA with the trust architecture** using a simple, modern, and secure approach.

It shows how to:

* create a release  
* generate and use a short-lived signing key  
* produce SBOMs and attestations  
* sign artefacts and the TEA collection  
* obtain trusted timestamps  
* publish TEA-native trust anchors in DNS  
* publish to a TEA service  

---

### Key Idea

Instead of protecting a long-lived signing key (as in traditional PKI), this model:

> **uses disposable keys and preserves trust through evidence**

This dramatically reduces operational complexity and limits the impact of key compromise.

---

## 2. Operating Model

In TEA with the trust architecture, trust is built from **multiple independent components**, not a single authority.

You will use:

* an **ephemeral signing key** (exists only during signing)  
* a **short-lived certificate** (identity wrapper)  
* a **trusted timestamp** (proof of when signing occurred)  
* a **transparency log** (proof of existence and auditability)  
* **DNS publication** (TEA-native trust anchor distribution)  

---

### How Trust Is Established

Each component answers a different question:

| Component | What it proves |
|----------|----------------|
| Signature | Integrity of the data |
| Certificate | Identity of the signer |
| Timestamp | When the signature existed |
| DNS | Where the identity is published |
| Transparency | That the data existed publicly |

These signals combine to form **compositional trust**.

---

### Ephemeral Key Model

The most important property:

* private keys are generated per release  
* used once  
* destroyed immediately  

This means:

* no long-term secrets to protect  
* no revocation infrastructure required  
* reduced impact of compromise  

---

## 3. One-Time Setup

### 3.1 Choose Trust Domains

You must define where your trust anchors will live.

Example:

* Manufacturer domain:  
  `teatrust.example.org`

* Optional persistence domain:  
  `teatrust.archive.example.net`

---

### Why Two Domains?

The persistence domain exists to support:

* long-term validation  
* domain ownership changes  
* company restructuring or shutdown  

---

### 3.2 Configure DNS

You must be able to publish DNS records.

For TEA-native:

* DNS publication is **REQUIRED**  
* DNSSEC is **OPTIONAL but recommended**

---

### Important Concept

DNS in TEA-native is:

* a **distribution mechanism**, not a trust guarantee  

Only when DNSSEC is present does it provide **authenticated distribution**.

---

## 4. Release Workflow (End-to-End)

This section describes the full lifecycle of producing a TEA release.

---

### Step 1: Prepare Artefacts

Create all release artefacts:

* SBOM (CycloneDX recommended)  
* attestations (e.g., in-toto)  
* release metadata  
* TEA collection JSON  

---

### What is the Collection?

The TEA collection is:

> **a signed, authoritative definition of the release**

It contains:

* references to artefacts  
* cryptographic digests  
* metadata  

---

### Step 2: Generate Ephemeral Key

Generate a fresh key pair in a secure environment.

Requirements:

* never reuse keys  
* do not store long-term  
* do not back up  

---

### Recommended Lifetime

* a few minutes to a few hours  
* typically ~5 hours  
* never exceed 24 hours  

---

### Why This Matters

Short-lived keys eliminate:

* long-term key compromise risk  
* need for revocation systems  

---

### Step 3: Derive Fingerprint and SAN Names

Compute:

```text
fingerprint = SHA-256(public key)
```

Construct SAN names:

```text
<fingerprint>.<trust-domain>
```

Optional:

```text
<fingerprint>.<persistence-domain>
```

---

### Important Concept

The fingerprint is the **actual identity**.

The certificate and DNS names are just **representations of that identity**.

---

### Step 4: Create Self-Signed Certificate

Create a short-lived X.509 certificate.

Requirements:

* self-signed  
* Ed25519 preferred  
* short validity (~5 hours)  
* CN MUST NOT be used  
* O SHOULD contain legal or stable name  
* exactly one required SAN  
* optional persistence SAN  
* no unrelated SAN entries  

---

### Why Self-Signed?

In TEA-native:

* identity = public key  
* certificate = validity wrapper  

No external CA is required.

---

### Step 5: Publish Certificate in DNS

Publish the certificate:

```text
<fingerprint>.<trust-domain>. IN CERT PKIX 0 0 <base64-certificate>
```

---

### Why DNS?

DNS provides:

* public discoverability  
* decentralized distribution  
* independence from centralized PKI  

---

### Important Operational Note

DNS publication SHOULD be confirmed during commit.

If a release is not committed:

* DNS entries SHOULD be removed or allowed to expire  

---

### Step 6: Record in Transparency Log

Submit to a transparency system:

* Rekor  
* Sigsum  
* SCITT  

Submit:

* certificate  
* artefacts  
* collection  

---

### Why Transparency?

Transparency provides:

* proof of existence  
* ordering of events  
* auditability  

---

### Critical Rule

Transparency entries MUST match:

* the signed object  
OR  
* the timestamped signature  

Otherwise they are invalid.

---

### Step 7: Sign Artefacts

In TEA with the trust architecture:

> **All artefacts MUST be signed**

Sign:

* SBOMs  
* attestations  
* release artefacts  

---

### What This Means

Artefact signatures prove:

> “This file is authentic”

---

### Step 8: Sign TEA Collection

Sign the collection separately.

This proves:

> “This set of artefacts defines the release”

---

### Key Insight

| Signature Type | Meaning |
|---------------|--------|
| Artefact signature | Authenticity of file |
| Collection signature | Release definition |

Both are required.

---

### Step 9: Obtain TSA Timestamp

Obtain a timestamp over:

* the signature (preferred)  

```text
messageImprint == hash(signature)
```

---

### Why Timestamp?

The timestamp proves:

* the signature existed at a specific time  
* the certificate was valid at that time  

This enables:

* validation after certificate expiry  

---

### Step 10: Validate Time

Before publishing, verify:

* TSA signature is valid  
* TSA certificate chains to trusted root  
* timestamp binds to signature  
* timestamp is within certificate validity  

---

### Multi-TSA Recommendation

Using multiple TSAs:

* reduces reliance on one provider  
* detects inconsistencies  

---

### Step 11: Delete Private Key

Immediately destroy the private key.

---

### Why This Is Critical

This ensures:

* no long-term key exposure  
* minimal attack surface  

---

### Step 12: Assemble Evidence Bundle

Collect:

* artefacts  
* signatures  
* collection  
* certificate  
* timestamps  
* transparency receipts  

---

### Why This Matters

The evidence bundle allows:

* offline validation  
* long-term verification  
* auditability  

---

### Step 13: Upload Draft Release

Upload everything to the TEA service.

This is still:

> **non-authoritative draft data**

---

### Step 14: Human Review and Commit

A human MUST approve:

* release contents  
* signatures  
* timestamps  
* DNS publication  

---

### Critical Security Principle

> **CI/CD prepares — humans authorize — TEA commits**

---

## 5. Consumer Validation (What Will Happen)

A consumer will:

1. validate collection signature  
2. verify artefact digests match collection  
3. validate certificate  
4. compute fingerprint  
5. verify SAN binding  
6. resolve DNS publication  
7. verify signatures  
8. validate timestamp  
9. validate transparency  
10. derive final trust decision  

---

### Key Insight

Consumers do NOT trust:

* the server  
* the transport  

They trust:

* cryptographic evidence  

---

## 6. Security Best Practices

### Key Handling

* never reuse keys  
* always delete after use  
* isolate signing environment  

---

### Certificate

* short-lived  
* fingerprint-based identity  
* minimal fields  

---

### Time

* use trusted TSAs  
* consider redundancy  
* store evidence  

---

### Transparency

* always retain receipts  
* treat as audit layer  

---

### DNS

* publish consistently  
* use DNSSEC when possible  

---

## 7. Common Mistakes

* reusing keys  
* incorrect SAN naming  
* missing DNS publication  
* missing timestamps  
* incomplete validation  
* ignoring collection binding  
* trusting DNS without DNSSEC  

---

## 8. Minimal Implementation Path

1. generate key  
2. compute fingerprint  
3. create certificate  
4. publish DNS  
5. sign artefacts + collection  
6. timestamp  
7. publish  
8. delete key  

---

## 9. Summary

This model provides:

* no long-lived secrets  
* strong cryptographic guarantees  
* long-term verifiability  
* simplified operations  

---

### Key Trade-Off

You replace:

* traditional PKI complexity  

with:

* short-lived keys  
* explicit evidence  
* compositional trust  

---

## 10. One-Line Takeaway

A small team can produce fully verifiable SBOMs and attestations using disposable keys, DNS-published short-lived certificates, timestamps, and transparency evidence — without running a traditional PKI.
