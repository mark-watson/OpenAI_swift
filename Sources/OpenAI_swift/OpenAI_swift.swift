import Foundation

let openai_key = ProcessInfo.processInfo.environment["OPENAI_KEY"]!

let openAiHost = "https://api.openai.com/v1/chat/completions"

public func summarize(text: String, maxTokens: Int = 40) -> String {
    //let body: String = "{\"prompt\": \"" + text + "\", \"max_tokens\": \(maxTokens), \"presence_penalty\": 0.0, \"temperature\": 0.3, \"top_p\": 1.0, \"frequency_penalty\": 0.0}"
    let body: String = "{\"messages\": [ {\"role\": \"user\"," + " \"content\": \"Summarize the following text: " + text + "\"}], \"model\": \"gpt-3.5-turbo\"}"
   return openAiHelper(body: body)}

public func questionAnswering(question: String) -> String {
    //let body: String = "{\"prompt\": \"nQ: " + question + " nA:\", \"max_tokens\": 25, \"presence_penalty\": 0.0, \"temperature\": 0.3, \"top_p\": 1.0, \"frequency_penalty\": 0.0 , \"stop\": [\"\\n\"]}"
    let body: String = "{\"messages\": [ {\"role\": \"user\"," + " \"content\": \"Answer the question: " + question + "\"}], \"model\": \"gpt-3.5-turbo\"}"
    let answer = openAiHelper(body: body)
    if let i1 = answer.range(of: "nQ:") {
        return String(answer[answer.startIndex..<i1.lowerBound])
        //return String(answer.prefix(i1.lowerBound))
    }
    return answer}

public func completions(promptText: String, maxTokens: Int = 25) -> String {
    let body: String = "{\"messages\": [ {\"role\": \"user\"," + " \"content\": \"Continue the following text: " + promptText + "\"}], \"model\": \"gpt-3.5-turbo\"}"
    //let body: String = "{\"prompt\": \"" + promptText + "\", \"max_tokens\": \(maxTokens),  \"model\": \"gpt-3.5-turbo\" }"
    print("**>> body: ", body)
    return openAiHelper(body: body)}

func openAiHelper(body: String)  -> String {
    var ret = ""
    var content = "{}"
    let requestUrl = URL(string: openAiHost)!
    var request = URLRequest(url: requestUrl)
    request.httpMethod = "POST"
    request.httpBody = body.data(using: String.Encoding.utf8);
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer " + openai_key, forHTTPHeaderField: "Authorization")
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            print("-->> Error accessing OpenAI servers: \(error)")
            return
        }
        if let data = data, let s = String(data: data, encoding: .utf8) {
            content = s
            CFRunLoopStop(CFRunLoopGetMain())
        }
    }
    task.resume()
    CFRunLoopRun()
    let c = String(content)
    print("**>> \(c)")
    let i1 = c.range(of: "\"text\":")
    if let r1 = i1 {
        let i2 = c.range(of: "\"index\":")
        if let r2 = i2 {
            ret = String(String(String(c[r1.lowerBound..<r2.lowerBound]).dropFirst(9)).dropLast(2))
        }
    }
    return ret
}

