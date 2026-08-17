# UNSTUCK Design System V1 — Implementation-Ready Summary

**Status:** Concise summary of the locked V1 design system. **No screens implemented yet.**
**Source of truth:** `DESIGN_SYSTEM.md` (full), `UI_UX.md` (behavior), `USER_FLOWS.md` (flows),
`DESIGN_DECISIONS.md` (open items). If an implementation conflicts with these, **stop and report.**

This file is the quick-reference for implementers. Exact numeric/hex values are **OPEN** until
approved (see `DESIGN_DECISIONS.md`) — do not invent them.

---

## Identity (LOCKED)
Editorial, minimalist, premium, Gen-Z, calm, slightly playful, spacious, emotionally
intelligent. **Not** a generic AI assistant, dating app, SaaS dashboard, or gamified
mental-health app.

## Color (LOCKED roles; OPEN values)
- Warm ivory background — `surface.base` (**OPEN**)
- Near-black primary text — `text.primary` (**OPEN**)
- Restrained neutral secondary text — `text.secondary` (**OPEN**)
- One restrained, **semantic** accent — `accent.primary` (**OPEN**)
- No rainbow gradients, neon, or excessive colored cards. Accent is semantic, not decorative.
- No color-only encoding; confidence is labeled, not a traffic light.

## Typography (LOCKED hierarchy; OPEN family/sizes)
`HERO` → `SECTION` → `BODY` → `SECONDARY` → `MICRO` (`type.hero`, `type.section`, `type.body`,
`type.secondary`, `type.micro`). Large, editorial, strong hierarchy, short copy, generous
whitespace, readability over density. Font family **OPEN** (none approved; system fonts
interim). Dynamic Type respected.

## Spacing (LOCKED philosophy; OPEN values)
Generous whitespace, consistent tokens (`space.0`…`space.2xl`, `space.contentInset`),
safe-area aware. No dense dashboard layouts. Whitespace is the primary structure, not boxes.

## Radius (LOCKED philosophy; OPEN values)
Flat/editorial default (`radius.none`…`radius.pill`). Intentional, not decorative. Avoid
"card-y" rounding.

## Components (LOCKED small vocabulary)
`Button` · `Option` · `TextInput` · `Progress` · `Signal` · `Result` · `Insight` ·
`BottomAction`. Compose these; avoid proliferation. No `Card`/`Badge`/`Gradient`/`Chip`.

## Result hierarchy (LOCKED order; THE READ is most important)
```
THE READ → SIGNALS → WHY → WHAT THIS DOESN'T MEAN → NEXT MOVE → CURIOSITY HOOK (optional)
```
Reserved names: `ReadView`, `SignalsSection`+`SignalItem`, `WhySection`, `DoesNotMeanSection`,
`NextMoveView`, `CuriosityHookView`, `ConfidenceIndicator`. Scores **support** interpretation,
never overpower it. Confidence is a labeled state, not a numeric score.

## Motion (LOCKED philosophy; OPEN timings)
Subtle, purposeful, editorial — for progress, reveal, transition, confirmation only. No
bouncing, gimmicks, parallax, or decorative animation. Honors Reduce Motion.

## Privacy UX (LOCKED)
Part of the design language. Trust without interruption. Concise, calm messaging
(e.g. "Your conversation stays yours."). Inline just-in-time notes before sensitive actions
(e.g. SHOW). No fear-based UI.

## Emotional design (LOCKED)
Curiosity yes; manipulation no. **Never** fake countdowns, scarcity, scores, fabricated
discoveries, misleading notifications, or exaggerated copy. Insightful, calm, honest, slightly
playful. (Aligns with `docs/AI_BEHAVIOR.md`.)

## Accessibility (LOCKED; first-class)
Dynamic Type, VoiceOver, sufficient contrast (target **OPEN** — see decisions), touch targets
(meet platform guidance), Reduce Motion. Never weakened for aesthetics.

## Iconography & illustration (LOCKED direction; OPEN system)
Illustration: minimal, hand-drawn, editorial, restrained — not on every screen. Icon system:
**OPEN** (none invented); SF Symbols as interim only.

## Dark mode (OPEN)
Not decided for v1; no palette invented.

---

## OPEN items requiring product-owner approval (full list in `DESIGN_DECISIONS.md`)
1. Exact color palette (ivory / near-black / secondary / accent)
2. Dark mode at v1?
3. Typeface family
4. Icon system (custom vs SF Symbols)
5. Contrast target (AA vs AAA)
6. Root navigation model
7. Landscape & tablet scope at v1

Exact numeric implementation specifics (font sizes, spacing/radius numbers, animation timings,
haptic mapping) are not product-owner decisions; they are specified when implementing the token
set, derived from the locked philosophy + approved palette/font. They must not be hardcoded into
screens.

---

## Implementation checklist
- [ ] Use `type.*`, `space.*`, `radius.*`, `surface/text/accent.*`, `state.*` tokens — never
      hardcode values.
- [ ] One primary `Button` per screen; `BottomAction` for the pinned forward action.
- [ ] Render `Result` in the locked order; THE READ leads.
- [ ] Confidence as labeled state; no numeric score dominance; no color-only encoding.
- [ ] Calm loading (`Progress`); no fake progress; no fabricated results on failure.
- [ ] Inline privacy note before SHOW; no fear-based copy.
- [ ] Honor Dynamic Type, VoiceOver labels, Reduce Motion, safe areas.
- [ ] If a token is still OPEN, do not implement with a guessed value — escalate.
