import SwiftUI

/// `SignalItem` — one analysis signal (`AnalysisSignal`).
/// Shows name + reading + confidence state + evidence (why). No invented scores; confidence
/// supports the interpretation, never overpowers it.
/// (UI_UX §14; DESIGN_SYSTEM_V1 result hierarchy.)
struct SignalItem: View {
    let signal: AnalysisSignal

    var body: some View {
        VStack(alignment: .leading, spacing: UnstuckSpacing.sm) {
            HStack(alignment: .firstTextBaseline) {
                Text(signal.name.displayName)
                    .font(UnstuckType.secondary.weight(.semibold))
                    .foregroundStyle(Color.unstuckTextPrimary)
                Spacer(minLength: UnstuckSpacing.sm)
                ConfidenceIndicator(confidence: signal.confidence)
            }
            Text(signal.reading)
                .font(UnstuckType.body)
                .foregroundStyle(Color.unstuckTextPrimary)
            Text(signal.evidence)
                .font(UnstuckType.secondary)
                .foregroundStyle(Color.unstuckTextSecondary)
        }
        .padding(.vertical, UnstuckSpacing.md)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(signal.name.displayName): \(signal.reading)")
        .accessibilityValue("Evidence: \(signal.evidence)")
    }
}

extension SignalName {
    /// Human-readable display name for a signal.
    var displayName: String {
        switch self {
        case .interest: return "Interest"
        case .effort: return "Effort"
        case .consistency: return "Consistency"
        case .intent: return "Intent"
        case .clarity: return "Clarity"
        case .reciprocity: return "Reciprocity"
        case .compatibility: return "Compatibility"
        case .attachment: return "Attachment"
        case .risk: return "Risk"
        }
    }
}
