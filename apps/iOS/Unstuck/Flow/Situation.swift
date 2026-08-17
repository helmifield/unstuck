import Foundation

/// The locked set of relationship situations a user can select
/// (docs/PRODUCT.md, docs/design/USER_FLOWS.md).
///
/// `Situation` is pure UI/flow state. It is deliberately **not** part of
/// `RancaRequest`, whose `situation` field is the free-form "Tell" description
/// (see `packages/contracts/src/ranca.ts`). Wiring the chosen category into the
/// analysis request is a future step (see docs/PHASE_3A_AUDIT.md).
public enum Situation: String, CaseIterable, Sendable, Codable, Identifiable {
    case talkingStage = "talking_stage"
    case dating = "dating"
    case situationship = "situationship_hts"
    case relationship = "relationship"
    case breakingUp = "breaking_up"
    case someoneFromPast = "someone_from_past"
    case somethingElse = "something_else"

    public var id: String { rawValue }

    /// Human-readable label, shown by the `SituationPicker` / `SituationOption`.
    public var title: String {
        switch self {
        case .talkingStage: return "Talking stage"
        case .dating: return "Dating"
        case .situationship: return "Situationship / HTS"
        case .relationship: return "Relationship"
        case .breakingUp: return "Breaking up"
        case .someoneFromPast: return "Someone from my past"
        case .somethingElse: return "Something else"
        }
    }
}
