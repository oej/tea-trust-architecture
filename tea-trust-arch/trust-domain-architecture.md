# 📘 TEA Trust Architecture — Three Major Domains

## Status

- **Version:** 1.0  
- **Status:** Draft (Informative)  
- **Scope:** TEA Trust Architecture  
- **Audience:** Implementers, architects  

---

## 1. Discovery Trust Architecture

### Question

“Am I talking to the right TEA service for this manufacturer?”

---

### Purpose

This phase establishes:

- the correct TEA API endpoint for a manufacturer  
- that the endpoint mapping is authorized and authentic  

It is the bootstrap trust step for all subsequent validation.

---

### What is being trusted

- Mapping from manufacturer domain → TEA service endpoint  
- Integrity of the discovery document  
- Authorization of delegation to third-party TEA service providers  

---

### Trust anchors involved

- TLS / WebPKI for transport security (initial retrieval)  
- Discovery signature  
- TSA timestamp over the discovery signature (MUST be present)  
- Transparency evidence (SHOULD be present, REQUIRED in high-assurance profiles)  
- DNS publication of the discovery signing certificate when DNS is used according to this trust model  
- DNSSEC, if present, strengthens DNS-based validation but is not mandatory  

See `dns-usage.md` for normative DNS behavior.

---

### Core problem

Discovery is a bootstrap trust problem.

At first contact, the consumer does not yet know the correct TEA API endpoint.  
Discovery establishes the first authenticated mapping between manufacturer identity and service endpoint.

---

### Correct architectural model

- The initial retrieval relies on TLS for transport integrity and server authentication  
- TLS alone MUST NOT be considered sufficient for trust establishment  

Discovery trust is established through:

- signature  
- timestamp  
- optional transparency evidence  

This is NOT trust-on-first-use (TOFU).

After retrieval, all further validations become repeatable and cryptographically anchored.

---

### Timestamp requirement (CRITICAL)

The discovery document MUST include a timestamp over the signature.

The timestamp is REQUIRED to:

- prevent backdating of discovery documents  
- establish a verifiable point in time for endpoint authorization  

---

### DNS behavior

When DNS is used according to this trust model:

- The discovery signing certificate MUST be published in DNS  
- Consumers MUST validate this binding  
- DNSSEC, when present, strengthens validation but is not mandatory  

For WebPKI:

- DNS MUST NOT be treated as a trust anchor  
- DNS may still contribute via CAA policy  

---

### Key security goal

Ensure that the consumer connects to the correct TEA API endpoint, even when services are hosted by third parties.

---

## 2. Consumer Trust Architecture

### Question

“Can I trust that these artifacts are correct and belong to this release?”

---

### Purpose

This is the core TEA trust model, validating:

- release authenticity  
- artifact integrity  
- publisher identity  
- timing and publication evidence  

---

### What is being trusted

- The collection (authoritative release definition)  
- The artifacts referenced in the collection  
- The publisher’s release statement  
- The timing and publication evidence associated with the release  

---

### Trust primitives

#### A. Collection signature

Proves:

> “This collection version is approved by the publisher.”

---

#### B. Checksums inside the collection

Prove:

> “These exact artifact bytes belong to this collection version.”

---

#### C. Artifact signatures

Prove:

> “This artifact is independently authentic.”

Artifact signatures:

- OPTIONAL in base TEA  
- REQUIRED in higher-assurance profiles  

---

#### D. Timestamp (TSA)

Provides:

- signing-time evidence  
- ordering  
- long-term validation support  

Normative statement:

Timestamp is a primary trust anchor enabling long-term validation independent of certificate lifetime.

---

### Timestamp Binding (CRITICAL)

The timestamp MUST bind to the signature over the object, not merely the raw artifact or collection.

For RFC 3161 timestamps:

```
messageImprint = hash(signature)
```

The timestamp MUST satisfy:

```
timestamp ∈ [certificate.notBefore, certificate.notAfter]
```

This ensures that the signature was created while the certificate was valid.

---

#### E. Transparency system

Provides:

- auditability  
- ordering  
- tamper detection  
- proof of publication existence  

Transparency SHOULD be present and is REQUIRED in high-assurance deployments.

Supported systems include:

- Rekor  
- Sigsum  

SCITT MAY be supported in future implementations.

---

### Transparency Binding (CRITICAL)

Transparency evidence MUST refer to the same:

- signature  
  OR  
- timestamped signature  

that is being validated.

Mismatch → validation MUST fail  

---

#### F. DNS publication

When DNS is used according to this trust model:

- DNS publication of certificates is REQUIRED  
- DNS MUST publish the certificate used for signature verification  
- Publication MUST use fingerprint-derived SAN names  
- DNSSEC is OPTIONAL but recommended  

For WebPKI:

- DNS MUST NOT be used as a trust anchor  
- DNS MAY strengthen policy via CAA  
- DNSSEC strengthens CAA if present  

See `dns-usage.md` for details.

---

### Evidence chain (normative)

Trust MUST be established through an evidence chain consisting of:

1. Signature validity  
2. Timestamp proving signing time  
3. Certificate validity at timestamp  
4. Transparency inclusion (if required)  
5. Trust anchor validation (DNS or PKI depending on trust model)  

---

### Evidence Bundle (RECOMMENDED)

