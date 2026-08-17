# UNSTUCK — Visual QA Preview (dev-only)

A **browser-only visual QA tool** that reproduces the approved Phase 3A UNSTUCK UI for
review. It is **not** the product and **not** a web app — the native iOS implementation
remains the source of truth. There are no API calls, no secrets, no real user data, no AI
provider, no analytics, and no tracking. All data is deterministic mock data.

## Start (one command, from the repo root)

```bash
npm run visual-preview
```

Then open the printed URL (default <http://127.0.0.1:4173/>). Ctrl+C to stop.

The server is zero-dependency (Node 20+ built-ins) and serves only the files in this
folder. No manual multi-service startup is required.

## What it previews

The approved Phase 3A flow, screen for screen:

1. **Launch** — wordmark, editorial line, inline privacy note, single primary action.
2. **What's Going On?** — editorial framing.
3. **Select Situation** — the locked situation set (Talking stage, Dating,
   Situationship / HTS, Relationship, Breaking up, Someone from my past, Something else).
4. **Tell Us What's Happening** — free-form TELL input with constructive guidance.
5. **Analysis transition** — calm, honest loading (no fake progress bar / delay theatrics).
6. **THE READ** — result in the LOCKED order: THE READ → SIGNALS → WHY →
   WHAT THIS DOESN'T MEAN → NEXT MOVE → optional CURIOSITY HOOK.

## Navigation

- Click the primary action to move forward (Start → Continue → Continue → Get my read).
- Select a situation to enable Continue. Type at least ~12 characters to enable Get my read.
- On the result, **Start over** resets the flow; the optional **Curious** hook returns to TELL
  to gather more context (matches the iOS slice — no fake destination).
- A **development-only** floating panel (bottom-right, clearly marked "Dev only") lets you
  jump directly to any state, toggle **Reduce motion**, view the no-Tell (low-confidence)
  result, and view the failure state. This panel is never in the native app.

## What is mock

- All analysis output is deterministic and produced by `mock.js`, which mirrors the approved
  `MockRanca` (`services/api/src/mock-ranca.ts`) and the iOS `UnstuckFlowViewModel` WHY
  synthesis and curiosity-hook rule. Nothing is fetched over the network.

## How it maps to the native iOS implementation

| Preview | iOS source |
|---|---|
| Design tokens (CSS vars) | `apps/iOS/Unstuck/Design/{Color,Type,Spacing,Motion}Tokens.swift` |
| Screens & flow | `apps/iOS/Unstuck/Flow/*` |
| Situation set + titles | `Flow/Situation.swift` |
| Situation picker | `Flow/SituationPicker.swift` |
| Tell input + guidance thresholds | `Flow/TellScreen.swift`, `Flow/UnstuckFlowViewModel.swift` |
| Result hierarchy | `Result/{AnalysisResultView,ResultSections,SignalItem,ConfidenceIndicator}.swift` |
| Mock analysis, WHY, curiosity | `services/api/src/mock-ranca.ts`, `Flow/UnstuckFlowViewModel.swift` |

## Known differences

- **No real device/safe-area insets.** A 24px content inset approximates the iOS safe-area +
  content inset. On wide screens the preview centers in a 430px phone-width frame.
- **System serif fonts.** The iOS `.serif` design resolves to the platform serif; the preview
  uses a serif stack (`ui-serif, Georgia, …`). Glyph metrics may differ slightly.
- **Haptics** are not reproduced (non-essential; iOS only).
- **Dynamic Type** is approximated with `rem`; system text-size settings are not reflected.
- **Loading transition** uses a short, honest delay in the preview only to demonstrate the calm
  transition; the iOS `AnalysisProgress` does not fake timing.
- **Ambient motion** is shown on Launch only (very slow, gentle), matching the onboarding-only
  ambient allowance. It is suppressed under Reduce Motion.

See `docs/design/VISUAL_QA.md` for the full guide and `docs/design/VISUAL_QA_AUDIT.md` for the
verification audit.
