import SwiftUI

/// `Result` — the analysis result container. Renders the LOCKED hierarchy in order:
///
///   THE READ → SIGNALS → WHY → WHAT THIS DOESN'T MEAN → NEXT MOVE → CURIOSITY HOOK (optional)
///
/// THE READ is visually dominant. Scores/confidence support interpretation, never overpower it.
/// (UI_UX §14; DESIGN_SYSTEM_V1 result hierarchy.)
struct AnalysisResultView: View {
    let result: AnalysisResult
    let whyExplanation: String
    let curiosityHook: String?
    let onSelectCuriosity: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: UnstuckSpacing.lg) {
            ReadView(read: result.read)

            HStack(spacing: UnstuckSpacing.sm) {
                Text("Overall read")
                    .font(UnstuckType.micro)
                    .foregroundStyle(Color.unstuckTextTertiary)
                ConfidenceIndicator(confidence: result.overallConfidence)
            }

            SignalsSection(signals: result.signals)
            WhySection(explanation: whyExplanation)
            DoesNotMeanSection(items: result.doesNotMean)
            NextMoveView(nextMove: result.nextMove)

            if let hook = curiosityHook {
                CuriosityHookView(hook: hook, onSelect: onSelectCuriosity)
            }
        }
    }
}