TEA implementations SHOULD support evidence bundles containing:

- signatures  
- certificates  
- timestamps  
- transparency evidence  

This enables:

- offline validation  
- long-term verification  
- interoperability  

---

### Trust model requirements

When DNS is used according to this trust model:

- timestamp validation is REQUIRED  
- transparency validation is REQUIRED  

For WebPKI:

- timestamp and transparency requirements are determined by validation profile or policy  

---

### Critical properties

- One artifact MAY appear in multiple collections  
- One release MAY have multiple collection versions  
- Collection ≠ artifact authenticity  
- Collection = release composition  
- Artifact signature = independent authenticity  

---

### Consumer trust conclusion

The strongest correct statement is:

> “This exact artifact file matches a checksum in this signed collection version, the collection is authentic, the timestamp proves valid signing time, and the evidence chain is valid. Therefore, the artifact belongs to the publisher-approved release context. If the artifact signature is also valid, the artifact itself is independently authentic.”

---

### Lifecycle integration (CLE)

Lifecycle information complements trust validation.

CLE provides machine-readable lifecycle events:

- supported  
- end-of-support  
- end-of-security-updates  
- end-of-life  
- superseded  

Important:

- CLE does not affect cryptographic validity  
- CLE is critical for risk, compliance, and operational decisions  
- CLE documents MUST be signed, versioned, and validated using the same trust mechanisms as collections  
- Consumers MUST be able to retrieve previous CLE versions for comparison  

---

### Key security goal

Ensure that the consumer receives:

- correct and unmodified artifacts  
- bound to the correct release  
- with verifiable timing and publication evidence  

---

## 3. Publication Trust Architecture

### Question

“Can I trust that what was published actually represents the manufacturer’s intent?”

---

### Purpose

This domain ensures:

- releases are intentional  
- publication is authorized  
- automation cannot publish without control  

---

### What is being trusted

- The release publication process  
- The collection signature as the authoritative release statement  
- The authorization behind publication  
- The integrity of the commit step  

---

### Trust boundaries

#### CI/CD system

Responsible for:

- building artifacts  
- preparing collections  
- performing signing  
- collecting timestamps and transparency evidence  
- staging releases  

Constraint:

CI/CD MUST NOT be trusted to publish independently  

---

#### Human authorization

Responsible for:

- validating release intent  
- approving publication  
- authorizing DNS updates when DNS is used according to this trust model  

This is the root of trust for publication.

---

#### TEA service

Responsible for:

- enforcing commit semantics  
- storing authoritative release state  
- exposing APIs  
- optionally publishing DNS trust anchors  

---

### Core mechanism — Commit step

The commit step is the critical control point.

It MUST:

- require strong authentication (e.g., MFA)  
- freeze the release  
- finalize the collection  
- record approver identity and time  
- attach evidence  
- validate signatures, timestamps, and transparency evidence  
- enforce trust-model compliance  
- optionally trigger DNS publication  
- reject trust-model violations  

---

### Key design principle

**CI/CD prepares — humans authorize — TEA commits**

---

### DNS publication behavior

When DNS is used according to this trust model:

- DNS publication happens at commit time  
- explicit approval is REQUIRED  
- the published certificate is the actual signing certificate  
- SAN DNS names are fingerprint-derived  

For WebPKI:

- DNS MUST NOT be used as a trust anchor  
- consumers MUST NOT treat DNS as a trust anchor  

---

### Transparency role

Transparency logs SHOULD include:

- discovery documents  
- certificates  
- artifacts  
- collections  

They provide:

- audit trail  
- misuse detection  
- long-term publication evidence  

---

### Ephemeral key security property

A key advantage of TEA:

- keys are generated per signing event  
- certificates are short-lived  
- private keys are deleted after use  

Normative statement:

Long-term trust is preserved by evidence (timestamp and transparency), not by persistent keys.

---

### Security implications

- minimal key exposure window  
- no long-term signing key to protect  
- reduced operational complexity  

---

### Lifecycle (CLE) publication

Lifecycle (CLE) updates follow the same controlled publication and authorization model as collections.

---

### Key security goal

Ensure that a release reflects:

- explicit authorization  
- verifiable intent  
- auditable publication  

---

## 4. How the Three Domains Connect

These domains form a chain of trust:

1. Discovery → identifies where to go  
2. Consumer validation → verifies what is received  
3. Publication → ensures what was published is legitimate  

They are independent but interdependent.

---

## 5. Important Insight

Most systems define only consumer validation.

TEA requires all three:

| Layer | Without it |
|------|------------|
| Discovery | You may talk to the wrong service |
| Consumer validation | You may accept incorrect artifacts |
| Publication | Unauthorized releases may appear valid |

---

## 6. Final Alignment Statement

This decomposition defines TEA:

1. Discovery trust → endpoint authenticity and authorization  
2. Consumer trust → artifact correctness, authenticity, and evidence validation  
3. Publication trust → publisher intent and controlled authorization  

---

## 🎯 Trust Model Principle

Trust in TEA is not derived from a single authority.

It emerges from the consistency of independent evidence sources:

- signatures  
- timestamps  
- transparency systems  
- DNS or PKI trust anchors  

Failure of one component does not automatically invalidate trust if the remaining evidence remains consistent and policy permits.