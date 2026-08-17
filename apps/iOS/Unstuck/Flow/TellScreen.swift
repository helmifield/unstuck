import SwiftUI

/// Tell Us What's Happening — free-form TELL input. (USER_FLOWS §4; UI_UX §9.)
/// Calm typing; constructive minimum guidance (not a hard gate). No live scoring.
/// Privacy surfaced inline (raw is temporary, user-controlled).
struct TellScreen: View {
    @Binding var text: String
    let guidance: String?
    let canContinue: Bool
    let onContinue: () -> Void

    var body: some View {
        UnstuckScreen(step: .tell) {
            VStack(alignment: .leading, spacing: UnstuckSpacing.lg) {
                Text("What's happening?")
                    .font(UnstuckType.hero)
                    .foregroundStyle(Color.unstuckTextPrimary)
                Text("Describe it in your own words. A few sentences is plenty.")
                    .font(UnstuckType.secondary)
                    .foregroundStyle(Color.unstuckTextSecondary)

                TellTextInput(text: $text, placeholder: "We've been talking for a few weeks…")

                if let guidance {
                    Text(guidance)
                        .font(UnstuckType.micro)
                        .foregroundStyle(Color.unstuckTextTertiary)
                        .transition(.opacity)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            BottomAction("Get my read", isEnabled: canContinue) { onContinue() }
                .padding(.horizontal, UnstuckSpacing.contentInset)
                .padding(.bottom, UnstuckSpacing.md)
        }
    }
}
