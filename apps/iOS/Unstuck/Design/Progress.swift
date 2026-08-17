import SwiftUI

/// `Progress` — calm, honest loading/analysis state.
/// No fake progress bars implying certainty about timing; no fabricated results.
/// (Approved vocabulary: docs/design/DESIGN_SYSTEM_V1.md; UI_UX §11 loading states.)
struct AnalysisProgress: View {
    let message: String

    init(message: String = "Reading the situation…") {
        self.message = message
    }

    var body: some View {
        VStack(spacing: UnstuckSpacing.lg) {
            // Honest, calm indicator: a single restrained mark that breathes.
            Circle()
                .stroke(Color.unstuckAccent, lineWidth: 2)
                .frame(width: 28, height: 28)
                .scaleEffect(1)
                .animation(UnstuckMotion.reduced(UnstuckMotion.progress), value: true)

            Text(message)
                .font(UnstuckType.secondary)
                .foregroundStyle(Color.unstuckTextSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
        .accessibilityAddTraits(.updatesFrequently)
    }
}

/// `Progress` for a determinate step indicator in onboarding (e.g. step dots).
/// Editorial, not gamified; communicates state/orientation only.
struct StepProgress: View {
    let step: Int
    let total: Int

    var body: some View {
        HStack(spacing: UnstuckSpacing.xs) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(index < step ? Color.unstuckAccent : Color.unstuckBorderSubtle)
                    .frame(width: index == step - 1 ? 24 : 8, height: 4)
                    .animation(UnstuckMotion.reduced(UnstuckMotion.select), value: step)
            }
        }
        .accessibilityHidden(true)
    }
}
