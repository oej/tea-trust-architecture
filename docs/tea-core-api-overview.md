# TEA Consumer API Overview

## Specification Version

- Source: https://github.com/CycloneDX/transparency-exchange-api/blob/main/spec/openapi.yaml
- Version: 0.4.0

---

## Overview

The TEA Consumer API is a read-only interface for retrieving and validating transparency data.

It provides access to:

- Products and product releases
- Components and component releases
- Collections
- Artefacts
- Component Lookup Entries (CLE)
- Discovery resolution
- Compliance-document identifiers and related metadata

All endpoints in this specification are HTTP `GET` operations.

---

## Data Model Overview

### Product
Represents a logical product such as an application, firmware, or service.

- Identified by UUID
- May include external identifiers
- Parent object for product releases

---

### Product Release
Represents a specific released version of a product.

- Linked to exactly one product
- Can expose CLE data
- Can expose one or more collections
- Supports retrieval of latest collection and version-specific collections

---

### Component
Represents a reusable software component.

- Identified by UUID
- May include external identifiers
- Parent object for component releases

---

### Component Release
Represents a specific released version of a component.

- Linked to exactly one component
- Can expose CLE data
- Can expose one or more collections
- Can expose artefacts

---

### Collection
Represents an authoritative bundle associated with a product release or component release.

- Used to group release-related data
- Supports latest and version-specific retrieval
- Central aggregation object in TEA consumer workflows

---

### Artefact
Represents a distributable or retrievable object associated with a release.

Examples may include:

- binaries
- SBOMs
- release files
- other release-associated artefacts

Artefacts support latest-version retrieval and version-specific retrieval.

---

### CLE (Common Lifecycle Enumeration)
Represents lifecycle metadata associated with:

- product
- product release
- component
- component release

It is exposed through dedicated CLE endpoints for each of those entity types.

---

### Identifier
Represents a typed identifier.

The schema supports at least these identifier types:

- `CPE`
- `TEI`
- `PURL`
- `COMPLIANCE_DOCUMENT`

