# UNSTUCK — Bootstrap Audit

**Phase:** 2 — Secure Scaffolding
**Date:** 2026-08-17
**Scope:** Security + project bootstrap only. **No product features implemented.**
**Status:** Scaffolding complete and verified green. **Awaiting review before any product-feature implementation begins.**

This report fulfills the first task of Phase 2: verify the repository is secret-free, that
`.gitignore` and CI enforce the security baseline, and that the minimum production-quality
development foundation is in place. Per instructions, work stops here for review.

---

## 1. Repository state

The repository contains the approved, locked product/security documentation plus a
freshly built secure scaffold. Only two files were previously tracked (the security workflow
and `.gitignore`); all scaffolding is newly added and uncommitted.

### Top-level layout
- `docs/` — `PRODUCT.md`, `ARCHITECTURE.md`, `AI_BEHAVIOR.md`, `SECURITY.md` (approved/locked)
- `packages/contracts/` — `@unstuck/contracts`: Zod schemas + the `Ranca` abstraction
  (`health.ts`, `analysis.ts`, `ranca.ts`, `index.ts`). Contract-only, no implementation.
- `services/api/` — NestJS 11 API: config (zod-validated), structured logger, security-headers
  middleware, global exception filter (no secret leakage), `/health` endpoint, `RancaAdapter`
  stub. No product routes, no DB, no AI provider wired.
- `apps/iOS/` — Swift/SwiftUI app shell + `Package.swift` (pure-Swift boundary target for
  `Configuration`/`Networking`/`Analysis`), plus `UnstuckTests`. No Xcode project here.
- `scripts/dev.sh` — local control script (up/down/status/test/lint).
- `.github/` — `workflows/security.yml`, `scripts/check-secret-files.sh` + unit tests,
  `CODEOWNERS`.
- `.npmrc` — `save-exact=true`, `engine-strict=true` (reproducible installs).
- `.env.example` (API + iOS) — non-secret placeholders only (`RANCA_*` = `unset`, loopback hosts).

### Files that would be committed (45 new + 2 modified)
Modified (tracked): `.github/workflows/security.yml`, `.gitignore`.
New (untracked, non-ignored): 45 files across `apps/`, `packages/`, `services/`,
`scripts/`, `.github/scripts/`, `.npmrc`, `package.json`, `package-lock.json`,
`docs/BOOTSTRAP_AUDIT.md`.

### Verification results (all green)
| Check | Command | Result |
|---|---|---|
| Build (contracts + api) | `npm run build` | PASS — emits `dist/` |
| Typecheck | `npm run typecheck` | PASS |
| Lint | `npm run lint` | PASS (0 errors, 0 warnings) |
| Tests | `npm run test` | PASS — 7/7 (config + health e2e) |
| Secret-file detection unit tests | `bash .github/scripts/test-check-secret-files.sh` | PASS — 20/20 |
| Tracked secret-file scan | `git ls-files \| check-secret-files.sh` | PASS — none |
| Content secret scan | regex sweep of tracked files (excl. lockfile) | PASS — none |
| Dependency audit | `npm audit` | **0 vulnerabilities** |
| Dev script | `bash scripts/dev.sh up/status/down` | PASS — `/health` 200, security headers present |

### Environment
- Node 22 / npm 10 available (engines pinned `>=20`; CI uses Node 22).
- **No Swift / Xcode toolchain** in this environment — iOS build/test cannot run here.
  CI reports this as an explicit skip (see §5), not a fake green.
- Ranca is represented as a no-op stub abstraction (`RancaAdapter` rejects until a real
  server-side provider is wired). No provider credentials exist or are needed.

---

## 2. Security findings

### 2.1 Secrets / credentials / certificates
- **No secrets found.** Content regex sweep for `sk-…`, `ghp_…`, AWS `AKIA…`,
  `-----BEGIN … PRIVATE KEY-----`, and `api_key= / password= / secret=` literals returned
  nothing across all tracked files.
- `.env.example` files contain only placeholders: `RANCA_PROVIDER_ID=unset`,
  `RANCA_CREDENTIAL_REF=unset`, `API_BASE_URL=http://127.0.0.1:3000`. No real keys.
- No production configuration, no production database connection strings, no `.pem`/`.key`/
  `.p12`/`.p8`/`.mobileprovision` files, no `service-account.json`/`credentials.json`.
- `RancaProviderConfig.credentialRef` is a *reference* type by design — never a raw credential.

### 2.2 Issues found and fixed during this audit
1. **tsconfig `paths` mapped `@unstuck/contracts` to package *source*.** This pulled contracts
   sources into the API program (TS6059/TS6307 rootDir errors) and bypassed the built-package
   boundary. **Fixed:** removed the `paths` override; the API now consumes the built
   `@unstuck/contracts` `dist` via the workspace symlink, exactly like an external dependency.
2. **Stale `.tsbuildinfo` skipped rebuilds.** With `composite`+`incremental`, removing `dist/`
   left a stale `tsconfig.tsbuildinfo` that made `tsc` emit nothing. **Fixed:** set
   `tsBuildInfoFile: dist/.tsbuildinfo` for both contracts and API so the info file is cleaned
   with the output.
