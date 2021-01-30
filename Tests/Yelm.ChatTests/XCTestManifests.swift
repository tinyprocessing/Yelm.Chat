import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Yelm_ChatTests.allTests),
    ]
}
#endif
