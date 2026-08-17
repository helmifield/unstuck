import Foundation

/// Thin, protocol-based HTTP client used to talk to the UNSTUCK API.
///
/// No AI provider credentials are present here; the client only calls the
/// UNSTUCK backend. The backend holds all sensitive orchestration (docs/ARCHITECTURE.md).
/// A concrete `URLSessionAPIClient` is wired at runtime; tests inject a stub.
public protocol APIClient: Sendable {
    func get<T: Decodable>(_ path: String, as type: T.Type) async throws -> T
    /// POST a JSON body and decode the response. Used by the analysis flow.
    func post<T: Decodable, U: Encodable>(
        _ path: String, body: U, as type: T.Type
    ) async throws -> T
}

public enum APIError: Error, Equatable {
    case invalidResponse
    case unacceptableStatus(Int)
    case decodingFailed
}

public struct HealthResponse: Decodable, Equatable, Sendable {
    public let status: String
    public let service: String
    public let version: String
    public let timestamp: String
}
