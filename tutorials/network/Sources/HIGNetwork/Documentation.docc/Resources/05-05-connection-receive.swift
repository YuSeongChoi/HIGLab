import Network

extension ChatServer {
    func startReceiving(from connection: NWConnection) {
        connection.receive(
            minimumIncompleteLength: 1,
            maximumLength: 65536
        ) { [weak self] data, _, isComplete, error in
            if let error = error {
                print("수신 오류: \(error)")
                return
            }
            
            if let data = data, !data.isEmpty {
                self?.handleMessage(data, from: connection)
            }
            
            if isComplete {
                // 클라이언트가 연결을 종료함
                print("클라이언트 연결 종료: \(connection.endpoint)")
                connection.cancel()
            } else {
                // 계속 수신
                self?.startReceiving(from: connection)
            }
        }
    }
    
    private func handleMessage(_ data: Data, from sender: NWConnection) {
        guard let message = String(data: data, encoding: .utf8) else { return }
        
        print("[\(sender.endpoint)] \(message)")
        
        // 다른 클라이언트에게 브로드캐스트
        broadcast(message, except: sender)
    }
    
    private func broadcast(_ message: String, except sender: NWConnection) {
        // 다음 스텝에서 구현
    }
}
