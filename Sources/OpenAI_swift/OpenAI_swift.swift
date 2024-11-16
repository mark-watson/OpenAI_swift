import Foundation

let openai_key = ProcessInfo.processInfo.environment["OPENAI_KEY"]!
let openAiHost = "https://api.openai.com/v1/chat/completions"

public func summarize(text: String, maxTokens: Int = 40) -> String {
    let messages = [
        ["role": "system", "content": "You are a helpful assistant that summarizes text concisely."],
        ["role": "user", "content": text]
    ]
    return openAiHelper(messages: messages, maxTokens: maxTokens)
}

public func questionAnswering(question: String) -> String {
    let messages = [
        ["role": "system", "content": "You are a helpful assistant that answers questions directly and concisely."],
        ["role": "user", "content": question]
    ]
    return openAiHelper(messages: messages, maxTokens: 25)
}

public func completions(promptText: String, maxTokens: Int = 25) -> String {
    let messages = [
        ["role": "user", "content": promptText]
    ]
    return openAiHelper(messages: messages, maxTokens: maxTokens)
}

func openAiHelper(messages: [[String: String]], maxTokens: Int = 25, temperature: Double = 0.3) -> String {
    var ret = ""
    var content = "{}"
    
    let requestBody: [String: Any] = [
        "model": "gpt-4o-mini",
        "messages": messages,
        "max_tokens": maxTokens,
        "temperature": temperature,
        "presence_penalty": 0.0,
        "frequency_penalty": 0.0,
        "top_p": 1.0
    ]
    
    let requestUrl = URL(string: openAiHost)!
    var request = URLRequest(url: requestUrl)
    request.httpMethod = "POST"
    
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
    } catch {
        print("Error creating request body: \(error)")
        return ret
    }
    
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
    
    //let c = String(content)
    //print("DEBUG: openAiHelper: c=\(c)")
    
    // Parse the response to get the assistant's message
    if let data = content.data(using: .utf8),
       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
       let choices = json["choices"] as? [[String: Any]],
       let firstChoice = choices.first,
       let message = firstChoice["message"] as? [String: Any],
       let content = message["content"] as? String {
        ret = content
    }
    
    return ret
}

public func embeddings(someText: String) -> [Float] {
    var embeddings: [Float] = [1.23]
    let embeddingsHost = "https://api.openai.com/v1/embeddings"
    
    let requestBody: [String: Any] = [
        "model": "text-embedding-ada-002",
        "input": someText
    ]
    
    let requestUrl = URL(string: embeddingsHost)!
    var request = URLRequest(url: requestUrl)
    request.httpMethod = "POST"
    
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
    } catch {
        print("Error creating request body: \(error)")
        return embeddings
    }
    
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer " + openai_key, forHTTPHeaderField: "Authorization")
    
    var content = "{}"
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
    
    // Parse the response to get the embedding vector
    if let data = content.data(using: .utf8) {
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let dataArray = json["data"] as? [[String: Any]],
               let firstItem = dataArray.first,
               let embeddingArray = firstItem["embedding"] as? [NSNumber] {
                
                // Convert NSNumber array to [Float]
                embeddings = embeddingArray.map { number in Float(truncating: number) }
                print("Successfully extracted \(embeddings.count) embeddings")
            } else {
                print("Failed to extract embedding array")
            }
        } else {
            print("Failed to parse JSON")
        }
    }    
    return embeddings
}