This means the API model explicitly supports compliance-document identifiers.  [oai_citation:1‡GitHub](https://raw.githubusercontent.com/CycloneDX/transparency-exchange-api/main/spec/openapi.yaml)

---

### Compliance Document Type
Represents a well-known compliance-document classification.

The spec defines a dedicated `compliance-document-type` schema and states that when `idType` is `COMPLIANCE_DOCUMENT`, the `idValue` should be one of those defined well-known document types.  [oai_citation:2‡GitHub](https://raw.githubusercontent.com/CycloneDX/transparency-exchange-api/main/spec/openapi.yaml)

This makes compliance documents part of the TEA consumer object model, even though they are not exposed as a separate endpoint family in this OpenAPI file.  [oai_citation:3‡GitHub](https://raw.githubusercontent.com/CycloneDX/transparency-exchange-api/main/spec/openapi.yaml)

---

### Discovery Response
Represents the result of resolving a TEI into TEA server objects.

The `/discovery` endpoint uses a `tei` query parameter and resolves that TEI into product-release-related information.  [oai_citation:4‡GitHub](https://raw.githubusercontent.com/CycloneDX/transparency-exchange-api/main/spec/openapi.yaml)

---

## Endpoint Summary

| Category | Endpoints |
|---|---:|
| Products | 3 |
| Product Releases | 5 |
| Components | 3 |
| Component Releases | 5 |
| Artefacts | 2 |
| CLE | 4 |
| Discovery | 1 |
| **Total** | **23** |

---

## Products

### `GET /products`
Returns a list of TEA products.

Used for product search and identifier-based matching.

**Documentation in OpenAPI:** Present

---

### `GET /product/{uuid}`
Returns a TEA product by UUID.

Used when the TEA product UUID is already known.

**Documentation in OpenAPI:** Present

---

### `GET /product/{uuid}/releases`
Returns releases belonging to a TEA product.

Used to enumerate product-release objects for a product.

**Documentation in OpenAPI:** Present

---

## Product Releases

### `GET /productReleases`
Returns a list of TEA product releases.

Supports pagination and identifier-based lookup.

**Documentation in OpenAPI:** Present

---

### `GET /productRelease/{uuid}`
Returns a TEA product release by UUID.

**Documentation in OpenAPI:** Present

---

### `GET /productRelease/{uuid}/cle`
Returns CLE data for a TEA product release.

Used for lifecycle state retrieval.

**Documentation in OpenAPI:** Present

---

### `GET /productRelease/{uuid}/collection/latest`
Returns the latest collection for a TEA product release.

Used when the caller wants the current authoritative collection.

**Documentation in OpenAPI:** Present

---

### `GET /productRelease/{uuid}/collection/{collectionVersion}`
Returns a specific collection version for a TEA product release.

Used for historical or version-specific collection retrieval.

**Documentation in OpenAPI:** Present

---

### `GET /productRelease/{uuid}/collections`
Returns all collections belonging to a TEA product release.

Used for enumerating collection history.

**Documentation in OpenAPI:** Present

---

## Components

### `GET /components`
Returns a list of TEA components.

Used for search and identifier matching.

**Documentation in OpenAPI:** Present

---

### `GET /component/{uuid}`
Returns a TEA component by UUID.

**Documentation in OpenAPI:** Present

---

### `GET /component/{uuid}/releases`
Returns releases belonging to a TEA component.

**Documentation in OpenAPI:** Present

---

## Component Releases

### `GET /componentReleases`
Returns a list of TEA component releases.

Supports pagination and identifier-based lookup.

**Documentation in OpenAPI:** Present

---

### `GET /componentRelease/{uuid}`
Returns a TEA component release with its latest collection.

**Documentation in OpenAPI:** Present

---

### `GET /componentRelease/{uuid}/cle`
Returns CLE data for a TEA component release.

**Documentation in OpenAPI:** Present

---

### `GET /componentRelease/{uuid}/collection/latest`
Returns the latest collection for a TEA component release.

**Documentation in OpenAPI:** Present

---

### `GET /componentRelease/{uuid}/collection/{collectionVersion}`
Returns a specific collection version for a TEA component release.

**Documentation in OpenAPI:** Present

---

### `GET /componentRelease/{uuid}/collections`
Returns all collections belonging to a TEA component release.

**Documentation in OpenAPI:** Present

---

## Artefacts

### `GET /artifact/{uuid}/latest`
Returns metadata for the latest revision of a TEA artefact.

**Documentation in OpenAPI:** Present

---

### `GET /artifact/{uuid}/{artifactVersion}`
Returns metadata for a specific revision of a TEA artefact.

**Documentation in OpenAPI:** Present

---

## CLE Endpoints

### `GET /product/{uuid}/cle`
Returns CLE data for a TEA product.

**Documentation in OpenAPI:** Present

---

### `GET /productRelease/{uuid}/cle`
Returns CLE data for a TEA product release.

**Documentation in OpenAPI:** Present

---

### `GET /component/{uuid}/cle`
Returns CLE data for a TEA component.

**Documentation in OpenAPI:** Present

---

### `GET /componentRelease/{uuid}/cle`
Returns CLE data for a TEA component release.

**Documentation in OpenAPI:** Present

---

## Discovery

### `GET /discovery`
Discovery endpoint that resolves a TEI into product-release-related TEA objects.

It takes a required `tei` query parameter.

**Documentation in OpenAPI:** Present

---

## Compliance Documents in the Consumer API

The consumer OpenAPI does not currently define a separate family of dedicated compliance-document endpoints.

However, compliance documents are still part of the model through:

- `identifier-type = COMPLIANCE_DOCUMENT`
- the dedicated `compliance-document-type` schema

That means compliance documents are represented as a recognized identifier/document category within the TEA consumer model.  [oai_citation:5‡GitHub](https://raw.githubusercontent.com/CycloneDX/transparency-exchange-api/main/spec/openapi.yaml)

This is important because it means the API already has semantic support for compliance-document references, even though retrieval appears to be integrated into the broader TEA object model rather than exposed through separate dedicated endpoints.  [oai_citation:6‡GitHub](https://raw.githubusercontent.com/CycloneDX/transparency-exchange-api/main/spec/openapi.yaml)

---

## Documentation Coverage

Every current endpoint in the consumer OpenAPI has an operation-level description. Based on the current file, there are no completely undocumented endpoints.  [oai_citation:7‡GitHub](https://raw.githubusercontent.com/CycloneDX/transparency-exchange-api/main/spec/openapi.yaml)

---

## Observations

1. The API is strictly read-only.
2. UUID-based retrieval is consistent across the model.
3. CLE is exposed uniformly across all major entity levels.
4. Collections are version-aware and support both latest and historical retrieval.
5. Compliance documents are present in the data model, but not as their own endpoint family in this file.  [oai_citation:8‡GitHub](https://raw.githubusercontent.com/CycloneDX/transparency-exchange-api/main/spec/openapi.yaml)

---

## Conclusion

The TEA Consumer API is broader than a simple product/component lookup API. It covers release history, collections, artefacts, lifecycle data, discovery, and compliance-document-aware identifiers. The main structural gap is not lack of compliance-document modeling, but lack of dedicated compliance-document endpoints in the current consumer OpenAPI file.  [oai_citation:9‡GitHub](https://raw.githubusercontent.com/CycloneDX/transparency-exchange-api/main/spec/openapi.yaml)

## API Flow Examples

This section shows two common consumer flows starting from a TEI.

### Flow 1: TEI → discovery → product release → collection → SBOM

This is the most direct flow when the client starts with a TEI and wants the authoritative collection for a product release, then locate the SBOM artefact.

#### Step 1: Resolve the TEI through discovery

Call the discovery endpoint with the TEI as a query parameter:

```http
GET /discovery?tei=<url-encoded-tei>
```

The consumer OpenAPI defines `/discovery` specifically to resolve a TEI into product-release-related TEA objects.  [oai_citation:0‡GitHub](https://raw.githubusercontent.com/CycloneDX/transparency-exchange-api/main/spec/openapi.yaml)

#### Step 2: Retrieve the product release

Use the UUID returned by discovery:

```http
GET /productRelease/{uuid}
```

This returns the TEA product release object.  [oai_citation:1‡GitHub](https://raw.githubusercontent.com/CycloneDX/transparency-exchange-api/main/spec/openapi.yaml)

#### Step 3: Retrieve the latest collection for the product release

```http
GET /productRelease/{uuid}/collection/latest
```

If a specific collection version is needed instead of the latest one:

```http
GET /productRelease/{uuid}/collection/{collectionVersion}
```

The consumer OpenAPI also supports listing all collections for a product release:

```http
GET /productRelease/{uuid}/collections
```

These endpoints provide latest, version-specific, and enumerated collection access.  [oai_citation:2‡GitHub](https://raw.githubusercontent.com/CycloneDX/transparency-exchange-api/main/spec/openapi.yaml)

#### Step 4: Inspect the collection and identify the SBOM artefact

The collection object is the authoritative bundle for the release and is the place where a client can identify the artefact UUID or artefact references associated with the release. The artefact metadata can then be retrieved via the artefact endpoints.  [oai_citation:3‡GitHub](https://raw.githubusercontent.com/CycloneDX/transparency-exchange-api/main/spec/openapi.yaml)

#### Step 5: Retrieve the SBOM artefact metadata

If the SBOM artefact UUID is known from the collection:

```http
GET /artifact/{uuid}/latest
```

or, for a specific artefact version:

```http
GET /artifact/{uuid}/{artifactVersion}
```

These endpoints return metadata for TEA artefacts.  [oai_citation:4‡GitHub](https://raw.githubusercontent.com/CycloneDX/transparency-exchange-api/main/spec/openapi.yaml)

#### Summary

```text
TEI
  → /discovery
  → /productRelease/{uuid}
  → /productRelease/{uuid}/collection/latest
  → inspect collection for SBOM artefact
  → /artifact/{uuid}/latest
```

---

### Flow 2: TEI → discovery → product → product releases → select release → collection

This flow is useful when the TEI resolves to a product and the consumer wants to choose among multiple product releases before retrieving a collection.

#### Step 1: Resolve TEI through discovery

```http
GET /discovery?tei=<url-encoded-tei>
```

Discovery resolves the TEI into TEA product-release-related information.  [oai_citation:5‡GitHub](https://raw.githubusercontent.com/CycloneDX/transparency-exchange-api/main/spec/openapi.yaml)

#### Step 2: Retrieve the product

If the resolved data includes the product UUID, or once the product UUID is otherwise known:

```http
GET /product/{uuid}
```

This returns the TEA product object.  [oai_citation:6‡GitHub](https://raw.githubusercontent.com/CycloneDX/transparency-exchange-api/main/spec/openapi.yaml)

#### Step 3: List releases for that product

```http
GET /product/{uuid}/releases
```

This allows the client to choose the product release it is interested in.  [oai_citation:7‡GitHub](https://raw.githubusercontent.com/CycloneDX/transparency-exchange-api/main/spec/openapi.yaml)

#### Step 4: Retrieve the selected product release

```http
GET /productRelease/{uuid}
```

This gives the selected product release in full.  [oai_citation:8‡GitHub](https://raw.githubusercontent.com/CycloneDX/transparency-exchange-api/main/spec/openapi.yaml)

#### Step 5: Retrieve the latest or specific collection

Latest collection:

```http
GET /productRelease/{uuid}/collection/latest
```

Specific collection version:

```http
GET /productRelease/{uuid}/collection/{collectionVersion}
```

Or enumerate all collections first:

```http
GET /productRelease/{uuid}/collections
```

 [oai_citation:9‡GitHub](https://raw.githubusercontent.com/CycloneDX/transparency-exchange-api/main/spec/openapi.yaml)

#### Summary

```text
TEI
  → /discovery
  → /product/{uuid}
  → /product/{uuid}/releases
  → /productRelease/{uuid}
  → /productRelease/{uuid}/collection/latest
```

---

### Flow 3: Product or product release → component selection → component release → collection → SBOM

This flow is useful when the consumer starts from a product or product release, then wants to inspect a specific component and its release-level collection.

#### Step 1: Resolve or retrieve the product context

Possible starting points:

```http
GET /discovery?tei=<url-encoded-tei>
GET /product/{uuid}
GET /productRelease/{uuid}
```

Depending on the starting point, the client obtains a product or product release context.  [oai_citation:10‡GitHub](https://raw.githubusercontent.com/CycloneDX/transparency-exchange-api/main/spec/openapi.yaml)

#### Step 2: Find the component

If the component is known by identifier, query the component list endpoint:

```http
GET /components?idType=<type>&idValue=<value>
```

If the component UUID is already known:

```http
GET /component/{uuid}
```

The consumer OpenAPI defines both component query and direct component retrieval.  [oai_citation:11‡GitHub](https://raw.githubusercontent.com/CycloneDX/transparency-exchange-api/main/spec/openapi.yaml)

#### Step 3: List releases of that component

```http
GET /component/{uuid}/releases
```

This returns the releases for the chosen component.  [oai_citation:12‡GitHub](https://raw.githubusercontent.com/CycloneDX/transparency-exchange-api/main/spec/openapi.yaml)

#### Step 4: Retrieve the selected component release

```http
GET /componentRelease/{uuid}
```

This endpoint returns the TEA component release with its latest collection.  [oai_citation:13‡GitHub](https://raw.githubusercontent.com/CycloneDX/transparency-exchange-api/main/spec/openapi.yaml)

#### Step 5: Retrieve collection data for the component release

Latest collection:

```http
GET /componentRelease/{uuid}/collection/latest
```

Specific collection version:

```http
GET /componentRelease/{uuid}/collection/{collectionVersion}
```

Or enumerate all collections:

```http
GET /componentRelease/{uuid}/collections
```

 [oai_citation:14‡GitHub](https://raw.githubusercontent.com/CycloneDX/transparency-exchange-api/main/spec/openapi.yaml)

#### Step 6: Inspect the collection and retrieve the SBOM artefact metadata

Once the collection identifies the relevant artefact UUID, retrieve the SBOM artefact metadata:

```http
GET /artifact/{uuid}/latest
```

or:

```http
GET /artifact/{uuid}/{artifactVersion}
```

 [oai_citation:15‡GitHub](https://raw.githubusercontent.com/CycloneDX/transparency-exchange-api/main/spec/openapi.yaml)

#### Summary

```text
TEI or product context
  → /components or /component/{uuid}
  → /component/{uuid}/releases
  → /componentRelease/{uuid}
  → /componentRelease/{uuid}/collection/latest
  → inspect collection for SBOM artefact
  → /artifact/{uuid}/latest
```

---

### Notes on CLE in these flows

If the consumer also needs lifecycle information, it can retrieve CLE at any of the main entity levels:

```http
GET /product/{uuid}/cle
GET /productRelease/{uuid}/cle
GET /component/{uuid}/cle
GET /componentRelease/{uuid}/cle
```

These are optional lifecycle lookups alongside the main product, release, collection, and artefact retrieval flow.  [oai_citation:16‡GitHub](https://raw.githubusercontent.com/CycloneDX/transparency-exchange-api/main/spec/openapi.yaml)
