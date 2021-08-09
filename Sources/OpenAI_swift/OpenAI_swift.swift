import Foundation

let openai_key = ProcessInfo.processInfo.environment["OPENAI_KEY"]!

let openAiHost = "https://api.openai.com/v1/engines/davinci/completions"


public func completions(promptText: String, maxTokens: Int = 25) -> Array<Dictionary<String,String>> {
    let body: String = "{\"prompt\": \"" + promptText + "\", \"max_tokens\": \(maxTokens)" + "}"
    return openAiHelper(body: body)}

func openAiHelper(body: String)  -> Array<Dictionary<String,String>> {
    print("++ body:", body)
    var ret = Set<Dictionary<String,String>>();
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
        }
     }
    print("++ task:", task)
    task.resume()
    CFRunLoopRun()
    print("++ content:", content)
    let json = try? JSONSerialization.jsonObject(with: Data(content.utf8), options: [])
    if let json2 = json as! Optional<Dictionary<String, Any?>> {
        if let head = json2["head"] as? Dictionary<String, Any> {
            if let xvars = head["vars"] as! NSArray? {
                if let results = json2["results"] as? Dictionary<String, Any> {
                    if let bindings = results["bindings"] as! NSArray? {
                        if bindings.count > 0 {
                            for i in 0...(bindings.count-1) {
                                if let first_binding = bindings[i] as? Dictionary<String, Dictionary<String,String>> {
                                    var ret2 = Dictionary<String,String>();
                                    for key in xvars {
                                        let key2 : String = key as! String
                                        if let vals = (first_binding[key2]) {
                                            let vv : String = vals["value"] ?? "err2"
                                            ret2[key2] = vv } }
                                    if ret2.count > 0 {
                                        ret.insert(ret2)
                                    }}}}}}}}}
    return Array(ret) }

