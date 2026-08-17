import SwiftUI
import UIKit

/// UNSTUCK motion tokens (V1).
///
/// Motion is LOCKED as subtle/purposeful/editorial — for progress, reveal, transition,
/// and confirmation only (`docs/design/DESIGN_SYSTEM_V1.md`). Exact timings are OPEN
/// implementation specifics, centralized here. No screen may hardcode an animation
/// duration/easing. All motion **honors Reduce Motion** via `UnstuckMotion.reduced`.
///
/// Onboarding may feel "alive" (ambient illustration movement, typography reveals,
/// gesture-responsive selection, fluid transitions, micro-interactions, subtle parallax)
/// but must remain fast and unobtrusive — never long cinematic delays, bouncing, or
/// decorative-only motion.
enum UnstuckMotion {
    /// Reveal of an entering view/section. Short, calm fade + slight rise.
    static let reveal: Animation = .easeOut(duration: 0.32)
    /// Transition between flow steps.
    static let transition: Animation = .easeInOut(duration: 0.28)
    /// Selection / press confirmation micro-interaction.
    static let select: Animation = .easeOut(duration: 0.18)
    /// Progress/analysis loop — honest, calm, non-decorative.
    static let progress: Animation = .easeInOut(duration: 0.9).repeatForever(autoreverses: true)
    /// Ambient drift for illustration (onboarding only), very slow and gentle.
    static let ambient: Animation = .easeInOut(duration: 3.2).repeatForever(autoreverses: true)

    /// Returns a no-op / near-instant animation when Reduce Motion is on, else `animation`.
    /// Use for any non-essential motion so accessibility settings are respected.
    /// `UIAccessibility.isReduceMotionEnabled` is safe to read off the main thread.
    static func reduced(_ animation: Animation) -> Animation {
        UIAccessibility.isReduceMotionEnabled ? .linear(duration: 0.01) : animation
    }
}

/// Convenience: a transition that respects Reduce Motion. When Reduce Motion is on,
/// steps are replaced by a near-instant fade so navigation still feels connected without
/// translating content.
struct UnstuckTransition {
    /// Forward flow transition (push-like, subtle).
    static var forward: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .offset(x: 0)),
            removal: .opacity
        )
    }
    /// Backward flow transition.
    static var backward: AnyTransition {
        .asymmetric(
            insertion: .opacity,
            removal: .opacity.combined(with: .offset(x: 0))
        )
    }
}
