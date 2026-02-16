import Network

extension P2PChatServer {
    func handleClientDisconnect(_ connection: NWConnection) {
        // 1. 클라이언트 목록에서 제거
        clients.removeAll { $0 === connection }
        
        // 2. 연결 리소스 정리
        connection.cancel()
        
        // 3. 다른 클라이언트에게 알림
        let clientId = connection.endpoint.debugDescription
        sendSystemMessage("\(clientId)님이 퇴장했습니다")
        
        // 4. 콜백 호출
        DispatchQueue.main.async { [weak self] in
            self?.onClientDisconnected?(clientId)
        }
        
        print("클라이언트 연결 해제: \(clientId). 현재 \(clients.count)명")
    }
    
    // 특정 클라이언트 강제 연결 해제
    func kickClient(_ connection: NWConnection, reason: String) {
        // 사유 전송
        if let data = "[시스템] 연결 해제: \(reason)".data(using: .utf8) {
            connection.send(
                content: data,
                contentContext: .finalMessage,
                isComplete: true,
                completion: .contentProcessed { _ in
                    connection.cancel()
                }
            )
        }
        
        handleClientDisconnect(connection)
    }
}
