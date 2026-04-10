# 📘 TEA Event Delivery Specification (Proposal)

---

## 1. Scope

This specification defines a **generic TEA publisher event delivery model** for asynchronous notifications about publisher-side workflow activity.

It supports:

- webhook delivery over HTTPS  
- message bus and queue-based delivery (future)  
- internal ↔ external TEA service propagation  
- audit and approval workflow integration  

The **event format is transport-independent**.

---

## 2. Design Principles

### 2.1 Transport Independence
Events MUST be identical regardless of delivery mechanism.

---

### 2.2 Independent Trust
Events MUST be integrity-protected and authenticated independently of TLS.

---

### 2.3 Optional Confidentiality
Events MAY be encrypted independently of transport.

---

### 2.4 Audit Alignment
Each event MUST map to a corresponding audit event.

---

## 3. Three-Layer Security Model

### 3.1 Layer 1 — Transport Security

- HTTPS SHOULD be used  
- TLS provides channel protection  

However:

> TLS MUST NOT be the sole security mechanism

---

### 3.2 Layer 2 — Message Integrity and Authenticity (REQUIRED)

All events MUST be signed.

This ensures:

- sender authenticity  
- payload integrity  
- non-repudiation  

---

### 3.3 Layer 3 — Message Confidentiality (OPTIONAL)

Events MAY be encrypted using a receiver public key.

This enables:

- secure relay through intermediaries  
- protection beyond TLS  
- message bus compatibility  

---

## 4. Event Envelope

All TEA events MUST follow a common structure.

```json
{
  "specVersion": "1.0",
  "eventType": "collection.readyForSigning",
  "eventId": "018f0d4a-8b2c-7cc2-a4b0-9f15c6f1db14",
  "occurredAt": "2026-04-07T16:00:00Z",
  "source": {
    "serviceId": "tea.publisher.example.com",
    "serviceType": "publisher-api"
  },
  "actor": {
    "type": "system",
    "id": "ci-system"
  },
  "subject": {
    "type": "collection",
    "id": "col-123"
  },
  "auditEventId": "TEA-PUB-COLLECTION-READY-FOR-SIGNING",
  "data": {
    "releaseId": "rel-456",
    "collectionVersion": 3
  }
}
```

---

## 5. Event Naming

Events MUST follow:

```
<domain>.<action>
```

Examples:

- `artifact.uploaded`  
- `collection.readyForSigning`  
- `collection.published`  
- `authorization.error`  

---

## 6. Event Categories

### 6.1 Collection Workflow
- collection.created  
- collection.updated  
- collection.readyForSigning  
- collection.signed  
- collection.validationFailed  
- collection.published  

---

### 6.2 Artifact Lifecycle
- artifact.uploaded  
- artifact.published  
- artifact.archived  
- artifact.garbageCollected  

---

### 6.3 Approval and Publication
- approval.required  
- approval.granted  
- approval.rejected  
- publication.commitStarted  
- publication.committed  
- publication.failed  

---

### 6.4 Security Events
- authorization.error  
- authentication.error  
- validation.error  
- policy.error  

---

### 6.5 Lifecycle Management
- product.archived  
- release.archived  
- cle.updated  

---

## 7. Audit Binding

Every event MUST correspond to an internal audit event.

Example:

```json
{
  "eventType": "authorization.error",
  "auditEventId": "TEA-PUB-AUTHORIZATION-ERROR"
}
```

---

## 8. Message-Level Signing

Events MUST be signed.

### 8.1 Canonicalization

JSON payloads SHOULD use RFC 8785 canonicalization.

---

### 8.2 Structure

```json
{
  "payload": { ...event... },
  "signature": {
    "format": "jws-detached",
    "algorithm": "EdDSA",
    "value": "BASE64URL..."
  },
  "signer": {
    "keyId": "events-2026-04",
    "verificationMethod": "https://tea.publisher.example.com/event-keys"
  }
}
```

---

## 9. Receiver Confidentiality

Implementations MAY support encryption.

Example:

```json
"deliverySecurity": {
  "encryptionMode": "payload",
  "recipientPublicKey": {
    "format": "jwk",
    "value": {
      "kty": "OKP",
      "crv": "X25519",
      "x": "..."
    }
  }
}
```

---

## 10. Sender Key Distribution

Implementations SHOULD expose verification keys:

```
GET /event-keys
```

This supports:

- key rotation  
- third-party validation  

---

## 11. Delivery Targets

Targets MUST support multiple transport types.

Example:

```json
{
  "target": {
    "type": "webhook",
    "url": "https://example.org/events"
  }
}
```

Future-compatible:

```json
{
  "target": {
    "type": "messageBus",
    "address": "tea.publisher.events",
    "protocol": "amqp"
  }
}
```

---

## 12. Subscription Model

Example:

```json
POST /event-subscriptions
{
  "target": {
    "type": "webhook",
    "url": "https://example.org/events"
  },
  "events": [
    "collection.readyForSigning",
    "approval.required",
    "authorization.error"
  ],
  "deliverySecurity": {
    "signatureMode": "asymmetric",
    "encryptionMode": "payload"
  },
  "enabled": true
}
```

---

## 13. Authorization Error Event Example

```json
{
  "specVersion": "1.0",
  "eventType": "authorization.error",
  "eventId": "018f0d4a-8b2c-7cc2-a4b0-9f15c6f1db15",
  "occurredAt": "2026-04-07T16:05:00Z",
  "source": {
    "serviceId": "tea.publisher.example.com"
  },
  "actor": {
    "type": "system",
    "id": "ci-system"
  },
  "subject": {
    "type": "collection",
    "id": "col-123"
  },
  "auditEventId": "TEA-PUB-AUTHORIZATION-ERROR",
  "data": {
    "action": "collection.publish",
    "reason": "insufficient privileges",
    "requiredRole": "release-approver",
    "currentState": "signed"
  }
}
```

---

## 14. collection.readyForSigning Example

```json
{
  "specVersion": "1.0",
  "eventType": "collection.readyForSigning",
  "eventId": "018f0d4a-8b2c-7cc2-a4b0-9f15c6f1db14",
  "occurredAt": "2026-04-07T16:00:00Z",
  "source": {
    "serviceId": "tea.publisher.example.com"
  },
  "actor": {
    "type": "system",
    "id": "ci-system"
  },
  "subject": {
    "type": "collection",
    "id": "col-123"
  },
  "auditEventId": "TEA-PUB-COLLECTION-READY-FOR-SIGNING",
  "data": {
    "releaseId": "rel-456",
    "collectionVersion": 3,
    "signingPayloadUrl": "https://tea.publisher.example.com/collections/col-123/signing-payload"
  }
}
```

---

## 15. Conformance Levels

### Mandatory
- event envelope  
- event naming  
- audit binding  
- message signing  

---

### Recommended
- asymmetric signing  
- key publication endpoint  
- retry and idempotency  

---

### Optional
- payload encryption  
- message bus transport  

---

## 16. Normative Statement

> TEA publisher implementations SHOULD support a standardized event delivery mechanism. Events SHALL be transport-independent. Implementations MUST provide message-level integrity protection and sender authentication independently of TLS. Implementations MAY support payload encryption using a receiver-provided public key. HTTP webhooks are one transport binding; the model SHOULD support message buses and similar transports.

---

## 17. Summary

This model ensures:

- secure delivery independent of TLS  
- interoperability across implementations  
- extensibility for future transports  
- alignment with TEA trust architecture  
