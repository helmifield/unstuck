import Foundation

/// Runtime environment configuration for the UNSTUCK iOS app.
///
/// Security (docs/SECURITY.md):
/// - No production credentials, API keys, or AI provider credentials live in the app.
/// - The API base URL is configurable but defaults to a local host; production
///   endpoints are injected via a build configuration, never hardcoded.
/// - This type carries no secrets. Sensitive device material lives in Keychain.
public struct UnstuckEnvironment: Sendable, Equatable {
    public let apiBaseURL: URL

    public init(apiBaseURL: URL) {
        self.apiBaseURL = apiBaseURL
    }

    /// Safe default for local development against the local NestJS API.
    public static let localDefault = UnstuckEnvironment(
        apiBaseURL: URL(string: "http://127.0.0.1:3000")!
    )
}
