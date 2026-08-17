import Foundation

/// Concrete `APIClient` backed by `URLSession`.
///
/// Production hardening (App Attest, certificate pinning, retries) is layered
/// on later; this implementation only enforces that responses are valid and
/// uses the configured environment's base URL. It never logs request bodies
/// or secrets (docs/SECURITY.md).
public struct URLSessionAPIClient: APIClient {
    private let baseURL: URL
    private let session: URLSession

    public init(environment: UnstuckEnvironment, session: URLSession = .shared) {
        self.baseURL = environment.apiBaseURL
        self.session = session
    }

    public func get<T: Decodable>(_ path: String, as type: T.Type) async throws -> T {
        guard let url = URL(string: path, relativeTo: baseURL) else {
            throw APIError.invalidResponse
        }
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw APIError.invalidResponse
        }
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw APIError.unacceptableStatus(http.statusCode)
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }

    /// POST a JSON-encoded body and decode the response.
    /// Never logs the body (the analysis request contains user relationship context;
    /// docs/SECURITY.md "no raw private conversation in logs").
    public func post<T: Decodable, U: Encodable>(
        _ path: String, body: U, as type: T.Type
    ) async throws -> T {
        guard let url = URL(string: path, relativeTo: baseURL) else {
            throw APIError.invalidResponse
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            req.httpBody = try JSONEncoder().encode(body)
        } catch {
            throw APIError.invalidResponse
        }
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: req)
        } catch {
            throw APIError.invalidResponse
        }
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw APIError.unacceptableStatus(http.statusCode)
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }
}
