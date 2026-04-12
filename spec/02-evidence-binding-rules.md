# 📄 spec/evidence-binding-rules.md

# TEA Evidence Binding Rules (v1.1)

---

## 1. Purpose

This document defines how evidence is used in TEA to establish long-term, verifiable trust in:

* artefacts  
* collections  
* identities  
* publication events  

It explains:

* what evidence mechanisms are used  
* what each mechanism actually proves  
* how those mechanisms are trusted  
* how they combine into a complete validation model  

---

## 2. Core Principle

> **TEA establishes trust by preserving verifiable evidence of correctness at the time of signing — not by relying on current system state.**

This is fundamentally different from traditional PKI.

---

### Traditional PKI Model

```text
Trust = certificate validity NOW
```

---

### TEA Model

```text
Trust = evidence that the signature was valid THEN
```

---

## 3. Evidence Mechanisms — What They Mean

TEA uses multiple independent evidence mechanisms.

Each answers a different question.

---

### 3.1 Signature

**What it proves:**

> "This data was produced by the holder of this private key"

Properties:

* integrity (data has not changed)  
* origin (which key produced it)  
* The signature MUST be verifiable using the public key contained in the associated certificate and MUST correspond to the exact target object.
---

### 3.2 Timestamp (RFC 3161)

---

#### What a Timestamp Is

A timestamp is a **cryptographically signed statement by a Timestamp Authority (TSA)** that:

> "A specific piece of data existed at time T"

More precisely:

```text
TimeStampToken = Sign_TSA(
    messageImprint = hash(signature),
    genTime = T
)
```

---

#### What a Timestamp Proves

A valid timestamp proves:

* the signature existed at time T  
* the signature was not created after T  
* the signature can be evaluated against the certificate validity window  

---

#### What It Does NOT Prove

A timestamp does NOT prove:

* who created the signature  
* that the signature is valid  
* that the artefact is correct  

---

#### How You Trust a Timestamp

You trust a timestamp by:

1. Verifying the TSA signature  
2. Verifying the TSA certificate chain to a trusted CA  
3. Verifying the timestamp structure and integrity  
4. Ensuring the timestamp binds to the signature  
5. Ensuring the timestamp falls within the certificate validity window  

---

#### Trust Model

Trust in timestamps depends on:

* trust in the TSA operator  
* trust in the issuing CA  
* correct validation of the timestamp  

---

#### Key Insight

> **The timestamp replaces revocation by proving when something was valid.**

---

### 3.3 Transparency Logs (Rekor, Sigsum, SCITT)

---

#### What a Transparency Log Is

A transparency system is an **append-only, cryptographically verifiable log**.

It records statements such as:

* certificates  
* artefacts  
* signatures  

---

#### What Transparency Proves

Transparency provides:

> "This object was publicly recorded in a verifiable log"

Specifically:

* existence (object was seen)  
* ordering (when relative to other entries)  
* immutability (cannot be removed without detection)  

---

#### What It Does NOT Prove

Transparency does NOT prove:

* correctness of the object  
* authorization of publication  
* that the object is safe or valid  

---

#### How You Trust Transparency

You trust a transparency system by:

1. Verifying inclusion proof  
2. Verifying log signature / checkpoint  
3. Verifying log consistency over time  
4. Trusting the log operator or governance model  

---

#### System Examples

| System | Trust Model |
|-------|------------|
| Rekor | Operator-based (Sigstore ecosystem) |
| Sigsum | Cryptographic quorum model |
| SCITT | Standardized transparency service (IETF) |

---

#### Key Insight

> **Transparency ensures detectability, not correctness.**

It allows:

* independent auditing  
* detection of misuse  
* long-term visibility  

---

### 3.4 DNS and DNSSEC

---

#### What DNS Provides

DNS publication proves:

> "This data is published at this name"

In TEA-native:

```text
fingerprint(public key) → certificate
```

---

#### What DNS Does NOT Prove

Without DNSSEC:

* authenticity is NOT guaranteed  
* data can be spoofed or modified  

---

