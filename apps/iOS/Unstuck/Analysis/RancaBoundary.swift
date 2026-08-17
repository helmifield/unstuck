import Foundation

/// Ranca is the orchestration boundary between UNSTUCK and AI providers
/// (docs/ARCHITECTURE.md). The iOS app NEVER holds AI provider credentials and
/// never talks to a provider directly — it talks to the UNSTUCK backend, which
/// calls Ranca server-side. This protocol is the clean boundary only; no
/// provider is embedded yet.
public protocol RancaBoundary: Sendable {
    func analyze(_ request: RancaRequest) async throws -> AnalysisResult
}

public struct RancaRequest: Sendable, Equatable {
    public let situation: String?
    public let hasConversationEvidence: Bool
    public let requestId: String

    public init(situation: String?, hasConversationEvidence: Bool, requestId: String) {
        self.situation = situation
        self.hasConversationEvidence = hasConversationEvidence
        self.requestId = requestId
    }
}

/// JSON body for `POST /analysis`, matching the backend `RancaRequestSchema`.
/// Encodes `situation` only when non-nil so the wire shape matches
/// `exactOptionalPropertyTypes` on the server.
extension RancaRequest: Encodable {
    private enum CodingKeys: String, CodingKey {
        case situation, hasConversationEvidence, requestId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(situation, forKey: .situation)
        try container.encode(hasConversationEvidence, forKey: .hasConversationEvidence)
        try container.encode(requestId, forKey: .requestId)
    }
}
