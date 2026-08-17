import SwiftUI

/// `SituationPicker` — selects one relationship situation from the LOCKED set
/// (docs/PRODUCT.md / docs/design/USER_FLOWS.md).
///
/// Uses the approved `Option` component vocabulary (docs/design/DESIGN_SYSTEM_V1.md).
/// Selection is calm and interactive (subtle state-based visual change), not gamified.
/// Honors Reduce Motion and VoiceOver.
struct SituationPicker: View {
    @Binding var selection: Situation?
    let onSelect: (Situation) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: UnstuckSpacing.sm) {
            ForEach(Situation.allCases) { situation in
                SituationOption(
                    situation: situation,
                    isSelected: selection == situation
                ) {
                    withAnimation(UnstuckMotion.reduced(UnstuckMotion.select)) {
                        selection = situation
                    }
                    onSelect(situation)
                }
                .accessibilityIdentifier("situation.\(situation.rawValue)")
            }
        }
    }
}

/// `SituationOption` — a single selectable choice (`Option` vocabulary).
/// Flat/editorial; selected state is conveyed by text label + restrained accent, not color
/// alone (a11y: no color-only encoding).
struct SituationOption: View {
    let situation: Situation
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: UnstuckSpacing.md) {
                Text(situation.title)
                    .font(UnstuckType.body)
                    .foregroundStyle(Color.unstuckTextPrimary)
                Spacer()
                if isSelected {
                    Text("Selected")
                        .font(UnstuckType.micro)
                        .foregroundStyle(Color.unstuckAccent)
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, UnstuckSpacing.contentInset)
            .padding(.vertical, UnstuckSpacing.lg)
            .contentShape(Rectangle())
            .accessibilityElement(children: .combine)
            .accessibilityLabel(situation.title)
            .accessibilityValue(isSelected ? "Selected" : "Not selected")
            .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        }
        .buttonStyle(.plain)
        .background(
            Rectangle()
                .fill(isSelected ? Color.unstuckSurfaceElevated : Color.clear)
                .animation(UnstuckMotion.reduced(UnstuckMotion.select), value: isSelected)
        )
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(Color.unstuckAccent)
                .frame(width: isSelected ? 3 : 0)
                .animation(UnstuckMotion.reduced(UnstuckMotion.select), value: isSelected)
        }
    }
}
