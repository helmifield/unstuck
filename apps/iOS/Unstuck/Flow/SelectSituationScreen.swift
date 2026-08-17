import SwiftUI

/// Select Situation — pick one of the locked situations. (USER_FLOWS §3.)
/// Uses the `SituationPicker` (`Option` vocabulary). Continue is disabled until a
/// selection is made, with no manipulative urgency.
struct SelectSituationScreen: View {
    @Binding var selection: Situation?
    let onContinue: () -> Void

    var body: some View {
        UnstuckScreen(step: .selectSituation) {
            VStack(alignment: .leading, spacing: UnstuckSpacing.lg) {
                Text("Pick one")
                    .font(UnstuckType.hero)
                    .foregroundStyle(Color.unstuckTextPrimary)
                Text("Choose the situation that's closest. You can refine as you go.")
                    .font(UnstuckType.secondary)
                    .foregroundStyle(Color.unstuckTextSecondary)

                SituationPicker(selection: $selection, onSelect: { _ in })
                    .padding(.top, UnstuckSpacing.sm)
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: UnstuckSpacing.xs) {
                if selection == nil {
                    Text("Pick one to continue.")
                        .font(UnstuckType.micro)
                        .foregroundStyle(Color.unstuckTextTertiary)
                }
                BottomAction("Continue", isEnabled: selection != nil) { onContinue() }
            }
            .padding(.horizontal, UnstuckSpacing.contentInset)
            .padding(.bottom, UnstuckSpacing.md)
        }
    }
}
