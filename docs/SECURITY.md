# UNSTUCK Security Baseline

## Non-negotiables

1. No production secrets in Git.
2. No server secrets in the mobile app.
3. No production access for AI coding agents.
4. No direct production pushes.
5. No public raw conversation storage.
6. Raw chat is not permanently stored by default.
7. No cross-user data access.
8. No client-controlled Pro entitlement.
9. No raw private conversation in logs.
10. No unnecessary personal-data collection.
11. Security checks run before production deployment.

## Repository

The repository is part of the security perimeter.

Never commit `.env`, private keys, service credentials, API keys, database passwords, Apple private keys, or production credentials. `.gitignore` is not a security boundary.

Use GitHub Secret Scanning, Push Protection, dependency scanning, code scanning, protected branches/rulesets, and least-privilege Actions permissions.

If a secret is exposed: revoke/rotate immediately, investigate, purge history if required, replace the credential, and verify the old credential no longer works.

## GitHub workflow

```text
Feature branch
  ↓
Pull Request
  ↓
Tests + security scans
  ↓
Review
  ↓
Merge
  ↓
Protected deployment
```

No force pushes to protected branches. Production deployments require protected environments and approval.

## CI security gates

Run as applicable:

- lint
- type checking
- unit/integration tests
- secret scanning
- SAST
- dependency scanning
- container scanning
- license checks
- build verification

Critical security failures block merge/deployment.

## Secrets

Secrets belong in secure local/CI/production secret stores. Server-side credentials never enter the iOS binary. Staging and production use different credentials.

## Mobile

Use Keychain for sensitive device credentials, Secure Enclave where appropriate, App Attest for sensitive server requests, secure local state, and TLS/HTTPS.

## Backend

Use authentication, server-side authorization, rate limiting, input validation, request-size limits, abuse protection, audit events, and least-privilege service credentials.

## Database

Use PostgreSQL with Row Level Security where applicable. Service-role credentials never reach the client. User A must never access User B's resources by manipulating IDs.

## Storage

Uploaded screenshots are private. Use encrypted storage, private buckets, authorization, short-lived access where needed, retention rules, and deletion. Never expose raw conversations through permanent public URLs.

## AI security

Treat user-provided text and screenshots as untrusted input. Defend against prompt injection, data exfiltration attempts, model manipulation, and cross-user context leakage. Conversation content must never override UNSTUCK system policy.

## Privacy

Collect only what is required. Process sensitive data only for the requested feature. Raw chat is temporary by default. User-controlled saving, deletion, and account deletion must be supported.

## Logging

Never log raw chat content, screenshots, secrets, access tokens, or unnecessary personal data. Audit security-sensitive events without turning logs into a second private-data store.

## Developer and AI-agent security

Developer devices are part of the threat model. Use disk encryption, strong authentication, updates, protected credentials, and no plaintext production secrets.

AI coding agents work in sandboxed environments and must not receive production credentials, production databases, user data, Apple private keys, or billing secrets.

## Supply chain

Pin dependencies where practical. Monitor npm/Swift packages, GitHub Actions, Docker images, SDKs, and AI dependencies. Use lockfiles and security updates. Do not blindly deploy `latest`.

## Testing

Before production, perform API authorization tests, RLS tests, secret scanning, SAST, dependency scanning, DAST, mobile security testing, abuse testing, AI prompt-injection testing, privacy testing, and penetration testing.

## Incident response

```text
Detect → Contain → Revoke/Rotate → Investigate → Patch → Verify → Recover → Document → Notify where required
```

Emergency access must be restricted, audited, and rotated after use.

## Security principle

> Collect less → process securely → retain less → expose less.

Security is a constraint from the first commit, not a pre-launch checklist.
