import SwiftUI

/// `TextInput` — free-form text input backing TELL.
/// (Approved vocabulary: docs/design/DESIGN_SYSTEM_V1.md; UI_UX §9 input behavior.)
///
/// Calm typing; no live scoring theatrics. Keyboard/safe-area aware via the caller's
/// `ScrollViewReader`/`.scrollDismissesKeyboard`. The caller owns the binding and any
/// minimum-guidance messaging (constructive, not punitive).
struct TellTextInput: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        TextEditor(text: $text)
            .font(UnstuckType.body)
            .foregroundStyle(Color.unstuckTextPrimary)
            .scrollContentBackground(.hidden)
            .padding(UnstuckSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: UnstuckRadius.md)
                    .fill(Color.unstuckSurfaceElevated)
            )
            .overlay(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(UnstuckType.body)
                        .foregroundStyle(Color.unstuckTextTertiary)
                        .padding(UnstuckSpacing.md)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
            .frame(minHeight: 160)
            .accessibilityLabel(placeholder)
            .accessibilityIdentifier("tell.input")
    }
}
