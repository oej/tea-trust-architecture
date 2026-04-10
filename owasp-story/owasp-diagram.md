Here’s a conference-grade architecture diagram (conceptual + visual structure) you can directly turn into slides, diagrams, or design tools (Figma, Keynote, etc.). I’ve also included a clean visual version to anchor the layout.

⸻

🧭 TEA + OWASP Software Supply Chain Architecture

⸻

🎯 Diagram Structure (Conference-Ready Layout)

🔷 TOP LAYER — Manufacturer (Production + Publication)

Purpose: Create and publish trustworthy transparency artifacts

Blocks:
* Development / CI/CD
* Build pipeline
* Dependency resolution
* Artifact generation
* CycloneDX Generator
* SBOM (multiple types)
* VEX
* Attestations
* Lifecycle Engine (CLE)
* released
* endOfSupport
* endOfLife
* supersededBy
* Signing + Trust
* Short-lived certs
* TSA timestamp
* Transparency log
* TEA Publisher
* Publishes:
* SBOM
* VEX
* CLE
* Metadata

⸻

🔷 MIDDLE LAYER — TEA (Exchange + Trust Overlay)

Split visually into two horizontal bands:

1. TEA (Core API Layer)
* Discovery:
* .well-known/tea
* TEA service endpoints
* Artifact access:
* SBOMs
* VEX
* CLE
* Product + release mapping

👉 Label:

“Find the right artifacts for the right product and release”

⸻

2. TEA Trust Architecture (Overlay)
* Publisher signing trust
* Discovery trust
* Artifact trust

With supporting primitives:
* DNS (CERT, DNSSEC)
* Signatures
* TSA timestamps
* Transparency logs

👉 Label:

“Prove authenticity and enable long-term validation”

⸻

🔷 RIGHT SIDE — Consumer Platform (Decision Layer)

Examples: Dependency-Track, commercial platforms

Blocks:
* Ingestion
* TEA client
* SBOM / VEX / CLE retrieval
* Identity Resolution
* PURL parsing
* Component normalization
* Vulnerability Correlation
* CVE
* OSV.dev
* VEX Processing
* Exploitable vs not exploitable
* Lifecycle Awareness (CLE)
* Supported?
* End-of-life?
* Superseded?
* Policy + Risk Engine
* Risk scoring
* Alerts
* Compliance rules
* License Compliance
* OSS obligations
* Policy enforcement

⸻

🔷 BOTTOM LAYER — Supply Chain Flow (Critical Insight)

Add a horizontal flow showing:

Upstream suppliers → Manufacturer → Customer

Each publishes and consumes via TEA.

👉 Key label:

“Continuous, automated transparency across the supply chain”

⸻

🔑 Key Messages to Highlight in the Diagram

1. Everything is machine-readable
* SBOM (CycloneDX)
* VEX
* CLE
* PURL

⸻

2. TEA is the transport layer
* No manual portals
* No PDFs
* Fully automatable

⸻

3. Trust is externalized
* Not “trust the server”
* Trust is:
* cryptographic
* timestamped
* transparent

⸻

4. Lifecycle is first-class
* Not documentation
* Operational signal (CLE)

⸻

5. Upstream is integrated
* Manufacturers consume SBOM/VEX from suppliers
* Not just produce → also ingest

⸻

🧠 Optional Tagline for the Slide

“From static documentation to continuous, verifiable supply chain intelligence”

⸻

