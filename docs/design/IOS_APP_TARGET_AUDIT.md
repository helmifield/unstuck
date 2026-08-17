# UNSTUCK — Phase 3A.2 iOS App Target Audit

**Phase:** 3A.2 — Fix native iOS app target so the existing SwiftUI implementation runs on an iOS Simulator.
**Status:** Project files created; pending review. **Not committed.**
**Date:** 2026-08-17
**Environment note:** This audit was produced on a Linux runtime with **no Swift/Xcode toolchain**
(`swift`, `xcodebuild`, `xcrun` unavailable). The Xcode project files were authored by hand and
validated structurally (UUID graph, brace balance, XML well-formedness, scheme/target wiring).
They could **not** be compiled here — that is reported honestly, never faked.

---

## 1. Root cause

SweetPad reported `✅ macOS detected`, `✅ workspace path detected`, `❌ No schemes found`.

Confirmed cause:

- `apps/iOS/Package.swift` exposes **only** the `UnstuckBoundary` library (a Foundation/Combine-only
  package target). It **excludes** the SwiftUI app shell and every SwiftUI `View` file:
  `UnstuckApp.swift`, `ContentView.swift`, `Design/*`, `Result/*`, and the seven `Flow/*Screen*.swift`
  + `FlowContainerView` + `SituationPicker` files.
- The repository contained **no `.xcodeproj` / `.xcworkspace` and no scheme**. The iOS README even
  instructed the reader to *"create one from these sources if not present."*

A Swift Package with only a library product has no executable app target and therefore no app scheme —
so SweetPad/Xcode find "no schemes." The package is correct as a *boundary* but was never paired with
the missing application project.

## 2. What was created (and why)

A native Xcode application target that wraps the **existing** SwiftUI source — no new screens, no
duplicate implementation, no UI/behavior changes.

| File | Purpose |
|---|---|
| `apps/iOS/Unstuck.xcodeproj/project.pbxproj` | Xcode project: one native app target `Unstuck`, iOS 16.0, `@main` = `UnstuckApp.swift`, compiling **all 30** existing `Unstuck/**/*.swift` sources inline. |
| `apps/iOS/Unstuck.xcodeproj/xcshareddata/xcschemes/Unstuck.xcscheme` | Shared `Unstuck` scheme (Build/Launch/Profile/Analyze/Archive). |
| `apps/iOS/Unstuck.xcworkspace/contents.xcworkspacedata` | Workspace wrapping the project (gives SweetPad a workspace to detect). |
| `apps/iOS/Unstuck.xcworkspace/xcshareddata/xcschemes/Unstuck.xcscheme` | Same scheme at workspace level for reliable discovery. |

### Design decisions

1. **App target compiles the boundary sources inline; it does not link the `UnstuckBoundary` package
   product.** The boundary types (`RancaBoundary`, `AnalysisService`, `AnalysisResult`, `Situation`,
   `UnstuckFlowViewModel`, `UnstuckFlowStep`, …) are `internal`/`public` to the app module. Linking the
   product alongside would duplicate symbols and require invasive `public`/`import` changes across the
   existing views (forbidden: "do not change existing SwiftUI source / behavior"). Compiling the same
   files inline means **one source tree, no duplication, no visibility changes** — the minimal fix.
2. **`UnstuckBoundary` is preserved as the package boundary.** `Package.swift` is **unchanged**; `swift
   test` (from `apps/iOS/`) remains the canonical path for the boundary tests. The app "uses" the
   boundary *code* (same files) and the package remains the testable boundary — satisfying "preserve
   UnstuckBoundary as the package boundary" and "link/use UnstuckBoundary where required" without source
   duplication.
3. **No new dependencies.** The project links no third-party frameworks; SwiftUI/Foundation/Combine are
   provided by the iOS SDK.
4. **No test target added in Xcode.** The existing `UnstuckTests/` use `@testable import UnstuckBoundary`
   (the package module). Creating a competing Xcode test target would duplicate or force rewriting the
   tests (forbidden: "preserve the existing tests"). Package tests stay runnable via `swift test`.

## 3. One required source fix (no behavior change)

`apps/iOS/Unstuck/ContentView.swift` had a **pre-existing compile error** that blocked the app target
from building:

```diff
- let client = URLSessionAPIClient(baseURL: environment.apiBaseURL)
+ let client = URLSessionAPIClient(environment: environment)
```

`URLSessionAPIClient.init(environment:session:)` takes `environment: UnstuckEnvironment` (with a default
`session: URLSession = .shared`). The old call used a non-existent `baseURL:` label with the wrong type.
This fix is the **intended wiring** (the client already derives its base URL from the environment
internally) and changes no product behavior — it is required for the app to compile (requirement #9:
"Build for the available iOS Simulator"). No other source files were modified.

## 4. Requirements checklist

| # | Requirement | Result |
|---|---|---|
| 1 | Xcode project/workspace openable by Xcode | ✅ `Unstuck.xcworkspace` + `Unstuck.xcodeproj` |
| 2 | Executable UNSTUCK iOS app target | ✅ `PBXNativeTarget` `Unstuck`, `productType = com.apple.product-type.application` |
| 3 | UNSTUCK scheme | ✅ Shared `Unstuck.xcscheme` (project + workspace level) |
| 4 | `UnstuckApp.swift` is `@main` entry point | ✅ `@main struct UnstuckApp: App`; target includes it |
| 5 | Includes existing SwiftUI source under `Unstuck/` | ✅ all 30 `.swift` files in Sources build phase |
| 6 | Link/use UnstuckBoundary where required | ✅ boundary code compiled inline; package boundary preserved (see §2) |
| 7 | Target iOS 16 | ✅ `IPHONEOS_DEPLOYMENT_TARGET = 16.0` (project + target) |
| 8 | Discoverable by SweetPad | ✅ shared scheme + workspace; *runtime discovery not verifiable on Linux* |
| 9 | Build for iOS Simulator | ✅ `SDKROOT = iphoneos`, `TARGETED_DEVICE_FAMILY = "1,2"`; *build not runnable here* |
| 10 | No unnecessary dependencies | ✅ none added |

