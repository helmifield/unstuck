# UNSTUCK Architecture

## Approved stack

- Client: Swift + SwiftUI
- Backend: TypeScript + NestJS
- Database: PostgreSQL / Supabase PostgreSQL
- Auth: Supabase Auth + Sign in with Apple / Google / Email
- AI orchestration: Ranca
- Payments: StoreKit 2
- Mobile integrity: Apple App Attest
- Device secrets: Keychain / Secure Enclave where appropriate
- CI/CD: GitHub Actions
- Security baseline: OWASP MASVS / MASTG + OWASP SAMM

## High-level flow

```text
SwiftUI
  ↓ HTTPS
NestJS API
  ↓
Auth / Authorization
  ↓
Ranca
  ├─ language detection
  ├─ OCR / parsing
  ├─ signal extraction
  ├─ scoring
  ├─ LLM interpretation
  ├─ reviewer
  └─ output validation
  ↓
PostgreSQL / temporary encrypted storage
  ↓
Structured result
```

## Ranca

Ranca is the orchestration boundary between the product and AI providers. The client never contains private AI provider credentials. Models are replaceable; UNSTUCK's behavior contract, schemas, scoring, and safety rules are not.

## Data flow

Raw screenshots and raw conversations are temporary by default. Process only what is needed. Convert useful observations into structured signals. Delete raw material when no longer required unless the user explicitly chooses to save it.

## Authorization

All sensitive access is server-side. Client-controlled IDs, roles, and Pro flags are never trusted. PostgreSQL Row Level Security is used where applicable.

## Environments

`local` → `staging` → `production`

Each environment has separate credentials, databases, storage, and AI credentials.

## Development

AI coding agents operate in sandboxed development environments and do not receive production credentials or production user data. Changes go through pull requests and security CI before merge.
