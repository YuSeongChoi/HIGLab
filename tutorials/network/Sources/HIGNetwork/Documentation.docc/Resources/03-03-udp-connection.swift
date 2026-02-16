import Network

class UDPClient {
    private var connection: NWConnection?
    private let queue = DispatchQueue(label: "udp.client.queue")
    
    func connect(to host: String, port: UInt16) {
        let endpoint = NWEndpoint.hostPort(
            host: NWEndpoint.Host(host),
            port: NWEndpoint.Port(integerLiteral: port)
        )
        
        // UDP 파라미터 사용
        connection = NWConnection(to: endpoint, using: .udp)
        
        connection?.stateUpdateHandler = { state in
            switch state {
            case .ready:
                // UDP는 "연결"이 없지만 ready 상태는 전송 가능을 의미
                print("UDP 준비 완료")
            case .failed(let error):
                print("UDP 실패: \(error)")
            default:
                break
            }
        }
        
        connection?.start(queue: queue)
    }
}
