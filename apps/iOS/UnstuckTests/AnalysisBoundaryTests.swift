import XCTest
@testable import UnstuckBoundary

final class AnalysisBoundaryTests: XCTestCase {
    func testRancaRequestIsValueSemanticAndEquatable() {
        let a = RancaRequest(situation: "s", hasConversationEvidence: false, requestId: "r1")
        let b = RancaRequest(situation: "s", hasConversationEvidence: false, requestId: "r1")
        XCTAssertEqual(a, b)
    }

    func testBackendAnalysisServiceMapsDecodingFailureToInvalidResult() {
        let stub = StubAPIClient(postResult: .decodingFailure)
        let service = BackendAnalysisService(client: stub)
        let request = RancaRequest(situation: nil, hasConversationEvidence: false, requestId: "r")
        let result = waitForAsyncError(service.analyze(request))
        XCTAssertEqual(result as? AnalysisServiceError, .invalidResult)
    }

    func testBackendAnalysisServiceMapsUnacceptableStatusToRequestFailed() {
        let stub = StubAPIClient(postResult: .status(500))
        let service = BackendAnalysisService(client: stub)
        let request = RancaRequest(situation: nil, hasConversationEvidence: false, requestId: "r")
        let result = waitForAsyncError(service.analyze(request))
        XCTAssertEqual(result as? AnalysisServiceError, .requestFailed(status: 500))
    }

    func testBackendAnalysisServiceReturnsDecodedResultOnSuccess() {
        let expected = AnalysisResult(
            read: "Here is a read.",
            signals: [
                AnalysisSignal(
                    name: .interest,
                    reading: "Signs of engagement.",
                    confidence: .medium,
                    evidence: "Based on the situation described."
                )
            ],
            doesNotMean: ["Not a prediction of intent."],
            nextMove: "Notice one pattern this week.",
            overallConfidence: .medium
        )
        let stub = StubAPIClient(postResult: .success(expected))
        let service = BackendAnalysisService(client: stub)
        let request = RancaRequest(
            situation: "We have been talking but plans are vague.",
            hasConversationEvidence: false,
            requestId: "r1"
        )
        let got = waitForAsyncValue(service.analyze(request))
        XCTAssertEqual(got, expected)
    }

    func testConfidenceRawValuesAreStable() {
        XCTAssertEqual(Confidence.high.rawValue, "high")
        XCTAssertEqual(Confidence.medium.rawValue, "medium")
        XCTAssertEqual(Confidence.low.rawValue, "low")
    }

    func testSituationSetIsLockedAndStable() {
        let ids = Situation.allCases.map { $0.rawValue }.sorted()
        XCTAssertEqual(ids, [
            "breaking_up",
            "dating",
            "relationship",
            "situationship_hts",
            "someone_from_past",
            "something_else",
            "talking_stage",
        ].sorted())
        XCTAssertEqual(Situation.talkingStage.title, "Talking stage")
        XCTAssertEqual(Situation.somethingElse.title, "Something else")
    }

    // MARK: - Helpers

    private func waitForAsyncError(_ work: @escaping () async throws -> AnalysisResult) -> Error {
        let semaphore = DispatchSemaphore(value: 0)
        var captured: Error?
        Task {
            do { _ = try await work() }
            catch { captured = error }
            semaphore.signal()
        }
        semaphore.wait()
        return captured ?? NSError(domain: "test", code: -1)
    }

    private func waitForAsyncValue(_ work: @escaping () async throws -> AnalysisResult) -> AnalysisResult {
        let semaphore = DispatchSemaphore(value: 0)
        var captured: AnalysisResult?
        var capturedError: Error?
        Task {
            do { captured = try await work() }
            catch { capturedError = error }
            semaphore.signal()
        }
        semaphore.wait()
        if let captured { return captured }
        fatalError("analyze threw: \(String(describing: capturedError))")
    }
}

/// Test-only APIClient stub. Used to keep AnalysisService decoupled from the
/// network in unit tests; never used in production code.
private final class StubAPIClient: APIClient {
    enum PostOutcome {
        case success(AnalysisResult)
        case decodingFailure
        case status(Int)
    }

    private let postResult: PostOutcome

    init(postResult: PostOutcome) {
        self.postResult = postResult
    }

    func get<T: Decodable>(_ path: String, as type: T.Type) async throws -> T {
        throw APIError.invalidResponse
    }

    func post<T: Decodable, U: Encodable>(
        _ path: String, body: U, as type: T.Type
    ) async throws -> T {
        switch postResult {
        case .success(let result):
            guard let typed = result as? T else { throw APIError.decodingFailed }
            return typed
        case .decodingFailure:
            throw APIError.decodingFailed
        case .status(let code):
            throw APIError.unacceptableStatus(code)
        }
    }
}
