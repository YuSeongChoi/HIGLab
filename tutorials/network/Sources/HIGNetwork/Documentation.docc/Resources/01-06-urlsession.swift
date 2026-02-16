import Foundation

// URLSession: HTTP 레벨의 고수준 API
let url = URL(string: "https://api.example.com/messages")!
var request = URLRequest(url: url)
request.httpMethod = "POST"
request.setValue("application/json", forHTTPHeaderField: "Content-Type")

let message = ["text": "Hello, World!"]
request.httpBody = try? JSONEncoder().encode(message)

// HTTP 요청 전송
URLSession.shared.dataTask(with: request) { data, response, error in
    if let httpResponse = response as? HTTPURLResponse {
        print("HTTP 상태 코드: \(httpResponse.statusCode)")
    }
}.resume()
