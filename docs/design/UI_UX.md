# UNSTUCK UI/UX Specification

**Status:** APPROVED / LOCKED (visual direction). This document is the UI/UX source of truth.
**Phase:** 2.5 — UI/UX Source of Truth. **No screens are implemented in this phase.**
**Scope of this document:** interaction, navigation, state, and behavior principles. Exact
visual values (colors, fonts, dimensions, icons, components) live in `DESIGN_SYSTEM.md` and
are marked `OPEN` where not yet approved.

> **Source-of-truth rule.** These design documents govern all UI implementation by OpenHands
> and future agents. If an implementation conflicts with these documents, **stop and report
> the conflict** — do not silently redesign the product.

---

## 0. How to read this document

- **LOCKED** = a product-owner-approved decision. Do not change without re-approval.
- **OPEN** = a genuine design decision not yet approved. Document, do not guess. See
  `DESIGN_DECISIONS.md`.
- Where the repo already contains an artifact (e.g. `AnalysisResult`, `Confidence`), this
  spec references it rather than redefining it.

---

## 1. Product UX rules (LOCKED)

These are non-negotiable behavioral constraints derived from `docs/PRODUCT.md` and the
approved direction. Every screen and state must satisfy them.

1. **No login on first launch.** Authentication is never shown before value.
2. **Value before account creation.** The user must receive a real `THE READ` before being
   asked to create an account.
3. **Chat history is never required.** TELL alone must produce value.
4. **Screenshots are never required.** SHOW is an optional, additive level.
5. **Chat analysis is optional.** It is offered, never forced.
6. **Start by explaining.** The user can begin by simply describing what is happening (TELL).
7. **Curiosity leads deeper — naturally.** Follow-up questions (ANSWER) and the option to SHOW
   arise from genuine unanswered insight, never from gating or withholding.
8. **No manipulative fake results or fake certainty.** Uncertainty is shown honestly.
9. **Uncertainty must feel trustworthy, not like a failure.** "Not enough evidence" is a
   legitimate, well-designed outcome — never an error state or a dead end.

These rules override any implementation convenience.

---

## 2. Visual direction (LOCKED — qualitative)

From `docs/PRODUCT.md`. Exact values are in `DESIGN_SYSTEM.md`; the *feel* is locked here.

- Mobile-first. Gen-Z focused. Minimal, clean, modern.
- Emotionally intelligent, curiosity-driven, premium, visually calm.
- **Editorial** and **intentional** — extremely simple.
- Warm ivory background, black typography, restrained accent, large typography, generous
  whitespace, minimal hand-drawn illustration.
- **Not** generic AI, typical dating app, wellness, romance, SaaS, childish, noisy, overly
  colorful, or full of cards/badges/gradients/unnecessary UI.

This is the contract for every layout decision: calm > clever, whitespace > chrome,
editorial type > decoration.

---

## 3. Core flow (LOCKED)

```text
OPEN
  → WHAT'S GOING ON?
  → SELECT SITUATION
  → TELL US WHAT'S HAPPENING
  → INITIAL READ
  → DEEPER INSIGHT
```

- **OPEN** — first launch / entry.
- **WHAT'S GOING ON?** — the framing question; the emotional entry point.
- **SELECT SITUATION** — pick one context.
- **TELL US WHAT'S HAPPENING** — free-form description (TELL).
- **INITIAL READ** — the first `THE READ`, delivered before any account or payment.
- **DEEPER INSIGHT** — curiosity-driven: optional ANSWER (targeted questions) and optional
  SHOW (chat/screenshot), leading to a deeper read.

Situations (LOCKED set, mirrors `docs/PRODUCT.md`):

- Talking stage
- Dating
- Situationship / HTS
- Relationship
- Breaking up
- Someone from my past
- Something else

**The user must never be forced into SHOW / chat upload.** It is one additive level.

---

## 4. Locked input model

Three additive, non-mandatory levels of context:

| Level | Name | What | Required? |
|---|---|---|---|
| 1 | **TELL** | User describes the situation in their own words. | Required to get a first read. |
| 2 | **ANSWER** | User answers targeted follow-up questions. | Optional; deepens the read. |
| 3 | **SHOW** | User optionally provides screenshots or conversation text. | Optional; deepens the read. |

These are **levels**, not **steps**. The UI must never imply a rigid wizard that must be
completed. ANSWER and SHOW are surfaced as genuine, curiosity-driven invitations.

---

## 5. Typography hierarchy

Qualitative hierarchy is LOCKED (V1 token names: `HERO`, `SECTION`, `BODY`, `SECONDARY`,
`MICRO`); exact fonts/sizes are `OPEN` (see `DESIGN_SYSTEM.md` §3).

- **HERO / editorial title** (`type.hero`) — large, confident, sets the editorial tone (e.g.
  the "What's going on?" framing; THE READ lead).
