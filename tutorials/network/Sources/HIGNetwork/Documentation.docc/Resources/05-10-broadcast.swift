import Network

extension P2PChatServer {
    // 모든 클라이언트에게 브로드캐스트
    func broadcastToAll(_ message: String) {
        guard let data = message.data(using: .utf8) else { return }
        
        for client in clients {
            sendToClient(client, data: data)
        }
    }
    
    // 발신자를 제외하고 브로드캐스트
    func broadcastExcept(_ message: String, sender: NWConnection) {
        guard let data = message.data(using: .utf8) else { return }
        
        for client in clients where client !== sender {
            sendToClient(client, data: data)
        }
    }
    
    private func sendToClient(_ client: NWConnection, data: Data) {
        client.send(
            content: data,
            contentContext: .defaultMessage,
            isComplete: true,
            completion: .contentProcessed { error in
                if let error = error {
                    print("전송 실패 [\(client.endpoint)]: \(error)")
                    // 실패한 클라이언트 연결 정리
                    client.cancel()
                }
            }
        )
    }
    
    // 시스템 메시지 전송 (예: 입장/퇴장 알림)
    func sendSystemMessage(_ message: String) {
        let formatted = "[시스템] \(message)"
        broadcastToAll(formatted)
    }
}
