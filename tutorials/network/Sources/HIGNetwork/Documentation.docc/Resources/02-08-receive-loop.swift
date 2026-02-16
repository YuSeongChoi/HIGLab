import Network

class TCPClient {
    private var connection: NWConnection?
    private var isReceiving = false
    
    func startReceiving() {
        guard !isReceiving else { return }
        isReceiving = true
        receiveLoop()
    }
    
    private func receiveLoop() {
        connection?.receive(
            minimumIncompleteLength: 1,
            maximumLength: 65536
        ) { [weak self] data, context, isComplete, error in
            guard let self = self else { return }
            
            if let error = error {
                self.isReceiving = false
                print("수신 오류: \(error)")
                return
            }
            
            if let data = data, !data.isEmpty {
                self.processData(data)
            }
            
            if isComplete {
                self.isReceiving = false
                print("연결 종료됨")
            } else if self.isReceiving {
                // 재귀적으로 다음 데이터 대기
                self.receiveLoop()
            }
        }
    }
    
    func stopReceiving() {
        isReceiving = false
    }
    
    private func processData(_ data: Data) {
        // 데이터 처리
    }
}
