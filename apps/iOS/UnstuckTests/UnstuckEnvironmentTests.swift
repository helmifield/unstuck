import XCTest
@testable import UnstuckBoundary

final class UnstuckEnvironmentTests: XCTestCase {
    func testLocalDefaultUsesLoopbackHost() {
        let env = UnstuckEnvironment.localDefault
        XCTAssertEqual(env.apiBaseURL.host, "127.0.0.1")
        XCTAssertEqual(env.apiBaseURL.scheme, "http")
    }
}
