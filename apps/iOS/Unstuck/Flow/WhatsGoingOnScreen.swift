import SwiftUI

/// "What's going on?" — editorial framing step. Sets context before selecting a
/// situation. (USER_FLOWS §2.)
struct WhatsGoingOnScreen: View {
    let onContinue: () -> Void

    var body: some View {
        UnstuckScreen(step: .whatsGoingOn) {
            VStack(alignment: .leading, spacing: UnstuckSpacing.lg) {
                Text("What's going on?")
                    .font(UnstuckType.hero)
                    .foregroundStyle(Color.unstuckTextPrimary)
                Text("Tell us where things are. We'll give you an honest read — not a verdict.")
                    .font(UnstuckType.body)
                    .foregroundStyle(Color.unstuckTextSecondary)
                Spacer(minLength: UnstuckSpacing.xl)
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .safeAreaInset(edge: .bottom) {
            BottomAction("Continue") { onContinue() }
                .padding(.horizontal, UnstuckSpacing.contentInset)
                .padding(.bottom, UnstuckSpacing.md)
        }
    }
}
