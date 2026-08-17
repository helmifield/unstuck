# UNSTUCK — Unresolved Design Decisions

**Status:** Register of design decisions that genuinely require product-owner approval.
**Phase:** 2.6 — Lock Design System V1. **No implementation in this phase.**
**Rule:** Each item is **OPEN**. Do not guess a value during implementation. Resolve here first,
then propagate the answer into `DESIGN_SYSTEM.md` / `UI_UX.md`.

This file contains **only** genuine product-owner decisions still unresolved. Anything not
listed here is already LOCKED in `UI_UX.md`, `DESIGN_SYSTEM.md`, or `USER_FLOWS.md`.

> Exact numeric values that are pure implementation specifics (font sizes, spacing numbers,
> radius numbers, animation timings, haptic mapping) are **not** product-owner decisions and are
> not listed here. They are marked **OPEN** in `DESIGN_SYSTEM.md` so they are not hardcoded into
> screens; they will be specified when the token set is implemented, derived from the locked
> philosophy and the approved palette/font below. They must not be invented ad hoc at the
> screen level.

---

## 1. Exact color palette

**OPEN.** The color *roles* are LOCKED (warm ivory background, near-black primary text,
restrained neutral secondary text, one restrained semantic accent). The exact hex/sRGB
values for each role are not yet approved and must not be invented.

- `surface.base` (warm ivory)
- `text.primary` (near-black)
- `text.secondary` (restrained neutral)
- `accent.primary` (the single restrained, semantic accent)

**Why it needs approval:** the palette defines the entire editorial canvas and the brand
feel; qualitative direction is locked, exact hue/value is a genuine design decision.

## 2. Dark mode at v1

**OPEN.** Whether UNSTUCK ships dark mode in v1 is undecided. If yes, the warm-dark palette
must remain calm/editorial (not a generic high-contrast dark). No dark palette is invented.

**Why it needs approval:** v1 scope and a second palette are product decisions.

## 3. Typeface family

**OPEN.** No approved font exists in the repository, so none is selected. Large editorial
typography and the HERO/SECTION/BODY/SECONDARY/MICRO hierarchy are LOCKED; the actual typeface
is not. System fonts are an acceptable interim.

**Why it needs approval:** the editorial tone depends heavily on the typeface.

## 4. Icon system

**OPEN.** No approved icon set exists in the repo, so none is invented. Decide between a
custom icon set vs. continued use of system SF Symbols as the interim.

**Why it needs approval:** affects product identity and the "minimal, not icon-noisy" direction.

## 5. Contrast target

**OPEN.** Accessibility is first-class and locked; the specific contrast target level to
guarantee (e.g. WCAG AA vs AAA) on the ivory/black pairing needs agreement. Exact ratios will
be measured against the approved palette (item 1).

**Why it needs approval:** sets the a11y bar the palette must satisfy.

## 6. Root navigation model

**OPEN.** The core flow is linear and low-depth with no tab clutter (LOCKED). Whether there is
any root container (e.g. a quiet home vs. going straight into the flow) is not yet decided.

**Why it needs approval:** affects first-launch and returning-user entry structure.

## 7. Landscape & tablet scope at v1

**OPEN.** Mobile-first / portrait-primary is LOCKED. Whether v1 supports landscape and/or
iPad/tablet-specific layouts is undecided.

**Why it needs approval:** v1 form-factor scope is a product decision.

---

## Resolution process

1. Product owner approves a value for an item.
2. Update the corresponding token/section in `DESIGN_SYSTEM.md` (or behavior in `UI_UX.md`),
   replacing **OPEN** with the approved value.
3. Remove the resolved item from this file.
4. Implementation may then consume the token; screens must never hardcode the value.

**No UI implementation should begin on any element whose item above is still OPEN.**
