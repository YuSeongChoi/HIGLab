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
        
        connection?.stateUpdateHandler = { [weak self] state in
            self?.handleStateChange(state)
        }
    }
    
    private func handleStateChange(_ state: NWConnection.State) {
        switch state {
        case .ready:
            print("TCP 연결 완료")
        case .failed(let error):
            print("연결 실패: \(error)")
        case .cancelled:
            print("연결 취소됨")
        default:
            break
        }
    }
}