- **SECTION heading** (`type.section`) — used for result sections: SIGNALS, WHY, WHAT THIS
  DOESN'T MEAN, NEXT MOVE.
- **BODY / reading text** (`type.body`) — comfortable, reading width; the result is read, not scanned.
- **SECONDARY** (`type.secondary`) — input labels/prompts (short, direct, warm) and signal
  labels (compact, paired with a confidence indicator).
- **MICRO / meta** (`type.micro`) — timestamps, confidence meta, helper text. Secondary in weight.

Principles:
- Large type, generous leading, generous whitespace. Calm reading rhythm.
- Black-on-ivory primary. Accent reserved, never decorative.
- No all-caps shouting beyond intentional editorial moments. (Wordmark "UNSTUCK" is the
  existing exception in the scaffold.)
- Numeric confidence is **not** shown as a loud score; confidence is conveyed as a labeled
  state (see §12).

---

## 6. Spacing philosophy

- Whitespace is the primary structural device, not dividers or boxes.
- Generous, consistent rhythm. Prefer fewer, larger gaps over many small ones.
- Content breathes; the result reads like an editorial page, not a feed of cards.
- Exact spacing tokens are `OPEN` (see `DESIGN_SYSTEM.md`), but the *rhythm* is locked:
  consistent scale, content-edge insets, safe-area-aware.

---

## 7. Interaction philosophy

- **One primary action per screen.** Secondary actions are visibly quieter.
- Calm over clever: no bounce, no surprise, no gamified nudges.
- Forward motion is always available (continue); back is always reversible.
- Curiosity invitations (ANSWER / SHOW) are presented as *options*, not obligations.
- No manipulative urgency, scarcity, or fake countdowns (per `docs/AI_BEHAVIOR.md` Curiosity).
- Tapping a signal or curiosity hook may lead deeper; nothing explodes into noise.

---

## 8. Button behavior

- **Primary button:** single, full intent, clearly the way forward. Disabled state must be
  visually distinct and explain why (e.g. "Add a little more" when TELL is too short —
  constructive, not punitive).
- **Secondary button / text link:** quieter weight; used for "Add a screenshot (optional)",
  "Answer a few questions", "Back".
- **No ghost CTAs that imply commitment** the product does not intend.
- Taps confirm with subtlety (see Haptics §16); no exaggerated press animations.

---

## 9. Input behavior

- **TELL input:** free-form, multiline, comfortable. The prompt is warm and short.
  - Gentle, constructive minimum guidance (not a hard gate): enough text is needed to read
    the situation. The UI invites more rather than blocking abruptly.
  - No live "scoring" theatrics while typing.
- **ANSWER input:** one targeted question at a time (or a short focused set), clearly optional
  to continue deeper.
- **SHOW input:** optional attach (screenshot) or paste (conversation text). Always labeled
  optional. Privacy surfaced inline (per `docs/SECURITY.md` — raw is temporary, user-controlled).
- Inputs respect keyboard, safe areas, and avoid content being hidden under the keyboard.
- No autocorrect/autocap fights with the user; typing feels calm.

---

## 10. Navigation behavior

- Linear, low-depth core flow. The user always knows where they are and how to go back.
- No tab bar clutter in the core analysis flow (exact root nav model is `OPEN`).
- Back is always available except where physically meaningless (e.g. mid-result).
- Deepening (ANSWER/SHOW) is additive context, not a new branch the user can get lost in.
- Returning users land in a place of immediate value, not a marketing screen (see USER_FLOWS).

---

## 11. Loading states

- Calm and honest. No fake progress bars that imply certainty about timing.
- Use a restrained, editorial loading treatment (e.g. quiet text or minimal mark).
- For analysis: communicate that the situation is being understood, not "computing a score".
- Never show partial/fabricated results while loading.
- If a step is genuinely quick, prefer a brief transition over a fake delay.

---

## 12. Empty states

- "Empty" is a valid, designed state, not an error.
- For TELL: a calm prompt inviting the user to describe what's happening; no shame.
- For history/recap (future): an empty state is warm and curiosity-led, not a "nothing here" void.
- No empty state ever pressures the user toward SHOW or account creation.

---

## 13. Error states

- Errors are calm, honest, and recoverable.
- Never expose internal/technical detail or any sensitive data (per `docs/SECURITY.md` logging).
- Distinguish **recoverable** (retry / try again) from **fatal** (graceful, with a clear path).
- Network/analysis failure must never display fabricated results as a fallback.
- A failure to analyze is not hidden behind a fake "low confidence" read — it is an error.

---

## 14. Result states

The result must support the LOCKED structure from `docs/AI_BEHAVIOR.md`, mapped to the existing
`AnalysisResult` contract (`apps/iOS/Unstuck/Analysis/Contracts.swift`,
`packages/contracts/src/analysis.ts`):