#### What DNSSEC Adds

DNSSEC provides:

> "This DNS data is authentic and has not been modified"

It does this by:

* signing DNS records  
* validating signatures through a chain of trust  
* anchoring at the DNS root  

---

#### How You Trust DNSSEC

You trust DNSSEC by:

1. Validating DNSSEC signatures  
2. Verifying chain of trust to root  
3. Ensuring no validation errors  

---

#### Trust Model

DNSSEC trust depends on:

* DNS root trust anchor  
* correct resolver validation  
* absence of key compromise  

---

#### Key Distinction

| Mode | Meaning |
|------|--------|
| DNS only | publication signal |
| DNS + DNSSEC | authenticated publication |

---

#### Critical Rule

> DNS without DNSSEC MUST NOT be treated as a trust anchor.

---

### 3.5 Certificate

---

#### What a Certificate Provides

A certificate provides:

> "This public key is valid under these conditions during this time window"

It includes:

* public key  
* validity period  
* metadata  

---

#### What It Does NOT Provide

A certificate alone does NOT prove:

* when it was used  
* whether it is still valid  
* whether it was revoked  
* whether it was used correctly  

---

#### How TEA Uses Certificates

TEA uses certificates as:

* identity wrappers  
* validity containers  

---

#### Key Insight

> **Certificates define validity windows — timestamps prove usage within those windows.**

---

## 4. Evidence Binding Model

---

### 4.1 Primary Binding Rule

> **All trust MUST anchor to signatures that are bound to time via timestamps.**

---

### 4.2 Binding Structure

```text
artefact
  ↓
signature (over exact artefact bytes)
  ↓
timestamp(signature)
  ↓
certificate (containing public key used for verification)
  ↓
certificate validity at time T
  ↓
identity binding (DNS or PKI)
  ↓
transparency (optional)
```

---

## 5. Object Coverage

---

### 5.1 MUST be Directly Bound

* collection signature  
* artefact signatures  
* discovery signature  
* the signature MUST validate against the object using the associated certificate

---

### 5.2 MUST be Included

* artefacts  
* collection  
* signing certificate  

---

### 5.3 SHOULD be Bound (High Assurance)

* transparency entries  
* DNSSEC validation  

---

## 6. Validation Model

A consumer MUST validate:

1. signature integrity (including verification against the object using the associated certificate)
2. timestamp validity  
3. certificate validity at timestamp  
4. identity binding (DNS or PKI)  
5. artefact inclusion in collection  

---

### 6.1 Publisher-side enforcement

Publisher implementations MUST enforce the same binding rules at ingestion time.

Before accepting an object and its evidence:

- the signature MUST be verified against the object  
- the certificate MUST correspond to the public key used for verification  

Objects failing these checks MUST be rejected.

This ensures that invalid bindings do not enter the TEA system.

---

## 7. Trust Composition

Each mechanism contributes independently:

| Mechanism | Role |
|----------|------|
| Signature | integrity |
| Timestamp | time |
| Certificate | identity context |
| DNS | publication |
| DNSSEC | authenticated publication |
| Transparency | auditability |

---

## 8. Critical Insights

---

### 8.1 No Single Trust Anchor

> TEA deliberately avoids relying on a single authority.

---

### 8.2 Evidence Over Infrastructure

> Trust survives even if infrastructure disappears.

---

### 8.3 Time is Central

> The most important question is not “is this valid now?”  
> but “was this valid when it was created?”

---

## 9. Failure Conditions

---

### MUST Reject

* invalid signature  
* missing timestamp  
* timestamp not bound to signature  
* certificate invalid at timestamp  

---

### SHOULD Reject

* missing transparency (if required)  
* DNS inconsistencies  
* DNSSEC failures (in high assurance)  

---

## 10. Final Rule

> **If you cannot prove that a signature existed within the certificate validity window using independent evidence, you MUST NOT trust it.**

---

## ✅ Result

This model ensures:

* long-term verifiability  
* independence from revocation  
* resilience against key compromise  
* strong alignment with modern supply chain security  
