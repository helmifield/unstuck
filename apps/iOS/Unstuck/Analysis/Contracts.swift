import Foundation

/// Mirror of `packages/contracts/src/analysis.ts`. Confidence is evidence-based
/// and must lower when evidence is short or conflicting (docs/AI_BEHAVIOR.md).
public enum Confidence: String, Codable, Sendable {
    case high, medium, low
}

public enum SignalName: String, Codable, Sendable {
    case interest, effort, consistency, intent, clarity, reciprocity, compatibility, attachment, risk
}

public struct AnalysisSignal: Codable, Equatable, Sendable {
    public let name: SignalName
    public let reading: String
    public let confidence: Confidence
    /// Why this conclusion was reached. Required, never invented.
    public let evidence: String
}

/// The structured result UNSTUCK consumes. Produced by Ranca; UNSTUCK depends
/// on this shape, not on any specific AI provider.
public struct AnalysisResult: Codable, Equatable, Sendable {
    public let read: String
    public let signals: [AnalysisSignal]
    public let doesNotMean: [String]
    public let nextMove: String
    public let overallConfidence: Confidence
}
