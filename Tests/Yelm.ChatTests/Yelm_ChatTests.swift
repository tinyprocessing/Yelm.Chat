import XCTest
@testable import Yelm_Chat

final class Yelm_ChatTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Yelm_Chat().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