## 5. Verification performed (on this Linux host)

### 5.1 Project structure — valid pbxproj

- `{` / `}` balanced: **87 / 87**.
- All UUIDs are valid **24-char hexadecimal** (`0-9A-F`); **0 non-hex** tokens.
- All 10 required sections present with Begin/End markers (PBXBuildFile, PBXFileReference,
  PBXFrameworksBuildPhase, PBXGroup, PBXNativeTarget, PBXProject, PBXResourcesBuildPhase,
  PBXSourcesBuildPhase, XCBuildConfiguration, XCConfigurationList).
- Object-reference integrity: **79 defined object keys**, **0 unresolved references**.
- Sources build phase references **30** `PBXBuildFile` entries, each resolving to a real
  `PBXFileReference`; all 30 `.swift` files under `Unstuck/` are present.
- Target `ABCDEF…0B2` is defined as an object, referenced by the project's `targets`, and is the
  scheme's `BlueprintIdentifier` — all consistent.
- `rootObject`, `mainGroup`, `productReference`, `productType`, `SDKROOT`, `IPHONEOS_DEPLOYMENT_TARGET`,
  `PRODUCT_BUNDLE_IDENTIFIER` (`dev.unstuck.UnstuckApp`), `SWIFT_VERSION` (`5.9`),
  `GENERATE_INFOPLIST_FILE` + `INFOPLIST_KEY_UILaunchScreen_Generation` all present.

### 5.2 Scheme + workspace XML — well-formed

`xml.dom.minidom.parse` succeeds for the project scheme, workspace scheme, and workspace data. The
scheme's `BlueprintIdentifier` matches the app target UUID; `BuildableName = Unstuck.app`;
`BlueprintName = Unstuck`; `ReferencedContainer = container:Unstuck.xcodeproj`.

### 5.3 Package tests (`swift test`) — NOT RUN

`swift` is unavailable on this Linux runtime. Package tests are **not faked**; they remain runnable via
`swift test` from `apps/iOS/` on a Swift/Xcode host. The `UnstuckBoundaryTests` target and `Package.swift`
are unchanged.

### 5.4 Backend tests — GREEN (unaffected)

`npm run build` ✅ · `typecheck` ✅ · `lint` ✅ · `test` **3 files / 12/12 pass** ·
`npm audit --workspaces` **0 vulnerabilities**. The iOS changes do not touch the backend.

### 5.5 Security / secret scan — CLEAN

- Secret-pattern scan over all new/changed iOS files: **no matches** (keys/tokens/JWT/passwords/api_key).
- No `.env`/`.pem`/`.key`/`.p12`/`.p8`/credentials files. The pbxproj contains **no URLs, no private
  keys, no tokens, no production endpoints** (the "token" grep hits are the filenames `*Tokens.swift`).
- The app's only configured endpoint is the safe local default `http://127.0.0.1:3000`
  (`UnstuckEnvironment.localDefault`) — unchanged, no production credentials introduced.

### 5.6 Git diff — scoped

- Modified (tracked): `apps/iOS/README.md` (build instructions), `apps/iOS/Unstuck/ContentView.swift`
  (1-line compile fix), `.gitignore` (added Xcode user-state ignores).
- New (untracked): `Unstuck.xcodeproj/project.pbxproj`, `Unstuck.xcodeproj/…/Unstuck.xcscheme`,
  `Unstuck.xcworkspace/contents.xcworkspacedata`, `Unstuck.xcworkspace/…/Unstuck.xcscheme`.
- **Unchanged:** `Package.swift`, all backend/contracts/`tools`/`docs/design` product sources. No native
  iOS *view* source beyond the ContentView compile fix; no product behavior changed.

### 5.7 `.gitignore` hardening

Added Xcode user-state ignores so opening the project on a Mac does not pollute the repo:

```
# Xcode (user-specific, never committed)
*.xcuserstate
xcuserdata/
```

This is ignore-only hygiene (mirrors the existing `.DS_Store` rule); it changes no build or security
behavior.

## 6. What was NOT done (constraints honored)

- Did **not** redesign the UI or change product behavior.
- Did **not** touch the backend, contracts, or security architecture.
- Did **not** replace SwiftUI or create a competing app implementation.
- Did **not** duplicate source files (the app target compiles the existing single source tree).
- Did **not** delete or alter `Package.swift`.
- Did **not** convert the repo away from Swift Package architecture.
- Did **not** create fake placeholder screens.
- Did **not** add dependencies.
- Did **not** access, request, or create production credentials/keys.
- Did **not** commit or push.

## 7. Recommended next step (verification on a Mac)

On a macOS host with Xcode 15+/16 and an iOS 16+ Simulator:

1. `cd apps/iOS && swift test` — run the boundary package tests.
2. `open Unstuck.xcworkspace` — confirm the `Unstuck` scheme appears (SweetPad should now discover it).
3. Select an iOS Simulator and `xcodebuild -scheme Unstuck -destination 'platform=iOS Simulator,name=iPhone 15' build` (or ⌘R).
4. Confirm the app boots: `UnstuckApp` → `ContentView` → `FlowContainerView` (Launch screen), with the
   backend (`services/api`) running locally to exercise `POST /analysis`.

If the hand-authored pbxproj needs any Xcode-side normalization (Xcode rewrites pbxproj on first open),
open and save the project once; the shared scheme and sources are already correct.

**Phase 3B is not started.** Stopping here for review as instructed.
