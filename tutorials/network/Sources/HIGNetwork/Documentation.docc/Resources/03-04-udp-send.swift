import Network

extension UDPClient {
    func send(_ message: String) {
        guard let data = message.data(using: .utf8) else { return }
        
        // 각 send는 하나의 독립적인 데이터그램
        connection?.send(
            content: data,
            contentContext: .defaultMessage,
            isComplete: true,
            completion: .contentProcessed { error in
                if let error = error {
                    // UDP 전송 실패는 드묾
                    // 주로 버퍼 오버플로우나 네트워크 문제
                    print("전송 실패: \(error)")
                } else {
                    // 전송 성공 != 수신 성공
                    // UDP는 도착을 보장하지 않음
                    print("데이터그램 전송됨")
                }
            }
        )
    }
}
