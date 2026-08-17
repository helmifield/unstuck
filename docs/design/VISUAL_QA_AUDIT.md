# UNSTUCK — Phase 3A.1 Visual QA Preview Audit

**Phase:** 3A.1 — Visual QA preview for the approved Phase 3A UI.
**Tool:** `tools/visual-preview/` (browser-only, dev-only, mock-only).
**Status:** Preview complete and verified; pending review. No product feature added.
**Date:** 2026-08-17

This audit records what was built, how it was verified, and how it stays isolated from the
product. It complements `docs/design/VISUAL_QA.md` (the guide).

---

## 1. Scope and constraints honored

- **Visual QA tool only.** Reproduces the approved Phase 3A iOS UI in the browser for review.
  It is **not** a web app and does **not** replace or modify the native iOS architecture.
- **No product feature was implemented.** No native iOS, backend (`services/api`), or
  contracts (`packages/contracts`) files were modified.
- **No new production dependencies.** The preview uses only browser APIs and Node 20+
  built-ins (`http`, `fs`, `path`). `package.json` changed only to add two `npm run` scripts.
- **No fake mechanics.** No bouncing, parallax excess, fake loading delays (the transition is
  a brief honest calm transition), fake scarcity, fake scores, or manipulative engagement.

## 2. What was created

```
tools/visual-preview/
  index.html      # the six screens + dev-only panel (no build step)
  styles.css      # design tokens transcribed from iOS Design/* as CSS variables
  app.js          # flow controller mirroring UnstuckFlowViewModel state machine
  mock.js         # deterministic mock mirroring MockRanca + WHY/curiosity synthesis
  server.js       # zero-dependency Node static server (serves only 4 files)
  test.js         # zero-dependency smoke test (no DOM)
  README.md       # tool readme
docs/design/VISUAL_QA.md       # guide (start, screens, navigation, mapping, known diffs)
package.json                   # +visual-preview, +visual-preview:test scripts
```

## 3. Verification performed

### 3.1 Preview starts successfully

- `npm run visual-preview` boots the server; prints the URL; serves `index.html`,
  `styles.css`, `app.js`, `mock.js` with HTTP 200 and correct content types.
- Security headers present: `cache-control: no-store`, `x-content-type-options: nosniff`,
  `x-frame-options: DENY`, `referrer-policy: no-referrer`.
- Path traversal (`/../package.json`) and unknown files (`/secret.env`) → 404.

### 3.2 All six states render (verified via browser)

| State | Verification |
|---|---|
| Launch | Rendered; "Start" primary action; privacy note; ambient mark. |
| What's Going On? | Rendered; "Continue"; step progress shown (1 filled/wide). |
| Select Situation | All 7 locked options rendered with exact titles. |
| Tell | Textarea with iOS placeholder; constructive guidance gating works. |
| Analysis transition | Calm breathing indicator + "Reading the situation…". |
| THE READ (with Tell) | Medium-confidence read; sections in LOCKED order; no curiosity hook. |
| THE READ (no Tell) | Low-confidence read; optional CURIOSITY HOOK rendered. |
| Failed state | Honest "We couldn't get a read." + "Try again". |

### 3.3 Flow navigation works (end-to-end, via browser)

Click-through verified: Launch → Start → What's Going On? → Continue → Select Situation →
tap option (enables Continue) → Continue → Tell → type ≥12 chars (enables "Get my read") →
Get my read → Analysis transition → THE READ → Start over → Launch.

### 3.4 Situation selection works

Tapping an option marks it selected (visible accent bar + "Selected" label + surface fill)
and enables Continue. Re-selecting updates the selection. Matches `SituationPicker.swift`.

### 3.5 Tell input works

Free-form textarea; <12 chars shows constructive guidance and disables "Get my read"; ≥12
chars enables it. Mirrors `UnstuckFlowViewModel` canContinueFromTell / tellGuidance.

### 3.6 Result renders (LOCKED order)

With-Tell result renders: THE READ → Overall read + confidence → SIGNALS (Interest, Clarity)
→ WHY → WHAT THIS DOESN'T MEAN (2 items) → NEXT MOVE → (no hook, medium confidence).
No-Tell result renders the same hierarchy and surfaces the optional CURIOSITY HOOK.
Confidence is a labeled state (dot + text), never a numeric score, never color-only.

