import Network

extension ChatServer {
    func setupNewConnectionHandler() {
        listener?.newConnectionHandler = { [weak self] connection in
            print("새 연결: \(connection.endpoint)")
            
            // 연결 상태 핸들러
            connection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    print("클라이언트 연결됨: \(connection.endpoint)")
                    self?.handleClient(connection)
                    
                case .failed(let error):
                    print("클라이언트 연결 실패: \(error)")
                    
                case .cancelled:
                    print("클라이언트 연결 종료: \(connection.endpoint)")
                    self?.removeClient(connection)
                    
                default:
                    break
                }
            }
            
            // 연결 시작
            connection.start(queue: self?.queue ?? .main)
        }
    }
    
    private func handleClient(_ connection: NWConnection) {
        // 클라이언트 처리
    }
    
    private func removeClient(_ connection: NWConnection) {
        // 클라이언트 제거
    }
}
