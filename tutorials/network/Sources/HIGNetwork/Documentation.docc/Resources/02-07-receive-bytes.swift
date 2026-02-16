import Network

extension TCPClient {
    func startReceiving() {
        // 최소 1바이트, 최대 65536바이트 수신
        connection?.receive(
            minimumIncompleteLength: 1,
            maximumLength: 65536
        ) { [weak self] data, context, isComplete, error in
            if let error = error {
                print("수신 오류: \(error)")
                return
            }
            
            if let data = data, !data.isEmpty {
                self?.handleReceivedData(data)
            }
            
            if isComplete {
                print("상대방이 연결을 종료했습니다")
            } else {
                // 계속 수신 대기
                self?.startReceiving()
            }
        }
    }
    
    private func handleReceivedData(_ data: Data) {
        print("수신: \(data.count) 바이트")
    }
}