### 3.7 Reduced-motion behavior

- `prefers-reduced-motion: reduce` media query maps all motion tokens to ~0.01s linear
  (mirrors `UnstuckMotion.reduced`).
- Dev toggle applies `body.force-reduced-motion` which re-applies the same near-instant
  tokens and stops ambient/progress/reveal animations.
- Verified CSS rules present (5 occurrences) and toggle wired in app.js.

### 3.8 Smoke test (deterministic, no DOM)

`npm run visual-preview:test` — 19 checks, all pass:
- Mock contract shape (overall confidence, 2 signals, doesNotMean, nextMove, never echoes user
  text, WHY synthesis, curiosity-hook rule, determinism).
- Gating logic mirrors the iOS view-model (empty/whitespace/short/<12 cannot continue; ≥12 can).
- Locked situation set + titles exact.

### 3.9 Backend unaffected (still green)

| Check | Result |
|---|---|
| `npm run build` | OK |
| `npm run typecheck` | OK |
| `npm run lint` | OK |
| `npm run test` | 3 files, **12/12 pass** |
| `npm audit --workspaces` | **0 vulnerabilities** |

The preview is outside workspaces, so backend build/lint/test do not touch it and vice-versa.

## 4. Security review

- **No secrets / API keys / tokens / credentials / private certs** in any new file
  (pattern scan clean; no secret-like filenames).
- **No production API calls.** The server makes no outbound network calls; the client fetches
  nothing (mock data only). No external HTTP URLs in preview code.
- **No real user data; no AI provider; no analytics; no tracking.**
- Server is scoped: an allowlist of 4 filenames; everything else 404s; path traversal blocked
  via `path.resolve` + prefix check.
- No `.env` files read; the preview does not import any workspace package or read repo secrets.

## 5. Design faithfulness

- Tokens transcribed **verbatim** from the iOS implementation (RGB→hex for colors; exact
  spacing/radius; serif system hierarchy → serif stack + rem; motion timings identical).
  There is **one** design system; no second conflicting system was invented.
- OPEN values remain OPEN per `docs/design/DESIGN_DECISIONS.md`; the centralized iOS
  placeholder values are reused, not re-decided.
- Result hierarchy, confidence-as-labeled-state, one primary action per screen, constructive
  TELL guidance, calm loading, honest failure, curiosity hook only when low — all match the
  locked docs (`UI_UX.md`, `USER_FLOWS.md`, `DESIGN_SYSTEM_V1.md`) and the iOS slice.

## 6. Known differences

Documented in `docs/design/VISUAL_QA.md` §8: safe-area insets approximated; system serif
font stack vs iOS `.serif`; no haptics; Dynamic Type approximated via `rem`; short honest
loading transition in preview only; ambient motion on Launch only.

## 7. Isolation from the product

- Lives under `tools/`, **not** a workspace; not imported by `services/api`, `packages/*`, or
  the iOS package.
- Adds **no dependencies**; `node_modules` is untouched.
- Does not alter `docs/design/UI_UX.md`, `DESIGN_SYSTEM*.md`, `USER_FLOWS.md`, or
  `DESIGN_DECISIONS.md` — those remain the source of truth.
- The dev-only control panel is present only in `tools/visual-preview/index.html`; it is not
  referenced by any native or production code.

## 8. Recommended next step

Review this audit and the preview (`npm run visual-preview`). If approved, the next
increment remains a product decision (e.g., wiring the selected `Situation` into the request,
or the SHOW optional-attach step) — all behind the existing Ranca boundary and validated at
the API. **Phase 3B is not started.**

## 9. Files changed

- `package.json` — added `visual-preview` and `visual-preview:test` scripts (2 lines).
- `docs/design/VISUAL_QA.md` — new guide.
- `docs/design/VISUAL_QA_AUDIT.md` — this file.
- `tools/visual-preview/` — `index.html`, `styles.css`, `app.js`, `mock.js`, `server.js`,
  `test.js`, `README.md` (7 files).

No other files were modified.
