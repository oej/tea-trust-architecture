Understood — let’s do this properly.

Below is a fully rewritten, publication-grade TEI specification that:
	•	Keeps your strict processing model (opaque, no parsing, no rejection of unknown types)
	•	Keeps governance for producers
	•	Restores educational narrative, rationale, and examples
	•	Reads like a cohesive spec, not a checklist

⸻

Transparency Exchange Identifier (TEI) Specification

Version: 1.0
Status: Draft for Implementation

⸻

1. Introduction

The Transparency Exchange Identifier (TEI) provides a uniform way to identify software products within the Transparency Exchange API (TEA) ecosystem.

A TEI is designed to be:
	•	Globally unique, within a publisher-controlled namespace
	•	Resolvable, via DNS-based discovery
	•	Stable over time, supporting long-term traceability
	•	Simple to process, requiring no interpretation of embedded identifiers

Unlike many identifier systems, TEI does not attempt to define a new global identifier scheme. Instead, it reuses existing identifiers (such as Package URLs or CPEs) and binds them to a DNS authority that provides discovery and context.

This design aligns with modern software transparency needs, including regulatory requirements such as the Cyber Resilience Act (CRA), where product information must be accessible throughout the lifecycle — including before purchase.

⸻

2. Core Concept

A TEI is constructed from three elements:
	•	a DNS authority (who owns the product identity)
	•	an identifier type (what kind of identifier is used)
	•	an encoded identifier value

Together, these form a unique identifier within the authority’s namespace.

tei://<authority>/<type>/<encoded-id>[?version=<string>]

2.1 Uniqueness Model

The combination of:

<authority> + <type> + <encoded-id>

MUST uniquely identify a product within the authority domain.

This means:
	•	Different vendors can reuse the same identifier value without collision
	•	The authority domain provides namespacing and ownership
	•	No global registry is required

⸻

3. Processing Model (Key Design Principle)

TEI is intentionally designed to be simple and robust for consumers.

3.1 Opaque Handling Requirement

Implementations MUST treat TEI as an opaque identifier.

This means:
	•	MUST NOT parse the identifier value
	•	MUST NOT depend on the semantics of <type>
	•	MUST NOT require understanding of the underlying identifier scheme
	•	MUST NOT reject a TEI solely because the <type> is unknown

A TEI is, from a consumer perspective, simply a stable lookup key.

⸻

3.2 Rationale

This design avoids several common failure modes:
	•	tight coupling to specific identifier formats
	•	breakage when new identifier types are introduced
	•	inconsistent parsing logic across implementations

By treating TEI as opaque:
	•	systems remain forward-compatible
	•	interoperability is preserved
	•	implementation complexity is minimized

⸻

3.3 Optional Enrichment

Implementations MAY:
	•	decode the identifier
	•	interpret known types (e.g., purl, cpe)
	•	enrich user interfaces or analytics

However:

Such behavior MUST remain optional and MUST NOT affect core TEI resolution.

⸻

4. Components

4.1 Authority

The authority is a DNS domain controlled by the product publisher.

Example:

acme.example.com

The authority serves two purposes:
	1.	Namespace control — ensuring identifier uniqueness
	2.	Discovery anchor — enabling TEA lookup

Requirement:
	•	The authority MUST correspond to the domain used for TEA discovery

⸻

4.2 Type

The <type> identifies which identifier scheme is used.

Examples include:

Type	Description
purl	Package URL (ECMA-427)
cpe	Common Platform Enumeration
swid	ISO/IEC 19770-2
ean	European Article Number
gtin	Global Trade Item Number
asin	Amazon Standard Identification Number
uuid	UUID (fallback only)


⸻

4.3 Encoded Identifier

The identifier value is encoded using BASE64url (RFC 4648).

This ensures:
	•	safe embedding in URLs
	•	no reserved character conflicts
	•	consistent parsing across environments

Example:

Original identifier:

pkg:docker/acme/widget

Encoded:

cGtnOmRvY2tlci9hY21lL3dpZGdldA


⸻

4.4 Version (Optional)

The optional version parameter specifies a particular release:

?version=1.2.3

Important distinction:
	•	TEI identifies the product
	•	Version identifies a release instance

⸻

5. Type Governance (Producer Perspective)

While TEI is opaque for consumers, the set of types is not arbitrary.

5.1 Governance Model

New TEI types:
	•	SHOULD be proposed through the TEA working group
	•	SHOULD represent established identifier schemes
	•	SHOULD provide interoperability value

The TEA working group is open to receiving proposals for new types.

⸻

5.2 Guidance for Manufacturers

Manufacturers:
	•	SHOULD use existing, recognized identifier types
	•	SHOULD avoid defining private or ad-hoc types
	•	SHOULD prioritize identifiers already used in SBOMs or ecosystems

