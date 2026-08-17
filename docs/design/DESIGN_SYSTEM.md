# UNSTUCK Design System

**Status:** Source of truth for visual tokens and component conventions.
**Version:** V1 — locked decisions (Phase 2.6). Exact numeric values remain **OPEN** until
product-owner approval; see `DESIGN_DECISIONS.md`.
**Phase:** 2.6 — Lock Design System V1. **No screens are implemented in this phase.**
**Rule:** Do not hardcode visual values into individual screens when a token should exist.
Where an exact value is not yet approved, it is marked **OPEN** — do not guess.

> Companion to `UI_UX.md` (behavior), `USER_FLOWS.md` (flows), and `DESIGN_SYSTEM_V1.md`
> (implementation-ready summary). If an implementation conflicts with these documents,
> **stop and report the conflict.**

---

## V1 locked decisions (summary)

The following *decisions* are LOCKED. The exact numeric/hex values that realize them remain
**OPEN** until approved — they are not invented here.

- **Visual identity:** editorial, minimalist, premium, Gen-Z, calm, slightly playful,
  spacious, emotionally intelligent. Must NOT resemble a generic AI assistant, a typical
  dating app, a generic SaaS dashboard, or a gamified mental-health app.
- **Color:** warm ivory primary background; near-black primary text; restrained neutral
  secondary text; one restrained accent color. Accent is **semantic, not decorative**. No
  rainbow gradients, neon colors, or excessive colored cards.
- **Typography:** large editorial typography, strong hierarchy, short copy, generous
  whitespace, readability over density. Hierarchy: `HERO`, `SECTION`, `BODY`, `SECONDARY`,
  `MICRO`. No font selected (no approved font exists in the repo) — family stays **OPEN**.
- **Spacing:** generous whitespace, consistent tokens, no dense dashboard layouts.
- **Components:** a deliberately small vocabulary (§7a). Avoid proliferation.
- **Result hierarchy:** `THE READ` is the most important element; order in §7b. Scores support
  interpretation, never overpower it.
- **Motion:** subtle, purposeful, editorial — for progress, reveal, transition, confirmation.
  No bouncing, gimmicks, parallax, or decorative animation everywhere.
- **Privacy UX:** part of the design language; trust without interruption; concise messaging
  (e.g. "Your conversation stays yours."); no fear-based UI.
- **Emotional design:** curiosity yes; manipulation no. No fake countdowns/scarcity/scores/
  fabricated discoveries/misleading notifications/exaggerated copy. Insightful, calm, honest,
  slightly playful.
- **Accessibility:** first-class — Dynamic Type, VoiceOver, sufficient contrast, touch targets,
  Reduce Motion. Never weakened for aesthetics.

---

## 0. Existing anchors (from the repo)

These are the only concrete visual facts already present. They are **directional**, not a full
token set, and must not be treated as final values.

From `docs/PRODUCT.md` (LOCKED, qualitative):
- Warm ivory background.
- Black typography.
- Restrained accent.
- Large typography, generous whitespace.
- Minimal hand-drawn illustration.
- Editorial, minimalist, Gen-Z, premium.

From the iOS scaffold (`apps/iOS/Unstuck/ContentView.swift`, illustrative only):
- Uses `.largeTitle.bold()` for the wordmark and `.subheadline` / `.caption.monospaced()` for
  supporting text. These are **placeholder** choices in a non-product shell, **not** approved
  design tokens.

From contracts (LOCKED data shapes the UI renders, **not** visual tokens):
- `Confidence` ∈ { `high`, `medium`, `low` } plus the "not enough evidence" outcome.
- `SignalName` ∈ { interest, effort, consistency, intent, clarity, reciprocity,
  compatibility, attachment, risk }.
- `AnalysisResult` { `read`, `signals[]`, `doesNotMean[]`, `nextMove`, `overallConfidence` }.
- `AnalysisSignal` { `name`, `reading`, `confidence`, `evidence` }.

Everything below that is not explicitly marked LOCKED is **OPEN**.

---

## 1. Token philosophy (LOCKED)

