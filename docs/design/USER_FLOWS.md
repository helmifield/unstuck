# UNSTUCK User Flows

**Status:** Source of truth for approved flows.
**Phase:** 2.5 — UI/UX Source of Truth. **No screens are implemented in this phase.**
**Rule:** These flows are LOCKED in structure. If an implementation conflicts, **stop and
report** — do not silently redesign.

> Companion to `UI_UX.md` (behavior) and `DESIGN_SYSTEM.md` (tokens). Flow steps reference
> the LOCKED core flow and input model. Visual details are `OPEN` per the design system.

---

## 0. Shared conventions

- **TELL** is required to get a first read; **ANSWER** and **SHOW** are optional, additive,
  curiosity-driven — never gates.
- Authentication, payments, Wrapped, and social sharing are **out of scope** for this phase
  and are **not** designed here.
- "Account wall" is explicitly forbidden before value (UX rule §1–§2). Where the product will
  eventually ask for an account, the flow **defers** to that future phase; it does not block.
- Confidence and "not enough evidence" are designed outcomes, not errors.

---

## 1. First-time user

```text
OPEN
 → WHAT'S GOING ON?
 → SELECT SITUATION
 → TELL US WHAT'S HAPPENING
 → (analysis, calm loading)
 → INITIAL READ  ← value delivered here, before any account
 → CURIOSITY HOOK (optional, genuine)
    ├─ ANSWER a few targeted questions (optional)
    └─ SHOW a screenshot / conversation (optional)
 → DEEPER READ (if more context added)
 → NEXT MOVE
 → (deferred: account creation is a future phase; never shown before this value)
```

**Rules:**
- No login prompt at any point in this flow.
- INITIAL READ must render fully from TELL alone.
- CURIOSITY HOOK is an invitation, never a gate; declining it leaves the user with a complete
  initial read and NEXT MOVE.
- If evidence is insufficient for a confident read, show the designed "not enough evidence"
  state and offer ANSWER/SHOW as a genuine way to get more evidence.

---

## 2. Talking stage

```text
SELECT SITUATION → "Talking stage"
 → TELL: describe what's happening
 → INITIAL READ (signals most relevant: interest, effort, consistency, intent, clarity)
 → optional ANSWER: targeted questions about frequency, initiation, plans, mixed signals
 → optional SHOW: paste conversation / attach screenshot
 → DEEPER READ (if context added)
 → NEXT MOVE
```

**Signal emphasis (illustrative, not exhaustive):** interest, effort, consistency, intent,
clarity. The engine decides which signals apply; the UI never invents signals.

---

## 3. Dating

```text
SELECT SITUATION → "Dating"
 → TELL: describe what's happening
 → INITIAL READ (signals e.g. consistency, reciprocity, compatibility, intent)
 → optional ANSWER: targeted questions about patterns, exclusivity, follow-through
 → optional SHOW
 → DEEPER READ (if context added)
 → NEXT MOVE
```

---

## 4. Situationship / HTS

```text
SELECT SITUATION → "Situationship / HTS"
 → TELL: describe what's happening
 → INITIAL READ (signals e.g. clarity, intent, consistency, effort, attachment)
 → optional ANSWER: targeted questions about definition, mixed signals, boundaries
 → optional SHOW
 → DEEPER READ (if context added)
 → NEXT MOVE
```

**Note:** "Mixed signals" is a common theme; the UI presents conflict honestly (AI_BEHAVIOR:
identify conflicting signals) without forcing a verdict.

---

## 5. Relationship

```text
SELECT SITUATION → "Relationship"
 → TELL: describe what's happening
 → INITIAL READ (signals e.g. reciprocity, compatibility, consistency, effort, risk)
 → optional ANSWER: targeted questions about dynamics, change over time, concerns
 → optional SHOW
 → DEEPER READ (if context added)
 → NEXT MOVE
```

---

## 6. Breaking up

```text
SELECT SITUATION → "Breaking up"
 → TELL: describe what's happening
 → INITIAL READ (signals e.g. clarity, intent, consistency, attachment, risk)
 → optional ANSWER: targeted questions about reasons, behavior, finality
 → optional SHOW
 → DEEPER READ (if context added)
 → NEXT MOVE
```

**Care:** tone is emotionally intelligent and non-judgmental (AI_BEHAVIOR: never judge the user).
Move-On is one context, not the whole product; a low/unfavorable read is never framed as failure.

---

## 7. Someone from my past

```text
SELECT SITUATION → "Someone from my past"
 → TELL: describe what's happening
 → INITIAL READ (signals e.g. intent, consistency, clarity, attachment)
 → optional ANSWER: targeted questions about re-contact, current behavior, history
 → optional SHOW
 → DEEPER READ (if context added)
 → NEXT MOVE
```