This ensures consistency across tooling and ecosystems.

⸻

5.3 Important Distinction

There is a deliberate asymmetry:

Role	Requirement
Producers	Controlled type usage
Consumers	Fully tolerant, no assumptions


⸻

6. Examples

6.1 Basic TEI

tei://acme.example.com/purl/cGtnOmRvY2tlci9hY21lL3dpZGdldA


⸻

6.2 TEI with Version

tei://acme.example.com/purl/cGtnOmRvY2tlci9hY21lL3dpZGdldA?version=1.2.3


⸻

6.3 Hardware Identifier Example

tei://manufacturer.eu/ean/NDIxMjM0NTY3ODkw


⸻

6.4 Marketplace Example

tei://marketplace.example/asin/QjAwMTIzNDU2


⸻

6.5 UUID Fallback Example

tei://startup.io/uuid/MTIzZTQ1NjctZTg5Yi0xMmQzLWE0NTYtNDI2NjE0MTc0MDAw


⸻

7. Resolution Model

7.1 Discovery Entry Point

A TEI is resolved by querying:

https://<authority>/.well-known/tea

This returns a TEA discovery document.

⸻

7.2 DNS Behavior

Resolution may involve:
	•	A and AAAA records
	•	SVCB and HTTPS DNS record types

These DNS records may provide:
	•	endpoint discovery
	•	connection optimization

Use of DNSSEC is RECOMMENDED.

⸻

7.3 Discovery Document (Example)

{
  "schemaVersion": 2,
  "issuer": "manufacturer.example.com",
  "trustModelsSupported": ["webpki", "taps"],
  "defaultTrustModel": "taps",
  "endpoints": [
    {
      "url": "https://api.manufacturer.example.com/tea",
      "versions": ["1.0.0"],
      "priority": 1,
      "role": "primary",
      "operatorType": "manufacturer"
    }
  ]
}


⸻

7.4 Resolution Flow

A consumer typically:
	1.	extracts <authority> from the TEI
	2.	retrieves the discovery document
	3.	selects endpoint and trust model
	4.	retrieves TEA data

⸻

8. Validation

Validation is intentionally minimal.

A TEI is valid if:
	•	syntax is correct
	•	authority is a valid DNS name
	•	encoding is valid BASE64url

Importantly:

Implementations MUST NOT validate identifier semantics.

⸻

9. Security Considerations

9.1 Transport Security
	•	HTTPS is REQUIRED
	•	TLS 1.3 or higher MUST be used
	•	Plain HTTP MUST NOT be used

⸻

9.2 DNS Security

DNSSEC is RECOMMENDED to protect discovery.

⸻

9.3 Trust Model

TEI itself provides no trust.

Trust is established through:
	•	TEA trust architecture
	•	signatures
	•	transparency logs
	•	DNS trust anchors

⸻

9.4 CRA Alignment

TEI enables “insights before purchase” by allowing:
	•	customers
	•	auditors
	•	regulators

to retrieve product transparency data prior to acquisition.

⸻

10. Interoperability and Use Cases

10.1 SBOM Integration

TEI can be used as a stable identifier in SBOMs.

⸻

10.2 Asset Inventory Integration

Organizations can store TEI in asset inventories to:
	•	correlate assets with SBOMs
	•	track vulnerabilities
	•	manage lifecycle risk

⸻

11. Distribution to End Users

To support accessibility, TEI SHOULD be made available via:
	•	QR codes on packaging
	•	software “About” menus
	•	invoices and delivery documents

This ensures TEI remains accessible throughout the product lifecycle.

⸻

12. Summary

TEI provides:
	•	a globally unique identifier model without a central registry
	•	a simple, opaque processing model for consumers
	•	a governed identifier ecosystem for producers
	•	strong alignment with modern transparency and regulatory requirements

⸻

13. References
	•	ECMA-427 (purl): https://tc54.org/purl/
	•	NIST CPE: https://nvd.nist.gov/products/cpe
	•	RFC 4648 (Base64url): https://www.rfc-editor.org/rfc/rfc4648
	•	RFC 8446 (TLS 1.3)
	•	Transparency Exchange API: https://github.com/CycloneDX/transparency-exchange-api

⸻

✅ Final Result

This version now:
	•	clearly explains why TEI is designed this way
	•	preserves your strict “opaque + tolerant” processing model
	•	keeps type governance without breaking consumers
	•	reads like a proper, teachable specification

⸻

If you want one final upgrade:

👉 I can convert this into RFC style (BCP 14 language, ABNF, conformance sections)
👉 or align it structurally with your TEA trust architecture docs (same tone and layering)