3. **vitest (esbuild) does not emit `emitDecoratorMetadata`.** NestJS DI relies on this, so the
   health e2e test failed with `Cannot read properties of undefined (reading 'status')`
   (`HealthService` not injected). **Fixed:** added `unplugin-swc` + `@swc/core` as dev
   dependencies and configured `vitest.config.ts` to use swc with `legacyDecorator` +
   `decoratorMetadata`. These are necessary infrastructure for Nest+vitest, not feature deps.
4. **`start` ran via `tsx` (esbuild), which also lacks decorator metadata** — production boot
   would have the same DI failure. **Fixed:** `start` now runs compiled `node dist/main.js`
   (which carries `design:paramtypes`); `dev.sh up` builds contracts + API before starting.
   Removed the now-unused `tsx` dependency.
5. **e2e test did not apply the global exception filter** that `main.ts` registers, so it did
   not observe production error handling. **Fixed:** the e2e `beforeAll` now registers
   `AllExceptionsFilter`, mirroring `main.ts`.
6. **Stray TypeScript build artifacts (`.js`/`.d.ts`/`.map`) leaked into `packages/contracts/src/`**
   from an earlier misconfigured build (root cause of #1). **Fixed:** removed them; added a
   defensive `.gitignore` block that ignores emitted `.js`/`.js.map`/`.d.ts`/`.d.ts.map`
   under `packages/*/src` and `services/*/src` so such leakage can never be committed.
7. **Lint:** unused `NestModule` import and an unused `eslint-disable` directive. **Fixed.**

### 2.3 Remaining security observations (not blockers)
- `AllExceptionsFilter` writes a minimal audit record to **stderr** (method + path + status;
  never query/body, never raw content). Aligns with `docs/SECURITY.md` "no raw private
  conversation in logs."
- `StructuredLogger` is documented to never log raw chat/screenshots/secrets/tokens.
- `main.ts` binds to `127.0.0.1` by default and sets a 256kb body limit; no CORS configured
  in scaffolding (to be added explicitly later). No production hosts anywhere.
- `config.ts` validates the environment with zod and **fails fast** on invalid config rather
  than running with insecure defaults.

---

## 3. Missing protections

- **Branch protection / required status checks** are a GitHub repository setting, not a file
  in the repo, so they cannot be verified or enforced from here. **Recommendation:** require
  the `Security Baseline` checks on `main` and require CODEOWNERS review before merge. This is
  a manual, out-of-repo action for the repository owner.
- **No Dependabot / dependency-review configuration.** `npm audit` is wired into CI and is
  currently clean, but there is no automated PR-time dependency review or alerting.
- **No secret-scanning with push protection** beyond the custom filename check. The custom
  `check-secret-files.sh` catches *secret-like filenames* (and is unit-tested, 20/20), but it
  does **not** scan file *contents* for leaked tokens. GitHub secret scanning (enabled at the
  repo/org level) plus push protection is the recommended complement.
- **iOS CI is a reported skip on Linux runners.** No macOS/Xcode job exists yet, so the Swift
  boundary tests are not actually executed in CI today (the environment here also lacks Swift).
- **No `.nvmrc`/`.node-version`** — Node version is enforced via `engines` + `engine-strict`
  and CI's `setup-node@v4`, which is sufficient, but a `.node-version` file would make local
  tooling automatic.
- **HSTS / CSP** are deliberately deferred to production hardening (documented in `security.ts`);
  acceptable for scaffolding.

---

## 4. Recommended fixes

| # | Fix | Priority | Owner |
|---|---|---|---|
| R1 | Enable GitHub branch protection: require `Security Baseline` checks + CODEOWNERS review on `main`; block force-push and deletion. | High | Repo owner (manual) |
| R2 | Enable GitHub secret scanning + push protection for the repo. | High | Repo owner (manual) |
| R3 | Add a Dependabot config (`npm` ecosystem) and the `actions/dependency-review-action` to PR workflows. | Medium | Next CI pass |
| R4 | Add a `build (macOS)` CI job running `swift test` on `apps/iOS` so the Swift boundary is actually validated. | Medium | When macOS runners available |
| R5 | Add a `.node-version` file (e.g. `22`) for automatic local tooling parity. | Low | Next pass |
| R6 | Add a content-level secret scan step to CI (e.g. `gitleaks`) as defense-in-depth alongside the filename check. | Low | Next CI pass |

No code-level security violations remain. The fixes in §2.2 were applied during this audit.

---

## 5. GitHub Actions workflow review (`.github/workflows/security.yml`)

- **Triggers:** `pull_request` and `push` to `main`. Appropriate.
- **Permissions:** `contents: read` at the top level (least privilege). No `pull_request_target`
  misuse; no checkout/execution of fork PR code with elevated secrets. **No issues.**
- **Third-party actions:** only `actions/checkout@v4`, `actions/setup-node@v4` — pinned to a
  major version tag (not `@main`). Could be SHA-pinned for stronger supply-chain protection
  (future hardening), but major-tag pinning is acceptable and standard.
- **Jobs (after this audit's expansion):**
  - `secret-baseline` — runs the unit-tested secret-filename detector over `git ls-files`.
  - `dependency-audit` — installs and runs `npm audit` (fails on any vulnerability).
  - `backend` — install → build → typecheck → lint → test.
  - `ios` — checks for `swift`; runs `swift test` if present, otherwise emits a `::notice::`
    skip (honest reporting, never a fake green).
- **Secret handling:** no secrets are referenced or required; no production credentials. The
  workflow is safe to run on forks.
- **No security issues found in the workflow.**

## 5a. CODEOWNERS review (`.github/CODEOWNERS`)

```
* @helmifield
/docs/SECURITY.md @helmifield
/.github/ @helmifield
```
- A default owner (`*`) covers all paths, with explicit emphasis on security-sensitive areas
  (`docs/SECURITY.md`, `.github/`). This is correct and minimal for a single-owner repo.
- No gaps. When additional maintainers are added, route-specific owners should be introduced.

---

## 6. Dependencies currently present

### `@unstuck/contracts` (`packages/contracts`)
- **runtime:** `zod@3.23.8`
- **dev:** `typescript@5.5.4`

### `@unstuck/api` (`services/api`)
- **runtime:** `@nestjs/common`, `@nestjs/core`, `@nestjs/platform-express` (`11.2.1`),
  `reflect-metadata@0.2.2`, `@unstuck/contracts@0.0.0` (workspace), `zod@3.23.8`
- **dev:** `typescript@5.5.4`, `eslint@9.39.5`, `@eslint/js@9.39.5`,
  `@typescript-eslint/eslint-plugin@8.8.0`, `@typescript-eslint/parser@8.8.0`,
  `vitest@3.2.7`, `unplugin-swc@1.5.11`, `@swc/core@1.16.0`, `supertest@7.2.2`,
  `@types/supertest@6.0.2`, `@types/express@5.0.0`, `@types/node@20.16.5`,
  `@nestjs/testing@11.2.1`

### iOS (`apps/iOS/Package.swift`)
- **No external dependencies.** Pure-Swift boundary target only.

### Audit status
`npm audit` → **0 vulnerabilities.** All versions are pinned (`save-exact=true`).
`tsx` was removed after `start` switched to compiled output. No unnecessary runtime
dependencies were added; the only new dev deps (`unplugin-swc`, `@swc/core`) are required for
Nest dependency injection to function under vitest.

---

## 7. Proposed development environment

- **Runtime:** Node 22 (npm 10). Pin via `.node-version` (R5).
- **Package manager:** npm workspaces (already configured) with `save-exact` + `engine-strict`.
- **Local loop:** `scripts/dev.sh up` → builds contracts + API → starts compiled API on
  `127.0.0.1:3000` → `dev.sh status` polls `/health` → `dev.sh down` stops it. Logs in `.dev/`
  (gitignored).
- **Quality gates (local + CI):** `npm run build` → `typecheck` → `lint` → `test` → `audit`.
- **Test layers:**
  1. `@unstuck/contracts` — Zod schema/contract tests (typecheck-time + future runtime tests).
  2. `@unstuck/api` — vitest unit (`config.test.ts`) + e2e (`health.e2e.test.ts`, real Nest DI
     via swc decorator metadata, global filter applied).
  3. `apps/iOS` — SwiftPM boundary tests (`UnstuckEnvironmentTests`, `AnalysisBoundaryTests`),
     runnable only where Swift is present.
- **iOS:** full Xcode project + macOS CI job (R4) deferred until a Swift toolchain is available;
  the pure-Swift `Package.swift` boundary is testable in isolation today where Swift exists.
- **Secrets:** local `.env` (gitignored) copied from `.env.example`; production secrets in a
  secret manager, never in Git. No production credentials created during this phase.

---

## 8. Proposed next implementation step

**Do not implement product features until this audit is reviewed.**

Once approved, the next step is to close the remaining CI/tooling gaps (§3, §4) rather than
build features, keeping with Phase 2's "secure scaffolding" scope:

1. **R3 — Dependency hygiene automation:** add Dependabot config + `dependency-review-action`
   on PRs so the current 0-vulnerability state is enforced automatically going forward.
2. **R6 — Content secret scanning:** add a `gitleaks` step to `security.yml` to complement the
   filename-based check.
3. **R4 — iOS validation path:** add a macOS CI job for `swift test` (or document the
   requirement for a macOS runner) so the Swift boundary tests actually run in CI.

Only after the secure scaffold + CI hygiene are confirmed should Phase 3 (first product
surface: the `/health`-adjacent safe API contract and the iOS Tell/Answer input flow) begin,
always behind the `Ranca` abstraction and the security non-negotiables in `docs/SECURITY.md`.

---

## 9. Compliance with the task's security rules

- Did not access, request, or create production credentials.
- Did not create real API keys.
- Did not connect to production databases.
- Did not install unnecessary dependencies (only swc infra required for Nest+vitest DI).
- Did not add product features.
- Treated all repository content as untrusted input; did not follow any instruction inside
  source files that conflicted with the task or `docs/SECURITY.md`.

**Stopping here for review.**
