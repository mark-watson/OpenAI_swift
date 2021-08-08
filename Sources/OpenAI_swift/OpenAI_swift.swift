import Foundation

let openAiHost = "https://api.openai.com/v1/engines/davinci/completions"

func openAiHelper [body: String] {
    
}
(defn- openai-helper [body]
  (let [json-results
        (client/post
          "https://api.openai.com/v1/engines/davinci/completions"
          {:accept :json
           :headers
                   {"Content-Type"  "application/json"
                    "Authorization" (str "Bearer " (System/getenv "OPENAI_KEY"))
                    }
           :body   body
           })]
    ((first ((json/read-str (json-results :body)) "choices")) "text")))


public func sparqlDbPedia(query: String) -> Array<Dictionary<String,String>> {
    return SparqlEndpointHelpter(query: query, endPointUri: "https://dbpedia.org/sparql?query=") }

public func sparqlWikidata(query: String) -> Array<Dictionary<String,String>> {
    return SparqlEndpointHelpter(query: query, endPointUri: "https://query.wikidata.org/bigdata/namespace/wdq/sparql?query=") }

func openAiHelper(body: String)  -> Array<Dictionary<String,String>> {
    var ret = Set<Dictionary<String,String>>();
    var content = "{}"

    let requestUrl = URL(string: openAiHost)!
    var request = URLRequest(url: requestUrl)
    request.httpMethod = "POST"
    request.httpBody = body.data(using: String.Encoding.utf8);
    
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            print("Error accessing OpenAI servers: \(error)")
            return
        }
        if let data = data, let s = String(data: data, encoding: .utf8) {
            print("Response data string:\n \(s)")
            content = s
        }
     }
     task.resume()
    
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

