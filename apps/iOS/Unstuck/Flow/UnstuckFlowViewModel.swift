import Foundation
import Combine

/// View-model driving the Phase 3A vertical slice:
/// Launch → What's Going On? → Select Situation → Tell Us What's Happening → Initial Read.
///
/// Talks to the backend via the `RancaBoundary` (iOS → UNSTUCK API → Ranca boundary →
/// analysis). No AI provider is referenced here; the boundary is injected.
///
/// Kept nonisolated for clean SwiftUI wiring. `@Published` mutations performed after an
/// `await` are hopped to the main actor explicitly (see `requestAnalysis`). Sync mutations
/// are invoked from SwiftUI button actions, which run on the main thread at runtime.
final class UnstuckFlowViewModel: ObservableObject {
    @Published var step: UnstuckFlowStep = .launch
    @Published var selectedSituation: Situation?
    @Published var tellText: String = ""
    @Published private(set) var resultState: ResultState = .idle

    private let boundary: RancaBoundary

    enum ResultState: Equatable {
        case idle
        case loading
        case loaded(LoadedResult)
        case failed(message: String)
    }

    struct LoadedResult: Equatable {
        let result: AnalysisResult
        /// WHY explanation synthesized from signal evidence (UI_UX §14).
        let whyExplanation: String
        /// Optional genuine curiosity hook (never fake scarcity). nil when none.
        let curiosityHook: String?
    }

    init(boundary: RancaBoundary) {
        self.boundary = boundary
    }

    // MARK: - Flow navigation (forward always available; back always reversible)

    func goForward() {
        if let next = step.next { step = next }
    }

    func goBack() {
        if let prev = step.previous { step = prev }
    }

    var canContinueFromSituation: Bool { selectedSituation != nil }

    /// Constructive minimum guidance for TELL (not a hard gate). UI_UX §9.
    var tellGuidance: String? {
        let trimmed = tellText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return "Add a little about what's happening so we can read it."
        }
        if trimmed.count < 12 {
            return "A bit more helps — what specifically is going on?"
        }
        return nil
    }

    var canContinueFromTell: Bool {
        // Gentle, not punitive: allow continue once there's meaningful text.
        tellText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 12
    }

    // MARK: - Analysis

    func requestAnalysis() async {
        await MainActor.run { resultState = .loading }
        let request = RancaRequest(
            situation: nonEmptyTell(),
            hasConversationEvidence: false, // SHOW not part of this slice
            requestId: UUID().uuidString
        )
        do {
            let result = try await boundary.analyze(request)
            await MainActor.run {
                resultState = .loaded(LoadedResult(
                    result: result,
                    whyExplanation: synthesizeWhy(from: result),
                    curiosityHook: curiosityHook(for: result)
                ))
                step = .result
            }
        } catch {
            // Honest failure; never fabricate a result (UI_UX §11, AI_BEHAVIOR).
            await MainActor.run {
                resultState = .failed(message: friendlyErrorMessage(error))
            }
        }
    }

    func reset() {
        step = .launch
        selectedSituation = nil
        tellText = ""
        resultState = .idle
    }

    // MARK: - Private helpers

    private func nonEmptyTell() -> String? {
        let trimmed = tellText.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    /// WHY is derived from `evidence` across signals (UI_UX §14). Honest and bounded.
    private func synthesizeWhy(from result: AnalysisResult) -> String {
        let evidences = result.signals.map { $0.evidence }.prefix(3)
        if evidences.isEmpty {
            return "There wasn't enough evidence in what you described to reach a firm conclusion."
        }
        let joined = evidences.joined(separator: " ")
        // Summarize without inventing: present the basis plainly.
        return "This read is based on: \(joined)"
    }

    /// Curiosity hook is optional and must be genuine — never fake scarcity
    /// (UI_UX §1, §7; AI_BEHAVIOR Curiosity). In this slice we surface a calm invitation
    /// only when overall confidence is low, as a real way to get more evidence.
    private func curiosityHook(for result: AnalysisResult) -> String? {
        guard result.overallConfidence == .low else { return nil }
        return "There's more to see. Adding a little more context could sharpen this read."
    }

    private func friendlyErrorMessage(_ error: Error) -> String {
        if let analysisError = error as? AnalysisServiceError {
            switch analysisError {
            case .requestFailed:
                return "We couldn't reach the read right now. Try again in a moment."
            case .invalidResult:
                return "Something went wrong reading that. Try again."
            }
        }
        return "We couldn't complete that. Try again in a moment."
    }
}
