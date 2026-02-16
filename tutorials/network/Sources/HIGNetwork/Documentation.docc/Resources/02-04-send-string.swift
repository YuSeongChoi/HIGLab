import Network

extension TCPClient {
    func send(_ message: String) {
        guard let data = message.data(using: .utf8) else { return }
        
        connection?.send(
            content: data,
            contentContext: .defaultMessage,
            isComplete: true,
            completion: .contentProcessed { error in
                if let error = error {
                    print("전송 실패: \(error)")
                } else {
                    print("전송 성공: \(message)")
                }
            }
        )
    }
}

// 사용 예시
let client = TCPClient()
client.connect(to: "192.168.1.100", port: 8080)
client.send("안녕하세요!")
