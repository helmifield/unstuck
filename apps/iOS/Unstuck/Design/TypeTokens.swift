import SwiftUI

/// UNSTUCK typography tokens (V1).
///
/// Hierarchy is LOCKED: `HERO` → `SECTION` → `BODY` → `SECONDARY` → `MICRO`
/// (`docs/design/DESIGN_SYSTEM_V1.md`). The typeface family is OPEN (no approved font in
/// the repo), so these resolve to system fonts with `TextStyle` mappings that honor
/// **Dynamic Type** automatically. When an approved typeface is chosen
/// (`DESIGN_DECISIONS.md` §3), only this file changes — screens use `type.*` tokens.
///
/// No screen may hardcode a font.
enum UnstuckType {
    /// `type.hero` — editorial framing ("What's going on?", THE READ lead). Largest.
    static let hero = Font.system(.largeTitle, design: .serif).weight(.bold)
    /// `type.section` — result section headings (SIGNALS, WHY, …).
    static let section = Font.system(.title2, design: .serif).weight(.semibold)
    /// `type.body` — reading text / THE READ body.
    static let body = Font.system(.body, design: .serif)
    /// `type.secondary` — supporting text, input prompts, signal labels.
    static let secondary = Font.system(.subheadline)
    /// `type.micro` — captions / meta / timestamps / helper text.
    static let micro = Font.system(.caption)
}
