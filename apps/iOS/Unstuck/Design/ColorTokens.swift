import SwiftUI

/// UNSTUCK design tokens (V1).
///
/// The *roles* are LOCKED by `docs/design/DESIGN_SYSTEM_V1.md`; the exact values are
/// OPEN pending product-owner approval (`docs/design/DESIGN_DECISIONS.md` §1–§5).
/// To stay faithful to the "do not invent a product decision" rule, exact values are
/// centralized here as clearly-marked **implementation placeholders**, in the locked
/// *direction* (warm ivory / near-black / restrained neutral / one restrained accent,
/// flat editorial radius, generous spacing). Changing a value later means changing it
/// in one place — screens consume these tokens, never literals.
///
/// No screen may hardcode a color, font, radius, or spacing value.
extension Color {
    /// `surface.base` — warm ivory primary background. Placeholder value (OPEN).
    static let unstuckSurfaceBase = Color(red: 0.976, green: 0.969, blue: 0.949)
    /// `surface.elevated` — quiet raised surface, rarely used. Placeholder (OPEN).
    static let unstuckSurfaceElevated = Color(red: 0.992, green: 0.988, blue: 0.976)
    /// `text.primary` — near-black primary text. Placeholder value (OPEN).
    static let unstuckTextPrimary = Color(red: 0.094, green: 0.086, blue: 0.078)
    /// `text.secondary` — restrained neutral secondary text. Placeholder (OPEN).
    static let unstuckTextSecondary = Color(red: 0.388, green: 0.373, blue: 0.345)
    /// `text.tertiary` — captions/meta. Placeholder (OPEN).
    static let unstuckTextTertiary = Color(red: 0.557, green: 0.537, blue: 0.502)
    /// `accent.primary` — the single restrained, semantic accent. Placeholder (OPEN).
    /// Used sparingly for emphasis and optional-action affordance; never decorative.
    static let unstuckAccent = Color(red: 0.204, green: 0.267, blue: 0.337)
    /// `accent.muted` — quiet accent for optional actions. Placeholder (OPEN).
    static let unstuckAccentMuted = Color(red: 0.337, green: 0.392, blue: 0.435)
    /// `border.subtle` — hairline separators, used minimally. Placeholder (OPEN).
    static let unstuckBorderSubtle = Color(red: 0.867, green: 0.851, blue: 0.820)
    /// `action.primary` — primary button fill. Placeholder (OPEN).
    static let unstuckActionPrimary = Color(red: 0.094, green: 0.086, blue: 0.078)
    /// `action.primary.text` — text on primary button. Placeholder (OPEN).
    static let unstuckActionPrimaryText = Color(red: 0.976, green: 0.969, blue: 0.949)
    /// `action.disabled` — disabled primary. Placeholder (OPEN); must stay accessible.
    static let unstuckActionDisabled = Color(red: 0.733, green: 0.718, blue: 0.690)

    /// Confidence state colors (LOCKED as *labeled states*, not a traffic-light ramp;
    /// `DESIGN_SYSTEM.md` §2.3: no color-only encoding). These are calm, low-saturation
    /// placeholders (OPEN) and always paired with a text label by `ConfidenceIndicator`.
    static let unstuckConfidenceHigh = Color(red: 0.204, green: 0.337, blue: 0.290)
    static let unstuckConfidenceMedium = Color(red: 0.439, green: 0.376, blue: 0.220)
    static let unstuckConfidenceLow = Color(red: 0.529, green: 0.467, blue: 0.388)
    /// `state.evidence.insufficient` — calm, trustworthy, not an error. Placeholder (OPEN).
    static let unstuckEvidenceInsufficient = Color(red: 0.439, green: 0.475, blue: 0.490)
}
