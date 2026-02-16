import Network

class UDPClient {
    private var connection: NWConnection?
    private let queue = DispatchQueue(label: "udp.client.queue")
    var onDataReceived: ((Data) -> Void)?
    
    func startReceiving() {
        receiveLoop()
    }
    
    private func receiveLoop() {
        connection?.receiveMessage { [weak self] data, context, isComplete, error in
            guard let self = self else { return }
            
            if let error = error {
                print("수신 오류: \(error)")
                return
            }
            
            if let data = data {
                DispatchQueue.main.async {
                    self.onDataReceived?(data)
                }
            }
            
            // UDP는 isComplete가 항상 true (각 데이터그램이 완결)
            // 계속 수신하려면 다시 호출
            self.receiveLoop()
        }
    }
    
    func stopReceiving() {
        connection?.cancel()
    }
}
