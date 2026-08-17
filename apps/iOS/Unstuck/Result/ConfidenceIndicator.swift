import SwiftUI

/// `ConfidenceIndicator` — labeled confidence state, not a numeric score.
/// (UI_UX §15; DESIGN_SYSTEM §2.3: no color-only encoding.)
/// Always pairs a text label with a calm accent dot; the text carries the meaning.
struct ConfidenceIndicator: View {
    let confidence: Confidence

    var body: some View {
        HStack(spacing: UnstuckSpacing.xs) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(UnstuckType.micro.weight(.medium))
                .foregroundStyle(Color.unstuckTextSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Confidence: \(label)")
    }

    private var label: String {
        switch confidence {
        case .high: return "High confidence"
        case .medium: return "Medium confidence"
        case .low: return "Low confidence"
        }
    }

    private var color: Color {
        switch confidence {
        case .high: return .unstuckConfidenceHigh
        case .medium: return .unstuckConfidenceMedium
        case .low: return .unstuckConfidenceLow
        }
    }
}
