import Network

class SecureTCPClient {
    private var connection: NWConnection?
    private let queue = DispatchQueue(label: "secure.tcp.queue")
    
    func connect(to host: String, port: UInt16 = 443) {
        let endpoint = NWEndpoint.hostPort(
            host: NWEndpoint.Host(host),
            port: NWEndpoint.Port(integerLiteral: port)
        )
        
        // TLS가 적용된 TCP 연결
        connection = NWConnection(to: endpoint, using: .tls)
        
        connection?.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("TLS 연결 완료 - 암호화된 통신 가능")
            case .failed(let error):
                print("TLS 연결 실패: \(error)")
                // TLS 핸드셰이크 실패, 인증서 문제 등
            default:
                break
            }
        }
        
        connection?.start(queue: queue)
    }
}
