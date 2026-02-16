import Network

class TCPClient {
    private var connection: NWConnection?
    private let queue = DispatchQueue(label: "tcp.client.queue")
    
    func connect(to host: String, port: UInt16) {
        let endpoint = NWEndpoint.hostPort(
            host: NWEndpoint.Host(host),
            port: NWEndpoint.Port(integerLiteral: port)
        )
        
        connection = NWConnection(to: endpoint, using: .tcp)
        connection?.stateUpdateHandler = handleStateChange
        
        // 연결 시작 - 모든 콜백은 지정된 큐에서 실행됨
        connection?.start(queue: queue)
    }
    
    private func handleStateChange(_ state: NWConnection.State) {
        switch state {
        case .ready:
            print("연결 성공! 데이터 송수신 준비 완료")
            startReceiving()
        case .failed(let error):
            print("연결 실패: \(error)")
            reconnect()
        default:
            break
        }
    }
    
    private func startReceiving() { /* 수신 시작 */ }
    private func reconnect() { /* 재연결 로직 */ }
}
