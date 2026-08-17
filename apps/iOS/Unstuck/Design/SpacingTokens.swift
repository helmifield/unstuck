import CoreGraphics

/// UNSTUCK spacing + radius tokens (V1).
///
/// Philosophy is LOCKED (generous whitespace, consistent scale, flat/editorial radius);
/// exact values are OPEN implementation specifics (`docs/design/DESIGN_DECISIONS.md` note)
/// and are centralized here so they can change globally. No screen may hardcode a spacing
/// or radius value.
enum UnstuckSpacing {
    static let zero: CGFloat = 0
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 36
    static let x2l: CGFloat = 56
    /// Horizontal content-edge inset; safe-area aware (added on top of safe area in screens).
    static let contentInset: CGFloat = 24
}

enum UnstuckRadius {
    /// Flat/editorial default.
    static let none: CGFloat = 0
    static let sm: CGFloat = 6
    static let md: CGFloat = 10
    static let lg: CGFloat = 16
    static let pill: CGFloat = 999
}
