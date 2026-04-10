# TEA Security Profile  
Transparency Exchange API — Security and Trust Model

---
## Status

This document is informative and describes the TEA security model.
Normative requirements are defined in the TEA Core Trust Architecture and related specifications.

## 1. Purpose

The Transparency Exchange API (TEA) enables distribution and validation of software transparency artefacts such as SBOMs, attestations, and related metadata. This security profile defines how trust is established, maintained, and verified across the TEA ecosystem.

The objective is to ensure that a consumer can reliably determine that a set of artefacts is authentic, unmodified, and correctly associated with a specific software release, and that the publication of that release reflects the authorized intent of the manufacturer.

---

## 2. Trust Architecture Overview

TEA establishes trust across three interconnected domains: discovery, consumer validation, and publication.

Discovery ensures that a consumer connects to the correct TEA service endpoint for a given manufacturer. Consumer validation ensures that the artefacts and collections retrieved from that service are authentic, correctly bound to a release context, and supported by the required evidence. Publication ensures that the data exposed through the TEA service reflects an authorized and auditable decision by the manufacturer.

These three domains form a chain of trust. Discovery identifies where to connect, consumer validation determines what is trusted, and publication ensures that what is exposed represents legitimate manufacturer intent.

---

## 3. Core Security Principles

TEA is built on a strict separation of concerns. Artefact authenticity, release definition, integrity binding, timing evidence, and publication authorization are handled independently.

Artefact signatures establish authenticity of individual artefacts. Collection signatures establish the publisher’s assertion of which artefacts belong to a release. Checksums embedded in the signed collection bind exact artefact bytes to that assertion. Timestamps establish that signatures existed within the validity period of the signing certificate. Transparency logs provide publication evidence and auditability. Publication authorization ensures that a validly signed release is also an authorized release.

The architecture prefers short-lived signing keys and avoids long-term private key protection. Instead of relying primarily on revocation, TEA relies on timestamps and transparency logs to provide durable and auditable trust over time. Trust is distributed across multiple mechanisms rather than being concentrated in a single infrastructure component.

Trust in TEA is not derived from a single authority. It emerges from the consistency of independent evidence sources:
* signatures
* timestamps
* transparency systems
* DNS or PKI trust anchors

---

## 4. Identity and Key Model

In TEA, identity is defined by a public key. Certificates are used as wrappers to provide validity periods, interoperability, and accountability metadata, but they are not the identity itself.

For TEA-native signing, Ed25519 is the preferred algorithm due to its compact size and suitability for DNS-based distribution. Each TEA-native signing certificate must contain a fingerprint-derived SAN DNS name. The required SAN form is:

```text
<fingerprint>.<trust-domain>
```

where fingerprint is the lowercase hexadecimal SHA-256 digest of the public key.

An optional persistence SAN may also be included:

```text
<fingerprint>.<persistence-domain>
```

This supports continuity when the original manufacturer domain changes hands, disappears, or becomes unavailable.

Certificate subjects may contain descriptive metadata such as organization and country, but they are not trust anchors. The Common Name field is not used for identity and must not be relied upon. If a legal entity exists, subject O is required to contain that legal name.

Signing certificates must be short-lived. A maximum validity of 24 hours is recommended, with shorter durations such as five hours preferred. Long-lived signing certificates are contrary to the intended TEA-native security model. Private keys are expected to be ephemeral and destroyed immediately after use.

---

## 5. Trust Anchors and Distribution

TEA supports two trust models:
* TEA-native
* WebPKI

In the TEA-native model, the certificate used for signature verification MUST be published in DNS using CERT records under the fingerprint-derived SAN DNS name. DNS publication is required. DNSSEC is optional. When DNSSEC is present, it provides authenticated distribution of the published certificate. When DNSSEC is absent, DNS still provides a required publication channel, but not authenticated publication on its own.

In the WebPKI model, trust is established through standard PKIX certificate validation. DNS-based TEA trust anchoring is not used. However, DNS may still provide security-relevant policy signals such as CAA. DNSSEC, when present, strengthens those DNS policy signals but does not turn them into TEA trust anchors.

Consumers should support both models. TEA-native provides direct publisher-controlled anchor publication and strong alignment with the ephemeral-key model. WebPKI provides compatibility with existing enterprise and public CA infrastructures.

---

## 6. Signature Model

TEA defines two distinct types of signatures:
* collection signatures
* artefact signatures

A collection signature is mandatory. It authenticates the publisher’s statement that a specific set of artefacts, identified by checksums, belongs to a particular collection version and release context. Because the checksums are included in the signed collection, the collection signature binds exact artefact bytes to that statement.

Artefact signatures are optional in core TEA but recommended, and may be required by stricter deployment policies. They provide independent authenticity of individual artefacts and may be either detached or embedded within the artefact format.

The two signature types serve different purposes. The collection defines what belongs to a release. The artefact signature defines what the artefact is. These roles are complementary and must not be conflated.

---

## 7. Discovery Security

Discovery is the bootstrap phase in which a consumer identifies the correct TEA service endpoint for a manufacturer.

This phase relies on TLS as a baseline for secure retrieval, but must not rely on transport security alone. Discovery signing is REQUIRED and discovery timestamping is REQUIRED. This ensures that endpoint authorization is cryptographically verifiable and temporally anchored.

