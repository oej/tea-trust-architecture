Here is a fully rewritten, architecture-aligned presentation outline.
It removes outdated concepts (two-layer, hybrid confusion), strengthens timestamps, clarifies TEA-native vs WebPKI, and highlights your strongest insight: short-lived keys → long-term trust.

⸻

🎤 TEA Trust Architecture — Full Presentation Outline (Rewritten)

⸻

1. Title

TEA Trust Architecture
End-to-end trust for transparency artifacts
	•	SBOMs, attestations, VEX — but verifiable
	•	Name / organization / date

⸻

2. The Core Problem

Transparency ≠ Trust

We can publish artifacts — but:
	•	Who signed them?
	•	Can I still trust them in 10 years?
	•	What happens if the vendor disappears?

⸻

3. Regulatory Pressure

CRA changes the requirements
	•	Long-term availability
	•	Verifiable integrity
	•	Lifecycle responsibility

👉 Trust must outlive infrastructure

⸻

4. What TEA Provides

Transparency Exchange API (TEA)
	•	Standardized API for:
	•	SBOMs
	•	attestations
	•	metadata
	•	Structured, machine-readable access

👉 TEA solves distribution

⸻

5. What TEA Does NOT Provide

TEA alone does not define:
	•	trust model
	•	trust anchor distribution
	•	validation rules
	•	long-term verification

👉 This is where the trust architecture comes in

⸻

6. TEA Trust Architecture (Overlay)

Adds:
	•	discovery protection
	•	explicit trust models
	•	trust-anchor publication
	•	validation rules
	•	long-term verification

👉 Turns transparency into trust

⸻

7. High-Level Architecture

Flow:

Manufacturer domain
→ Discovery (.well-known)
→ TEA API endpoint(s)
→ Trusted collection
→ Validation (WebPKI or TEA-native)

⸻

8. Design Principles
	•	Explicit over implicit
	•	No guessing
	•	Separation of concerns
	•	Short-lived secrets
	•	Long-term verifiability
	•	Decentralized trust anchors

⸻

9. Step 1: Discovery (Bootstrap)

Start from:

https://manufacturer/.well-known/tea

Purpose:
	•	identify TEA endpoints
	•	learn trust model
	•	bootstrap trust

⸻

10. Discovery in TEA Core

Provides:
	•	endpoints
	•	versions
	•	priorities

👉 Only answers:

“Where is the API?”

⸻

11. Discovery Problem

Missing:
	•	trust model
	•	endpoint roles
	•	trust-anchor linkage
	•	protection against tampering

👉 Discovery alone is not trustworthy

⸻

12. Discovery with Trust Overlay

Adds:
	•	required signature
	•	required timestamp
	•	trust model declaration
	•	endpoint roles (primary, persistence)
	•	operator type (manufacturer / third-party)

👉 Discovery becomes trusted bootstrap

⸻

13. Delegation Model
	•	Discovery remains on manufacturer domain
	•	API endpoints may be:
	•	manufacturer-hosted
	•	third-party hosted
	•	archive-hosted

👉 Identity stays with manufacturer
👉 Hosting becomes replaceable

⸻

14. Step 2: Fetch Collection

Consumer retrieves:
	•	TEA collection
	•	wrapped with trust information

⸻

15. Trusted Collection Concept

Key idea:
	•	collection defines what belongs to a release
	•	signature defines who approved it
	•	trust model defines how to validate it

⸻

16. Explicit Trust Models

Two models:
	•	WebPKI
	•	TEA-native

👉 Consumers MUST NOT infer
👉 Trust model is explicit

⸻

17. Validation Split
	•	WebPKI → CA-based validation
	•	TEA-native → DNS + timestamp + transparency

👉 No fallback
👉 No guessing

⸻

18. WebPKI Model
	•	Uses existing CA ecosystem
	•	Familiar enterprise model
	•	Simple validation

Optional strengthening:
	•	CAA records
	•	transparency monitoring

⸻

19. WebPKI Limitations
	•	dependent on CA ecosystem
	•	weaker long-term guarantees
	•	no inherent persistence model

⸻

20. TEA-Native Model

Key properties:
	•	self-signed certificates
	•	short-lived keys
	•	DNS publication of trust anchors
	•	timestamp + transparency support

👉 No long-term private key protection required

⸻

