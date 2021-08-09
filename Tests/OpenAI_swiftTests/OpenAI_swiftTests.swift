    import XCTest
    @testable import OpenAI_swift

    final class OpenAI_swiftTests: XCTestCase {
        func testExample() {
            let prompt = "Where is Paris?"
            let ret = completions(promptText: prompt)
            print(ret)
        }
    }