Discovery timestamps are REQUIRED to:
* prevent replay of stale endpoint mappings
* prevent backdating of discovery documents
* provide a verifiable authorization time for endpoint delegation

A valid discovery statement establishes that the manufacturer authorized the advertised endpoint set at a verifiable time. Optional transparency evidence may further strengthen auditability and later review.

The primary security objective in discovery is to prevent redirection to malicious endpoints and to prevent replay of stale endpoint authorization.

---

## 8. Consumer Validation

Consumer validation is the core of the TEA trust model.

A consumer MUST:
* validate the collection signature
* validate the collection timestamp
* extract the checksums from the collection
* compute the digest of each artefact
* compare computed digests with collection checksums

If artefact signatures are present, the consumer SHOULD validate them according to the artefact format and applicable policy.

Consumers SHOULD validate transparency evidence where required by policy or trust model.

Consumers must support the possibility that:
* a single artefact may appear in multiple collections
* a single release may have multiple collection versions

The strongest validation conclusion is:

An artefact matches a checksum in a signed collection, the collection timestamp is valid, and therefore the artefact is part of the publisher-approved artefact set for that release context. If an artefact signature is also valid, the artefact itself is independently authenticated.

---

## 9. Publication Security

Publication is the most critical trust boundary in TEA. It ensures that the data exposed through the TEA service reflects authorized manufacturer intent.

CI/CD systems may prepare artefacts and perform signing operations, but MUST NOT have authority to publish releases independently.

The commit step MUST:
* require strong authentication (e.g., MFA)
* validate all relevant properties
* freeze the release
* record approver identity and time
* attach evidence
* enforce trust-model constraints

DNS publication of TEA-native certificates MUST:
* be explicitly authorized
* be tied to the commit process
* validate certificate properties before publication

The fundamental principle is:

CI/CD prepares — humans authorize — TEA commits

---

## 10. Transparency and Time

Transparency logs provide auditability and proof of existence. Certificates, artefacts, and collections SHOULD be submitted to a transparency system such as:
* Rekor
* Sigsum
* SCITT

### Timestamp Role

Timestamps provide:
* evidence that a signature existed at a specific time
* protection against backdating
* support for long-term validation after certificate expiry

Timestamp is a primary trust component enabling long-term validation independent of certificate lifetime.

For TEA-native deployments:
* timestamp validation is REQUIRED

### Timestamp Binding (CRITICAL)

The timestamp MUST bind to the digital signature over the object, not merely the raw artefact or collection.

For RFC 3161 timestamps:

```text
messageImprint == hash(signature)
```

The timestamp MUST satisfy:

```text
timestamp ∈ [certificate.notBefore, certificate.notAfter]
```

### Transparency Binding (CRITICAL)

Transparency evidence MUST refer to the same signed object, or the same timestamped-signature object, that is being validated.

Transparency entries that cannot be cryptographically bound to the validated signature chain MUST be rejected.

### Multi-TSA Recommendation

Implementations SHOULD:
* use multiple TSAs
* validate drift between timestamps
* periodically validate time consistency

---

## 11. Evidence Bundles

TEA implementations SHOULD support packaging validation material into an evidence bundle containing:

* signatures
* certificates
* timestamps
* transparency evidence

This enables:
* offline validation
* long-term verification
* interoperability between TEA implementations

---

## 12. Threat Mitigation Summary

The TEA security model addresses threats identified through STRIDE analysis.

Spoofing is mitigated through:
* TEA-native DNS publication
* SAN fingerprint validation
* timestamps
* transparency logs
* CAA (WebPKI)

Tampering is mitigated through:
* collection signatures
* checksum binding
* artefact signatures

Repudiation is mitigated through:
* timestamps
* transparency logs
* audit logs

Denial of service is mitigated through:
* caching
* redundancy
* stored evidence

Critical risks include:
* weak publication authorization
* misuse of long-lived certificates

---

## 13. Normative Requirements

TEA implementations MUST:
* validate collection signatures
* validate required timestamps
* verify artefact checksums
* enforce certificate lifetime limits
* require strong publication authorization
* prevent unauthorized modification

TEA implementations SHOULD:
* support artefact signatures
* support transparency logging
* support DNS-based trust (TEA-native)
* support DNSSEC validation when available
* support CAA validation (WebPKI)
* maintain audit logs

TEA implementations MAY:
* support multiple trust models
* use multiple TSAs
* use multiple transparency systems

---

## 14. Residual Risk and Final Assessment

Residual risks include:
* CA compromise
* DNS dependency
* TSA/transparency reliability

These are mitigated through:
* multi-anchor trust
* redundancy
* cross-validation

TEA avoids reliance on long-lived private keys and distributes trust across independent systems.

---

## 15. Conclusion

TEA provides a secure and flexible model for distributing software transparency artefacts.

By combining:
* signed collections
* checksum binding
* optional artefact signatures
* timestamps
* transparency logs
* controlled publication

TEA enables long-term validation without reliance on long-lived signing secrets.

The architecture is resilient against supply chain threats and aligns with lifecycle-oriented regulatory expectations.

The most critical requirement is:

Publication must reflect authorized intent.

If this condition is met, TEA provides strong guarantees of:
* integrity
* authenticity
* auditability
* long-term verifiability