- **Tokens over hardcoding.** Every reusable visual decision is a token. Screens compose
  tokens; they do not invent colors/sizes/radii.
- **Semantic over raw.** Screens use semantic tokens (`text.primary`, `surface.base`), not
  raw hex. Raw values live only in the token definitions.
- **Few, calm tokens.** The palette is intentionally small. Restraint is the design.
- **Confidence is a state, not a color ramp.** Confidence is represented by labeled states,
  not a numeric color scale.
- **OPEN values are tracked.** Any value not yet approved is recorded in `DESIGN_DECISIONS.md`
  and left as a named, unassigned token — never guessed.

---

## 2. Color tokens

### 2.1 Light theme (primary, editorial)

| Token | Role | Value |
|---|---|---|
| `surface.base` | App background (warm ivory) | **OPEN** — warm ivory, exact hex/sRGB TBD |
| `surface.elevated` | Raised content surface if used | **OPEN** |
| `text.primary` | Primary text (black) | **OPEN** — near-black, exact TBD |
| `text.secondary` | Supporting text | **OPEN** — derived from primary, lower weight |
| `text.tertiary` | Captions/meta | **OPEN** |
| `accent.primary` | Restrained accent | **OPEN** — used sparingly, not decorative |
| `accent.muted` | Quiet accent for optional actions | **OPEN** |
| `border.subtle` | Hairline separators (used minimally) | **OPEN** |
| `state.confidence.high` | Confidence: high | **OPEN** — labeled state, not loud |
| `state.confidence.medium` | Confidence: medium | **OPEN** |
| `state.confidence.low` | Confidence: low | **OPEN** |
| `state.evidence.insufficient` | "Not enough evidence" | **OPEN** — calm, trustworthy, not an error |
| `action.primary` | Primary button fill | **OPEN** |
| `action.primary.text` | Text on primary button | **OPEN** |
| `action.disabled` | Disabled primary | **OPEN** — must stay accessible |

### 2.2 Dark theme
- **OPEN** — whether v1 ships dark mode, and its warm-dark palette, is undecided. If shipped,
  it must remain calm/editorial (not generic high-contrast dark). See `DESIGN_DECISIONS.md`.

### 2.3 Color rules (LOCKED)
- Accent is **restrained**: used for emphasis and optional-action affordance, never decoration.
- No gradients in the core UI (per locked direction: no gradients/unnecessary UI).
- No color-only encoding. Every color state pairs with a text label (accessibility).
- No red/green as the sole good/bad signal — confidence is textual + stateful, not a traffic light.

---

## 3. Typography tokens

Exact family/size/weight are **OPEN**. The hierarchy is LOCKED (V1 names, mirrors `UI_UX.md` §5).

| Token (V1) | Role | Family | Size | Weight | Leading |
|---|---|---|---|---|---|
| `type.hero` | Editorial framing ("What's going on?", THE READ lead) | **OPEN** | **OPEN** (largest) | **OPEN** | **OPEN** (generous) |
| `type.section` | Result section headings (SIGNALS, WHY, …) | **OPEN** | **OPEN** | **OPEN** | **OPEN** |
| `type.body` | Reading text / THE READ body | **OPEN** | **OPEN** | **OPEN** | **OPEN** (reading width) |
| `type.secondary` | Supporting text / input labels / signal labels | **OPEN** | **OPEN** | **OPEN** | **OPEN** |
| `type.micro` | Captions / meta / timestamps / helper text | **OPEN** | **OPEN** | **OPEN** | **OPEN** |

The V1 hierarchy replaces the earlier role names: `display`→`hero`, `heading`→`section`,
`body`→`body`, `inputLabel`/`signalLabel`→`secondary` (role-specific usage), `caption`→`micro`.
Screens reference `type.*` tokens; never hardcode sizes.

### Typography rules (LOCKED)
- Large type, generous leading, calm rhythm. Short copy; readability over information density.
- Black-on-ivory primary text.
- Reading width is comfortable; THE READ is read, not scanned.
- Dynamic Type respected (accessibility); no fixed pixel assumptions that break at XL sizes.
- Custom font (if any) is **OPEN** — no approved font exists in the repo, so none is selected.
  System fonts are an acceptable interim; the exact choice is TBD and tracked in
  `DESIGN_DECISIONS.md`.

