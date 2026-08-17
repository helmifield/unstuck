import Foundation

/// The linear, low-depth UNSTUCK flow.
/// (docs/design/USER_FLOWS.md; UI_UX §10 navigation: linear, low-depth, forward always
/// available, back always reversible.)
enum UnstuckFlowStep: Int, CaseIterable, Sendable {
    case launch
    case whatsGoingOn
    case selectSituation
    case tell
    case result

    var next: UnstuckFlowStep? {
        guard let i = UnstuckFlowStep.allCases.firstIndex(of: self) else { return nil }
        let next = UnstuckFlowStep.allCases.index(after: i)
        return next < UnstuckFlowStep.allCases.endIndex ? UnstuckFlowStep.allCases[next] : nil
    }

    var previous: UnstuckFlowStep? {
        guard let i = UnstuckFlowStep.allCases.firstIndex(of: self) else { return nil }
        let prev = UnstuckFlowStep.allCases.index(before: i)
        return prev >= UnstuckFlowStep.allCases.startIndex ? UnstuckFlowStep.allCases[prev] : nil
    }
}
