import Foundation

let openai_key = ProcessInfo.processInfo.environment["OPENAI_KEY"]!

let openAiHost = "https://api.openai.com/v1/engines/davinci/completions"


public func completions(promptText: String, maxTokens: Int = 25) -> String {
    let body: String = "{\"prompt\": \"" + promptText + "\", \"max_tokens\": \(maxTokens)" + "}"
    return openAiHelper(body: body)}

func openAiHelper(body: String)  -> String {
    print("++ body:", body)
    var ret = ""
    var content = "{}"
    
    let requestUrl = URL(string: openAiHost)!
    var request = URLRequest(url: requestUrl)
    request.httpMethod = "POST"
    request.httpBody = body.data(using: String.Encoding.utf8);
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer " + openai_key, forHTTPHeaderField: "Authorization")
    print("++ request.allHTTPHeaderFields:", request.allHTTPHeaderFields!)
    print("++ openai_key:", openai_key)
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        print("++ response:", response!)
        if let error = error {
            print("-->> Error accessing OpenAI servers: \(error)")
            return
        }
        if let data = data, let s = String(data: data, encoding: .utf8) {
            print("++ Response data string:\n \(s)")
            content = s
            CFRunLoopStop(CFRunLoopGetMain())
        }
    }
    print("++ task:", task)
    task.resume()
    CFRunLoopRun()
    print("++ content:", content)
    let c = String(content)
    print("++ c:", c)
    let i1 = c.range(of: "\"text\": ")
    print("++ i1:", i1)
    let i2 = c.range(of: "\"index\":")
    if let r1 = i1 {
        if let r2 = i2 {
            ret = String(String(String(c[r1.lowerBound..<r2.lowerBound]).dropFirst(9)).dropLast(2))
        }
    }
    return ret
}

