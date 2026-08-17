# UNSTUCK iOS

SwiftUI application. **Phase 3A: first UI vertical slice** —
Launch → What's Going On? → Select Situation → Tell Us What's Happening → Initial Read,
wired to the backend through the Ranca boundary (no AI provider in the client).

## What is here

- `UnstuckApp.swift` / `ContentView.swift` — SwiftUI app shell hosting the flow.
- `Configuration/Environment.swift` — runtime environment with a safe local default; no production endpoints hardcoded, no secrets.
- `Networking/APIClient.swift` / `URLSessionAPIClient.swift` — protocol-based HTTP client (GET + POST) that talks **only** to the UNSTUCK backend. No AI provider credentials; never logs request bodies.
- `Analysis/RancaBoundary.swift` — the clean `RancaBoundary` protocol + `RancaRequest`/`AnalysisResult` contracts mirroring `packages/contracts`. The app depends on this abstraction, never on a concrete AI provider.
- `Analysis/AnalysisService.swift` — backend-facing analysis service calling `POST /analysis` via the API client; maps errors explicitly (no fabricated results).
- `Design/` — V1 design tokens (color/type/spacing/radius/motion) and shared components (`BottomAction`, `Progress`, `TextInput`). Exact numeric values are **OPEN** placeholders centralized here; screens consume tokens, never literals.
- `Flow/` — the vertical slice: `Situation` (locked situation set), `UnstuckFlowStep`, `UnstuckFlowViewModel`, `FlowContainerView`, and the four screens + `SituationPicker`. Honors Reduce Motion, Dynamic Type, VoiceOver, safe areas.
- `Result/` — result components in the LOCKED order: `ReadView` → `SignalsSection`/`SignalItem` → `WhySection` → `DoesNotMeanSection` → `NextMoveView` → `CuriosityHookView` (optional), with `ConfidenceIndicator` (labeled state, not a score).
- `UnstuckTests/` — Swift unit tests for the pure-Swift boundary, contracts, flow logic, and configuration.

## What is NOT here

- No onboarding, chat/screenshot upload (SHOW), auth, subscriptions, Wrapped, or sharing.
- No embedded Ranca / AI provider.
- No production credentials or Apple private keys.

## Building

The pure-Swift boundary (Configuration + Analysis + Flow logic + tests) is also
expressed as a Swift Package so it can be type-checked where Swift is available
(see `Package.swift` at the iOS root). SwiftUI View files live in the Xcode app target
only. The full app target requires Xcode and the iOS SDK:

1. Open `Unstuck.xcodeproj` in Xcode (create one from these sources if not present).
2. Select a simulator and run.

If `swift`/`xcodebuild` is unavailable (e.g. CI on Linux), the iOS build/test is
skipped and reported as such — it is never faked. Run the backend (`services/api`)
locally to exercise the full `POST /analysis` path from the app.