---

## 8. Optional deeper questions (ANSWER)

This is the **ANSWER** level, surfaced by a genuine CURIOSITY HOOK from the initial read.

```text
INITIAL READ
 → CURIOSITY HOOK (e.g. "There's more to see if you answer a couple of questions")
 → ANSWER: one targeted question at a time (or a short focused set), clearly optional
 → (analysis, calm loading)
 → DEEPER READ (integrates TELL + ANSWER)
 → NEXT MOVE
 → optional SHOW still available (additive)
```

**Rules:**
- Questions are targeted and situation-aware, generated from genuine gaps in evidence.
- The user can stop after any question; a partial deepen still yields a valid deeper read.
- No fake scarcity ("only 1 question left"). Curiosity is honest (AI_BEHAVIOR).

---

## 9. Optional chat analysis (SHOW)

This is the **SHOW** level, the most optional and the most privacy-sensitive.

```text
CURIOSITY HOOK / explicit option
 → "Add a screenshot or paste a conversation (optional)"
 → privacy note shown inline: raw material is temporary, user-controlled (docs/SECURITY.md)
 → SHOW: attach screenshot(s) and/or paste conversation text
 → (analysis, calm loading)
 → DEEPER READ (integrates TELL ± ANSWER + SHOW)
   ↳ can answer: Are they into me? Are they serious? What does this mean?
     What should I reply? Any red flags? Could this be a scam? What's the dynamic?
     Am I being delusional? (per docs/PRODUCT.md Chat analysis)
 → NEXT MOVE
```

**Rules:**
- SHOW is never required, never defaulted on, never pressured.
- Privacy is surfaced inline before upload, not buried in fine print.
- Conclusions remain evidence-based with stated uncertainty (AI_BEHAVIOR); never a scammer/
  manipulator accusation without sufficient evidence.
- Raw chat is temporary by default; the UI reflects user-controlled save/delete (future phase
  for full management UI, but the *affordance* is part of trust).

---

## 10. Result

The terminal experience of any depth (initial or deeper). Renders the LOCKED structure.

```text
RESULT
 ├─ THE READ            (AnalysisResult.read)            — editorial lead
 ├─ SIGNALS             (AnalysisResult.signals[])       — SignalItem each, with confidence
 ├─ WHY                 (evidence synthesis)             — why this was concluded
 ├─ WHAT THIS DOESN'T MEAN (AnalysisResult.doesNotMean[]) — guards overinterpretation
 ├─ NEXT MOVE           (AnalysisResult.nextMove)        — one practical move
 └─ CURIOSITY HOOK      (optional)                       — genuine, leads to ANSWER/SHOW
```

**States within the result:**
- **Confidence states:** high / medium / low shown as labeled states per signal and overall.
- **Insufficient evidence:** a designed, trustworthy state — not an error. May offer the
  curiosity path to add evidence.
- **Conflicting signals:** shown honestly, not smoothed into a false verdict.

**Rules:**
- Concise and editorial, not an AI essay.
- No fabricated scores; no mind-reading claims.
- Reveal is calm (motion principle), not a dramatic score reveal.

---

## 11. Returning user

```text
OPEN (returning)
 → WHAT'S GOING ON? (immediate re-entry to value, no marketing wall)
 → SELECT SITUATION
 → TELL US WHAT'S HAPPENING
 → INITIAL READ
 → … (same core flow)
```

**Rules:**
- A returning user lands in a place of immediate value, not an onboarding/marketing screen.
- (History/recap are future phases — Wrapped/annual recap are out of scope here. Their empty
  states, when built, follow the warm, curiosity-led empty-state principle from `UI_UX.md`.)
- No friction is added on return that wasn't present on first use (e.g. no surprise login wall).

---

## 12. Out of scope (LOCKED exclusions)

The following are **not** designed in this phase and must not be implemented:

- Authentication / account creation flows
- Payments / StoreKit 2 / Pro entitlement flows
- Wrapped / annual recap flows
- Social sharing flows

Where these would touch the core flow (e.g. gating deeper analysis behind Pro), the core flow
is designed to **defer** to the future phase, not to implement or mock the gate.

---

## 13. Cross-flow consistency checklist (LOCKED)

Every flow above must satisfy:

- [ ] No login before value.
- [ ] TELL alone produces a complete initial read.
- [ ] ANSWER and SHOW are optional, additive, never required.
- [ ] Curiosity is genuine, never fake scarcity.
- [ ] Uncertainty and "not enough evidence" are designed, trustworthy states.
- [ ] No fabricated scores or mind-reading claims.
- [ ] Privacy surfaced inline for SHOW.
- [ ] Calm loading/result reveal; no dramatic score theatrics.
- [ ] Authentication/payments/Wrapped/sharing are not implemented here.
