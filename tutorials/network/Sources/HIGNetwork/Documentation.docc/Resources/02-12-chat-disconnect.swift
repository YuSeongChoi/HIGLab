import Network

extension ChatClient {
    func disconnect() {
        // 연결 취소
        connection?.cancel()
        connection = nil
        
        DispatchQueue.main.async {
            self.isConnected = false
        }
    }
    
    // Graceful shutdown: 마지막 메시지 전송 후 종료
    func disconnectGracefully(farewell: String = "연결을 종료합니다") {
        guard let data = farewell.data(using: .utf8) else {
            disconnect()
            return
        }
        
        connection?.send(
            content: data,
            contentContext: .finalMessage,  // 연결 종료 신호
            isComplete: true,
            completion: .contentProcessed { [weak self] _ in
                self?.connection?.cancel()
                self?.connection = nil
                
                DispatchQueue.main.async {
                    self?.isConnected = false
                }
            }
        )
    }
    
    deinit {
        disconnect()
    }
}
