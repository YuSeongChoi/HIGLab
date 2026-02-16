import Network

extension P2PChatServer {
    // 서버 정상 종료
    func shutdown() {
        print("서버 종료 시작...")
        
        // 1. 새 연결 수신 중지
        listener?.newConnectionHandler = nil
        
        // 2. 모든 클라이언트에게 종료 알림
        sendSystemMessage("서버가 종료됩니다")
        
        // 3. 모든 클라이언트 연결 종료
        for client in clients {
            client.send(
                content: "서버 종료".data(using: .utf8),
                contentContext: .finalMessage,
                isComplete: true,
                completion: .contentProcessed { _ in }
            )
            client.cancel()
        }
        clients.removeAll()
        
        // 4. 리스너 취소 (Bonjour 광고도 중지됨)
        listener?.cancel()
        listener = nil
        
        print("서버 종료 완료")
    }
    
    // 앱 종료 시 정리
    deinit {
        shutdown()
    }
}

// 사용 예시
let server = P2PChatServer()
try? server.start(name: "My Chat Room")

// 앱 종료 시
NotificationCenter.default.addObserver(
    forName: UIApplication.willTerminateNotification,
    object: nil,
    queue: .main
) { _ in
    server.shutdown()
}
