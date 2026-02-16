import Network

extension TCPClient {
    // 일반 메시지 전송
    func sendMessage(_ data: Data) {
        connection?.send(
            content: data,
            contentContext: .defaultMessage,  // 일반 메시지
            isComplete: true,
            completion: .contentProcessed { _ in }
        )
    }
    
    // 마지막 메시지 전송 후 연결 종료
    func sendFinalMessage(_ data: Data) {
        connection?.send(
            content: data,
            contentContext: .finalMessage,  // 연결 종료 신호
            isComplete: true,
            completion: .contentProcessed { _ in }
        )
    }
    
    // 우선순위가 높은 메시지
    func sendExpedited(_ data: Data) {
        let context = NWConnection.ContentContext(
            identifier: "expedited",
            expiration: 5000,  // 5초 내 전송 실패 시 만료
            priority: 1.0,     // 최고 우선순위
            isFinal: false
        )
        
        connection?.send(
            content: data,
            contentContext: context,
            isComplete: true,
            completion: .contentProcessed { _ in }
        )
    }
}
