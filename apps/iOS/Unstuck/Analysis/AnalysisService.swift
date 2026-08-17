import Foundation

/// Connects the iOS app to the backend's `/analysis` endpoint via the HTTP client.
/// Keeps the app decoupled from any concrete AI provider — it only knows the
/// UNSTUCK API contract. No provider credentials are present here (docs/ARCHITECTURE.md).
public struct BackendAnalysisService: RancaBoundary {
    private let client: APIClient
    private static let path = "/analysis"

    public init(client: APIClient) {
        self.client = client
    }

    public func analyze(_ request: RancaRequest) async throws -> AnalysisResult {
        do {
            return try await client.post(
                Self.path,
                body: request,
                as: AnalysisResult.self
            )
        } catch APIError.decodingFailed {
            throw AnalysisServiceError.invalidResult
        } catch APIError.unacceptableStatus(let status) {
            throw AnalysisServiceError.requestFailed(status: status)
        } catch APIError.invalidResponse {
            throw AnalysisServiceError.requestFailed(status: nil)
        }
    }
}

public enum AnalysisServiceError: Error, Equatable {
    case requestFailed(status: Int?)
    case invalidResult
}
