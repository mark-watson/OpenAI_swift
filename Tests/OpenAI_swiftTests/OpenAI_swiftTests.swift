    import XCTest
    @testable import OpenAI_swift

    final class OpenAI_swiftTests: XCTestCase {
        func testExample() {
            //let prompt = "He walked to the river"
            //let ret = completions(promptText: prompt)
            //print(ret)
            let question = "Where was Leonardo da Vinci born?"
            let answer = questionAnsweering(question: question)
            print(answer)
        }
    }