| Result section | Source field | UI behavior |
|---|---|---|
| **THE READ** | `AnalysisResult.read` | Concise, editorial. The lead. Reads first. |
| **SIGNALS** | `AnalysisResult.signals[]` | Each `AnalysisSignal` shown with its `reading`, `evidence`, and confidence state. No invented scores. |
| **WHY** | derived from `evidence` across signals | Explain why a conclusion was reached. |
| **WHAT THIS DOESN'T MEAN** | `AnalysisResult.doesNotMean[]` | Guards against overinterpretation. Present and prominent when populated. |
| **NEXT MOVE** | `AnalysisResult.nextMove` | One practical next move. |
| **CURIOSITY HOOK** | optional | Genuine unanswered insight (never fake scarcity). Leads to ANSWER/SHOW. |

- The result feels concise and editorial, **not** an AI-generated essay.
- Conflict/uncertainty among signals is shown honestly (per AI_BEHAVIOR "Identify conflicting signals").

---

## 15. Confidence states

Confidence uses the existing `Confidence` enum: `high`, `medium`, `low` (and the implicit
"not enough evidence" outcome). It is **never** a loud numeric score.

- **high** — quietly confident framing.
- **medium** — measured framing; signals some uncertainty.
- **low** — explicit, honest uncertainty.
- **not enough evidence** — a designed, trustworthy outcome, **not** an error or a failure.
  It may offer the curiosity path (ANSWER/SHOW) as a genuine way to get more evidence.

Confidence is shown per-signal and as an overall read state. Presentation exact tokens `OPEN`.

---

## 16. Accessibility

- WCAG-aligned contrast (black-on-ivory supports strong contrast; exact ratios `OPEN`/verified).
- Dynamic Type: respect user text-size settings; layouts must not break at largest sizes.
- VoiceOver: every interactive element has a meaningful accessibility label/hint.
- Reduce Motion: honor `Reduce Motion` and `Reduce Transparency` — non-essential animation is
  suppressed or removed.
- No information conveyed by color alone (confidence states include text labels).
- Min tappable target: meet platform accessibility guidance (exact size `OPEN`/verified).
- Haptics are non-essential; never the only feedback for an action.

---

## 17. Dark / light behavior

- A warm light (ivory) theme is the primary, editorial default per `docs/PRODUCT.md`.
- Dark mode behavior is **OPEN** — whether UNSTUCK ships dark mode at v1, and what "warm dark"
  means, requires product/design approval. If shipped, dark must remain calm and editorial, not
  a high-contrast generic dark. See `DESIGN_DECISIONS.md`.

---

## 18. Animation philosophy

- Restrained, purposeful. Animation supports understanding, never spectacle.
- Prefer fades and gentle transitions; avoid springy/bouncy/gamified motion.
- Must respect Reduce Motion (§16).
- Result reveal is calm and editorial — a quiet unfurl, not a dramatic reveal of a "score".

---

## 19. Haptic philosophy

- Subtle, used to confirm a deliberate action (e.g. submitting TELL, completing a level),
  never to reward engagement or manufacture satisfaction.
- Always optional/non-essential (suppressible by system settings).
- No haptic "slot-machine" or progress-reward patterns.
- Exact haptic mapping is `OPEN` (see `DESIGN_DECISIONS.md`).

---

## 20. Safe-area behavior

- Respect device safe areas and the home indicator inset on all screens.
- Input screens account for the keyboard without clipping content.
- No content tucked under the home indicator or notch.
- Generous insets support the calm, editorial whitespace (§6).

---

## 21. Responsive behavior

- **Mobile-first, iOS primary.** Portrait is the primary orientation.
- Landscape behavior is `OPEN` — whether supported at v1 requires a decision.
- Layouts are single-column editorial; no dense multi-pane layouts at phone sizes.
- Exact tablet/`iPad` behavior is `OPEN` (deferred; not a v1 focus).

---

## 22. Out of scope for this phase (LOCKED exclusions)

Per task constraints, these are **not** designed here and belong to future phases:

- Authentication / account creation UI
- Payments / StoreKit 2 / Pro entitlement UI
- Wrapped / annual recap UI
- Social sharing UI

Do not introduce these flows, states, or components. When their edges touch the core flow
(e.g. "value before account"), the core flow is designed to *defer* to them, not to implement
them.

---

## 23. Source-of-truth & conflict handling

- `UI_UX.md`, `DESIGN_SYSTEM.md`, and `USER_FLOWS.md` are the source of truth for UI/UX.
- They must stay consistent with `docs/PRODUCT.md`, `docs/AI_BEHAVIOR.md`,
  `docs/ARCHITECTURE.md`, and `docs/SECURITY.md`.
- **If an implementation conflicts with these documents: STOP and report the conflict.**
  Do not silently redesign.
- Unresolved decisions are tracked only in `DESIGN_DECISIONS.md`.