---

## 4. Spacing tokens

Exact values **OPEN**. The scale is locked as a consistent, generative rhythm.

| Token | Use |
|---|---|
| `space.0` | none |
| `space.xs` | tight internal gaps |
| `space.sm` | small gaps |
| `space.md` | default content rhythm |
| `space.lg` | section separation |
| `space.xl` | large editorial gaps |
| `space.2xl` | page-level breathing room |
| `space.contentInset` | horizontal content-edge inset (safe-area aware) |

### Spacing rules (LOCKED)
- Whitespace is the primary structural device, not boxes/dividers.
- Prefer fewer, larger gaps over many small ones.
- Consistent scale everywhere; no one-off magic numbers in screens.
- All insets are safe-area aware.

---

## 5. Radius tokens

Exact values **OPEN**. Philosophy LOCKED.

| Token | Use |
|---|---|
| `radius.none` | flat / editorial (default for text surfaces) |
| `radius.sm` | subtle controls |
| `radius.md` | input fields / minor containers (if used) |
| `radius.lg` | sheets / larger surfaces (if used) |
| `radius.pill` | optional-action chips / pills (if used) |

### Radius rules (LOCKED)
- Default to flat/editorial. Roundedness is intentional, not decorative.
- Avoid heavy rounding that reads as "card-y" — UNSTUCK is not a card app.

---

## 6. Interaction state tokens

States are LOCKED in meaning; exact visual treatment **OPEN**.

| Token | Applies to | Meaning |
|---|---|---|
| `state.rest` | all controls | default |
| `state.hover` | pointer contexts | subtle, optional |
| `state.press` | tappable elements | quiet confirm, not dramatic |
| `state.focus` | inputs | clear, calm focus ring |
| `state.disabled` | primary action | visually distinct + reason shown |
| `state.loading` | analysis | honest, calm, no fake progress |
| `state.error` | recoverable/fatal | calm, recoverable, no sensitive data |
| `state.empty` | tell/history | designed, warm, never an error |
| `state.confidence.{high,medium,low}` | signals/read | labeled uncertainty, not a score |
| `state.evidence.insufficient` | read | trustworthy "not enough evidence" |

---

## 7. Component vocabulary (V1 — small, deliberate)

The V1 system is a deliberately small vocabulary. **Avoid component proliferation** — compose
these primitives rather than creating one-off styled views.

### 7a. Core vocabulary (LOCKED set)

| Component | Role | Notes |
|---|---|---|
| `Button` | Primary / secondary actions | One primary `Button` per screen; secondary is quieter. Disabled shows reason. |
| `Option` | Selectable choice (e.g. a situation) | Used by `SituationPicker`. Selecting is calm, not gamified. |
| `TextInput` | Free-form and short text input | Backs TELL (`TellInput`) and ANSWER (`AnswerPrompt`). Keyboard/safe-area aware. |
| `Progress` | Loading / analysis state | Honest, calm, no fake progress. Used for analysis loading. |
| `Signal` | One analysis signal (`AnalysisSignal`) | Name + reading + evidence + confidence state. Not a loud score. |
| `Result` | The analysis result container | Composes the result hierarchy (§7b) in order. |
| `Insight` | A curiosity hook / deeper invitation | Genuine unanswered insight; never fake scarcity. |
| `BottomAction` | Pinned primary action | Full-width, safe-area-aware; the way forward. |

Conventions (LOCKED):
- **PascalCase SwiftUI views**, named by *role*, not visual style.
- Components compose tokens (§2–§5); they never hardcode colors/sizes/radii.
- No `Card`/`Badge`/`Gradient`/`Chip` components — the direction explicitly avoids those.

### 7b. Result hierarchy (LOCKED order)

Within `Result`, the most important element is **THE READ**. Render in this exact order:

```text
THE READ          (AnalysisResult.read)            — editorial lead, most important
  → SIGNALS      (AnalysisResult.signals[])       — one Signal each
  → WHY          (evidence synthesis)             — why this was concluded
  → WHAT THIS DOESN'T MEAN (AnalysisResult.doesNotMean[]) — guards overinterpretation
  → NEXT MOVE    (AnalysisResult.nextMove)        — one practical move
  → CURIOSITY HOOK (optional Insight)              — genuine, leads to ANSWER/SHOW
```

Reserved component names (compose the vocabulary above):
`ReadView` (THE READ), `SignalsSection` + `SignalItem` (SIGNALS), `WhySection` (WHY),
`DoesNotMeanSection` (WHAT THIS DOESN'T MEAN), `NextMoveView` (NEXT MOVE),
`CuriosityHookView` (CURIOSITY HOOK), `ConfidenceIndicator` (labeled confidence state —
**not** a numeric score). `SituationPicker`, `TellInput`, `AnswerPrompt`, `ShowAttach` map
to the input flow and use `Option`/`TextInput`/`Button`.

**Scores support the interpretation, never overpower it.** Confidence is a labeled state, not
a dominant numeric display.

Exact component APIs and styling are **OPEN** (implementation phase). Names are reserved so
implementation does not fragment the design language.

---

## 7c. Privacy UX (LOCKED as design language)

- Privacy is part of the design language, not a bolt-on legal layer.
- Sensitive-data interactions communicate trust **without interrupting** the experience.
- Use concise, calm messaging, e.g. **"Your conversation stays yours."**
- Inline, just-in-time privacy notes (e.g. before SHOW), never fear-based UI or heavy modals.
- No scare copy, no walls of warnings. Trust through clarity, not alarm.

---

## 7d. Emotional design (LOCKED)

- UNSTUCK may create curiosity but must **not** manipulate emotional uncertainty.
- **Never** use: fake countdowns, fake scarcity, fake scores, fabricated discoveries,
  misleading notifications, or exaggerated emotional copy.
- The product feels **insightful, calm, honest, and slightly playful.**
- This section is consistent with `docs/AI_BEHAVIOR.md` (Curiosity) and `UI_UX.md` §1, §7.

---

## 8. Accessibility requirements (LOCKED)

- Contrast: meet platform accessibility guidance on the ivory/black pairing (exact ratios
  **OPEN**/to be verified against final tokens).
- Dynamic Type: all layouts reflow at largest accessible sizes.
- VoiceOver: every interactive element has `accessibilityLabel`/`accessibilityHint`;
  confidence and signal states are announced as text, not color.
- Reduce Motion / Reduce Transparency: non-essential animation/transparency suppressed.
- No information by color alone.
- Min tappable target meets platform guidance (exact **OPEN**/verified).
- Haptics never the sole feedback.

---

## 9. Motion principles (LOCKED)

- **Subtle, purposeful, editorial.** Motion is used for progress, reveal, transition, and
  confirmation — nothing else.
- Fades and gentle transitions; result reveal is a calm editorial unfurl, never a dramatic
  "score reveal".
- **Never:** excessive bouncing, gimmicky motion, unnecessary parallax, or decorative
  animation everywhere.
- Honors Reduce Motion (non-essential animation suppressed).
- Exact durations/easings **OPEN**.

---

## 10. Iconography & illustration

- **Illustration** is LOCKED in direction: minimal, hand-drawn, editorial, restrained
  (from `docs/PRODUCT.md`). Do **not** add illustrations to every screen.
- **Iconography:** no approved icon set exists in the repo, so none is invented. A custom icon
  system is **OPEN**. System SF Symbols may be used as an interim where a symbol is genuinely
  needed; the final icon treatment is tracked in `DESIGN_DECISIONS.md`.
- No emoji-as-icon in the result experience.
- Avoid icon noise; icons are functional, never decorative.

---

## 11. Token governance

- Tokens are the only place raw values live.
- Adding a new screen-level value is a smell: add/extend a token instead.
- Any token left **OPEN** must be resolved via `DESIGN_DECISIONS.md` before it can be filled.
- When a token is approved, update it here (and only here); all screens pick it up.