21. Trust Anchors in TEA-Native

Trust is anchored in:
	•	certificate (identity wrapper)
	•	timestamp (time proof)
	•	DNS publication (distribution)
	•	transparency log (auditability)

👉 No single point of trust

⸻

22. DNS Trust Anchor Publication

Published under:

<fingerprint>.teatrust.vendor.example

Properties:
	•	globally resolvable
	•	manufacturer-controlled
	•	survives infrastructure changes

DNSSEC:
	•	optional
	•	adds authenticity when present

⸻

23. Certificate Identity Model
	•	public key = identity
	•	certificate = wrapper
	•	SAN = identity binding

⸻

24. SAN Rules (TEA-Native)
	•	1 required manufacturer SAN
	•	1 optional persistence SAN
	•	maximum 2 SANs
	•	both must:
	•	be DNS names
	•	include the same fingerprint

👉 Identity = fingerprint-derived DNS name

⸻

25. Persistence SAN (Optional)

Supports:
	•	bankruptcy
	•	acquisition
	•	shutdown

Example:
	•	vendor: <fp>.vendor.com
	•	archive: <fp>.archive.net

⸻

26. No EKU / No Magic
	•	no special certificate semantics
	•	no EKU dependency
	•	no custom OIDs required

👉 Trust is defined externally, not in the certificate

⸻

27. Evidence and Time

TEA-native uses:
	•	timestamps (required)
	•	transparency logs (recommended)

Purpose:
	•	ordering of events
	•	long-term validation
	•	auditability

⸻

28. Critical Separation
	•	WebPKI does not use TEA-native evidence model
	•	TEA-native does not rely on PKIX chains

👉 Clean separation prevents ambiguity

⸻

29. Consumer Validation Flow
	1.	Fetch discovery
	2.	Verify signature + timestamp
	3.	Fetch collection
	4.	Read trust model
	5.	Validate accordingly

⸻

30. TEA-Native Validation Steps
	•	verify certificate profile
	•	verify SAN fingerprint binding
	•	resolve DNS publication
	•	compare certificate with DNS
	•	validate timestamp
	•	validate transparency (if present)
	•	verify signature

⸻

31. No-Inference Rule

Consumers MUST NOT rely on:
	•	SAN count alone
	•	EKU
	•	issuer
	•	algorithm

Only:
	•	explicit trust model
	•	defined validation rules

⸻

32. Lifecycle & Rotation
	•	certificates are short-lived
	•	keys are ephemeral
	•	no revocation dependency

Rotation via:
	•	new certificate
	•	DNS update
	•	new signed collection

⸻

33. Short-Lived Keys, Long-Term Trust

Key insight:
	•	private keys exist only during signing
	•	certificates expire quickly
	•	timestamps prove signing time
	•	transparency provides audit trail

👉 No long-term secret protection required

⸻

34. Long-Term Verification

Achieved through:
	•	timestamp validation
	•	transparency logs
	•	DNS-based anchor continuity
	•	persistence SAN (optional)

👉 Trust survives vendor disappearance

⸻

35. CRA Alignment

Supports:
	•	integrity
	•	authenticity
	•	traceability
	•	long-term verification

⸻

36. Deployment Models

Small / OSS:
	•	TEA-native
	•	minimal setup
	•	single SAN

Mid-size:
	•	TEA-native
	•	persistence SAN
	•	provider-hosted API

Enterprise:
	•	WebPKI or TEA-native
	•	depending on policy and ecosystem

⸻

37. Key Architecture Insight

Three layers:
	•	Discovery → where to connect
	•	Collection → what belongs to release
	•	Trust model → how to validate

⸻

38. Final Takeaway
	•	TEA publishes artifacts
	•	Discovery finds them
	•	Trust model defines validation
	•	TEA-native enables long-term trust

👉 Together: end-to-end verifiable transparency

⸻

39. Backup Slides
	•	discovery v2 JSON
	•	SAN examples
	•	DNS CERT examples
	•	validation flow diagrams
	•	threat model (STRIDE)

⸻

🎯 Final Message

Short-lived keys + distributed trust anchors + timestamps = long-term verifiability without long-term secrets

⸻

If you want next, I can turn this into:
	•	a speaker script, or
	•	a Keynote/PPT structure with slide layouts and visuals (clean, conference-ready).