import Network

extension TCPClient {
    private func processData(_ data: Data) {
        // Data를 UTF-8 문자열로 변환
        guard let message = String(data: data, encoding: .utf8) else {
            print("UTF-8 디코딩 실패")
            return
        }
        
        print("수신 메시지: \(message)")
        
        // 메인 스레드에서 UI 업데이트
        DispatchQueue.main.async {
            self.onMessageReceived?(message)
        }
    }
    
    var onMessageReceived: ((String) -> Void)?
}

// 사용 예시
let client = TCPClient()
client.onMessageReceived = { message in
    print("새 메시지: \(message)")
    // UI 업데이트
}
