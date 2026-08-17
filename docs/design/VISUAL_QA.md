# UNSTUCK — Visual QA Preview Guide

**Phase:** 3A.1 — Visual QA preview for the approved Phase 3A UI.
**Status:** Preview tool complete; pending review. This is a **dev-only** tool.

This document explains the isolated browser preview that reproduces the approved Phase 3A
UNSTUCK UI for visual QA. It is **not** the product and **not** a web app — the native iOS
implementation remains the single source of truth. No product feature was added; no native
behavior was changed.

---

## 1. What it is

A self-contained, zero-dependency, browser-based preview of the six approved Phase 3A
screens, served by a tiny zero-dependency Node static server. It runs entirely on
deterministic mock data — **no API calls, no secrets, no real user data, no AI provider, no
analytics, no tracking**. It lives under `tools/visual-preview/`, outside the npm workspaces
and outside the iOS package, so it cannot affect the product build or tests.

## 2. How to start (one command)

From the repository root:

```bash
npm run visual-preview
```

Then open the printed URL (default <http://127.0.0.1:4173/>). Press Ctrl+C to stop. No
manual multi-service startup is required. (Optional port: `node tools/visual-preview/server.js 5173`.)

A self-contained smoke test (no DOM required) verifies the mock contract and gating logic:

```bash
npm run visual-preview:test
```

## 3. Supported screens

| # | Screen | What it reproduces |
|---|---|---|
| 1 | **Launch** | Wordmark, editorial line, inline privacy note, single primary action. |
| 2 | **What's Going On?** | Editorial framing question. |
| 3 | **Select Situation** | The locked situation set (7 options) with calm selection. |
| 4 | **Tell Us What's Happening** | Free-form TELL input with constructive guidance. |
| 5 | **Analysis transition** | Calm, honest loading (no fake progress bar). |
| 6 | **THE READ** | Result in the LOCKED order (see §6). |

## 4. How to navigate

- **Forward (primary action):** Start → Continue → Continue → Get my read.
- **Select Situation:** tap an option to enable Continue.
- **Tell:** type at least ~12 characters to enable Get my read. Below that, a constructive
  helper appears (never a hard block).
- **Result:** **Start over** resets the flow. The optional **Curious** hook (only shown for
  the low-confidence read) returns to TELL to gather more context — matching the iOS slice
  (no fake deeper destination is invented).
- **Back:** navigation is forward-primary in this slice; the dev panel can jump to any state.
- **Keyboard:** Esc on the result resets to Launch.

### Development-only preview controls

A floating panel (bottom-right) is clearly marked **"Dev only"** and visually separated from
the product UI. It lets a reviewer:

- Jump to any of the six states directly.
- View the **no-Tell** (low-confidence) result — which is the only variant that surfaces the
  optional **CURIOSITY HOOK**.
- View the **failed** state (honest, recoverable; never fabricated results).
- Toggle **Reduce motion** to verify the reduced-motion behavior.
- **Reset flow.**

This panel exists only in the preview and is **never** included in the native app.

## 5. What is mock

All analysis output is produced by `tools/visual-preview/mock.js`, which mirrors the approved
`MockRanca` (`services/api/src/mock-ranca.ts`) and the iOS `UnstuckFlowViewModel` WHY
synthesis and curiosity-hook rule. The mock:

- is deterministic (same input → identical output);
- never echoes the user's free-form text;
- never invents evidence;
- lowers confidence when evidence is short (no Tell → low);
- gives exactly one practical next move;
- surfaces a curiosity hook only when overall confidence is low.

There is no network and no AI provider. Nothing is stored or transmitted.

## 6. How it maps to the native iOS implementation

| Preview | iOS source |
|---|---|
| Design tokens (CSS variables) | `apps/iOS/Unstuck/Design/{Color,Type,Spacing,Motion}Tokens.swift` |
| Screens & flow | `apps/iOS/Unstuck/Flow/*` |
| Situation set + titles | `Flow/Situation.swift` |
| Situation picker / option | `Flow/SituationPicker.swift` |
| Tell input + guidance thresholds | `Flow/TellScreen.swift`, `Flow/UnstuckFlowViewModel.swift` |
| Step progress | `Design/Progress.swift` (`StepProgress`) |
| Analysis loading | `Design/Progress.swift` (`AnalysisProgress`) |
| Bottom action | `Design/BottomAction.swift` |
| Result hierarchy | `Result/{AnalysisResultView,ResultSections,SignalItem,ConfidenceIndicator}.swift` |
| Mock analysis, WHY, curiosity | `services/api/src/mock-ranca.ts`, `Flow/UnstuckFlowViewModel.swift` |

### Result hierarchy (LOCKED order, rendered identically)

```
THE READ → overall read + confidence → SIGNALS → WHY → WHAT THIS DOESN'T MEAN → NEXT MOVE → CURIOSITY HOOK (optional)
```

Confidence is shown as a **labeled state** (dot + text), never a numeric score, and never by
color alone — exactly as in `ConfidenceIndicator.swift`.

## 7. Motion

The preview demonstrates the approved motion direction, all subtle and premium, and all
honoring **Reduce Motion** (both the OS preference via `prefers-reduced-motion` and the dev
toggle):

- **Ambient movement** — a very slow, gentle drift of a minimal mark on Launch only
  (onboarding-only allowance; `MotionTokens.ambient` 3.2s).
- **Subtle reveal** — entering views/sections fade + rise (`MotionTokens.reveal` 0.32s).
- **Responsive interactions** — situation selection, button presses (`MotionTokens.select`
  0.18s).
- **Smooth transitions** — between flow steps (`MotionTokens.transition` 0.28s).
- **Progress movement** — the honest, breathing analysis indicator
  (`MotionTokens.progress` 0.9s, alternate).
- **State changes** — calm opacity transitions on guidance, selected state, result sections.

Motion timings are transcribed verbatim from `MotionTokens.swift`; the reduce-motion path
maps every animation to a near-instant linear duration (0.01s), mirroring
`UnstuckMotion.reduced`.

### Motion it does NOT do (per the design contract)

No bouncing UI, no excessive parallax, no fake loading delays (the analysis transition is a
brief, honest calm transition — not a fake progress bar implying timing certainty), no fake
scarcity, no fake scores, and no manipulative engagement mechanics.

## 8. Known differences from native

- **Safe areas / device insets** are approximated with a 24px content inset; the preview
  centers in a 430px phone-width frame on wide screens.
- **System serif fonts** resolve to a serif stack (`ui-serif, Georgia, …`); glyph metrics may
  differ slightly from the iOS `.serif` design.
- **Haptics** are not reproduced (non-essential; iOS only).
- **Dynamic Type** is approximated with `rem`; the device's text-size setting is not reflected.
- **Loading transition** uses a short, honest delay in the preview only to demonstrate the
  calm transition; the iOS `AnalysisProgress` does not fake timing.
- **Ambient motion** is shown on Launch only and is suppressed under Reduce Motion.
- The preview is a flat-file tool (HTML/CSS/JS); it does not compile or run any Swift.

## 9. Security

- No production API calls; the server serves only the four preview files and 404s everything
  else (no path traversal).
- No secrets, credentials, or `.env` files are read or bundled.
- No real user data; mock data contains no real personal information.
- No external AI provider; no analytics; no tracking.
- Response headers: `no-store`, `nosniff`, `DENY` (frame), `no-referrer`.

## 10. Out of scope

This tool does not implement any product feature. It does not touch the native iOS code, the
backend, the contracts package, or any test. Phase 3B is not started. Per `docs/design/UI_UX.md`
§22, authentication, payments, Wrapped, and sharing are not present.

See `docs/design/VISUAL_QA_AUDIT.md` for the verification audit.
