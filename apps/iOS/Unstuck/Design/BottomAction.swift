import SwiftUI

/// `BottomAction` — pinned primary action, safe-area aware; the way forward.
/// (Approved vocabulary: docs/design/DESIGN_SYSTEM_V1.md.)
///
/// One primary action per screen (UI_UX §8). Disabled state is visually distinct and the
/// reason is shown by the caller (constructive, not punitive). Touch target meets platform
/// guidance; VoiceOver label provided.
struct BottomAction: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void

    init(_ title: String, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.isEnabled = isEnabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(UnstuckType.secondary.weight(.semibold))
                .foregroundStyle(isEnabled ? Color.unstuckActionPrimaryText : Color.unstuckTextTertiary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, UnstuckSpacing.lg)
        }
        .disabled(!isEnabled)
        .background(
            RoundedRectangle(cornerRadius: UnstuckRadius.md)
                .fill(isEnabled ? Color.unstuckActionPrimary : Color.unstuckActionDisabled)
        )
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
    }
}
