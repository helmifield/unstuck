import SwiftUI

/// Launch — first-launch entry. Calm, editorial, privacy-first.
/// (USER_FLOWS §1; UI_UX §1, privacy UX.)
///
/// One primary action: begin. A quiet inline privacy note, not fear-based copy.
struct LaunchScreen: View {
    let onBegin: () -> Void

    var body: some View {
        UnstuckScreen(step: .launch) {
            VStack(alignment: .leading, spacing: UnstuckSpacing.lg) {
                Text("Unstuck")
                    .font(UnstuckType.hero)
                    .foregroundStyle(Color.unstuckTextPrimary)

                Text("A quiet read on what's actually going on.")
                    .font(UnstuckType.body)
                    .foregroundStyle(Color.unstuckTextSecondary)

                Spacer(minLength: UnstuckSpacing.x2l)

                PrivacyNote()
                    .padding(.bottom, UnstuckSpacing.md)
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .safeAreaInset(edge: .bottom) {
            BottomAction("Start") { onBegin() }
                .padding(.horizontal, UnstuckSpacing.contentInset)
                .padding(.bottom, UnstuckSpacing.md)
        }
    }
}

/// Inline just-in-time privacy note. Concise, calm, no fear-based copy (UI_UX §1).
struct PrivacyNote: View {
    var body: some View {
        Label {
            Text("Your conversation stays yours. Nothing is stored unless you choose to add it.")
                .font(UnstuckType.micro)
                .foregroundStyle(Color.unstuckTextTertiary)
        } icon: {
            Image(systemName: "lock")
                .font(UnstuckType.micro)
                .foregroundStyle(Color.unstuckTextTertiary)
        }
        .accessibilityElement(children: .combine)
    }
}
