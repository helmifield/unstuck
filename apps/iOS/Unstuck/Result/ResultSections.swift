import SwiftUI

/// A small, reusable result section header used by the result sub-sections.
/// Editorial label; not loud. (`type.section` token.)
struct ResultSectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(UnstuckType.section)
            .foregroundStyle(Color.unstuckTextPrimary)
            .padding(.top, UnstuckSpacing.lg)
            .accessibilityAddTraits(.isHeader)
    }
}

/// `ReadView` — THE READ. The most important element; visually dominant.
/// Concise, editorial lead. Reads first. (UI_UX §14; DESIGN_SYSTEM_V1 result hierarchy.)
struct ReadView: View {
    let read: String

    var body: some View {
        Text(read)
            .font(UnstuckType.hero)
            .foregroundStyle(Color.unstuckTextPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader)
    }
}

/// `SignalsSection` — renders each `AnalysisSignal` via `SignalItem`.
struct SignalsSection: View {
    let signals: [AnalysisSignal]

    var body: some View {
        VStack(alignment: .leading, spacing: UnstuckSpacing.zero) {
            ResultSectionHeader(title: "Signals")
            if signals.isEmpty {
                Text("Not enough evidence to read signals yet.")
                    .font(UnstuckType.secondary)
                    .foregroundStyle(Color.unstuckTextSecondary)
                    .padding(.top, UnstuckSpacing.sm)
            } else {
                ForEach(Array(signals.enumerated()), id: \.offset) { _, signal in
                    SignalItem(signal: signal)
                }
            }
        }
    }
}

/// `WhySection` — explains why a conclusion was reached, synthesized from signal evidence.
/// (UI_UX §14: WHY is derived from `evidence` across signals.)
struct WhySection: View {
    let explanation: String

    var body: some View {
        VStack(alignment: .leading, spacing: UnstuckSpacing.sm) {
            ResultSectionHeader(title: "Why")
            Text(explanation)
                .font(UnstuckType.body)
                .foregroundStyle(Color.unstuckTextPrimary)
        }
    }
}

/// `DoesNotMeanSection` — WHAT THIS DOESN'T MEAN. Guards against overinterpretation.
/// Present and prominent when populated. (UI_UX §14.)
struct DoesNotMeanSection: View {
    let items: [String]

    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: UnstuckSpacing.sm) {
                ResultSectionHeader(title: "What this doesn't mean")
                VStack(alignment: .leading, spacing: UnstuckSpacing.xs) {
                    ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                        Text("— \(item)")
                            .font(UnstuckType.body)
                            .foregroundStyle(Color.unstuckTextPrimary)
                    }
                }
            }
        }
    }
}

/// `NextMoveView` — one practical next move.
struct NextMoveView: View {
    let nextMove: String

    var body: some View {
        VStack(alignment: .leading, spacing: UnstuckSpacing.sm) {
            ResultSectionHeader(title: "Next move")
            Text(nextMove)
                .font(UnstuckType.body)
                .foregroundStyle(Color.unstuckTextPrimary)
        }
    }
}

/// `CuriosityHookView` — optional genuine unanswered insight.
/// Never fake scarcity (UI_UX §1, §7; AI_BEHAVIOR Curiosity).
/// In this vertical slice, curiosity hooks are surfaced only when the mock analysis provides one.
struct CuriosityHookView: View {
    let hook: String
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: UnstuckSpacing.xs) {
                Text("Curious")
                    .font(UnstuckType.micro.weight(.semibold))
                    .foregroundStyle(Color.unstuckAccent)
                Text(hook)
                    .font(UnstuckType.body)
                    .foregroundStyle(Color.unstuckTextPrimary)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(UnstuckSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: UnstuckRadius.md)
                    .fill(Color.unstuckSurfaceElevated)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Curiosity hook: \(hook)")
        .accessibilityHint("Explore this further")
    }
}
