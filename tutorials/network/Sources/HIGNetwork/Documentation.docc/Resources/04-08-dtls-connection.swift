import Network
import Security

class SecureUDPClient {
    private var connection: NWConnection?
    private let queue = DispatchQueue(label: "secure.udp.queue")
    
    func connect(to host: String, port: UInt16) {
        let endpoint = NWEndpoint.hostPort(
            host: NWEndpoint.Host(host),
            port: NWEndpoint.Port(integerLiteral: port)
        )
        
        // DTLS 옵션 설정
        let dtlsOptions = NWProtocolTLS.Options()
        
        // DTLS 버전 설정
        sec_protocol_options_set_min_tls_protocol_version(
            dtlsOptions.securityProtocolOptions,
            .DTLSv12
        )
        
        // UDP 옵션
        let udpOptions = NWProtocolUDP.Options()
        
        // DTLS + UDP 파라미터
        let parameters = NWParameters(dtls: dtlsOptions, udp: udpOptions)
        
        connection = NWConnection(to: endpoint, using: parameters)
        
        connection?.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("DTLS 연결 완료 - 암호화된 UDP 통신 가능")
            case .failed(let error):
                print("DTLS 연결 실패: \(error)")
            default:
                break
            }
        }
        
        connection?.start(queue: queue)
    }
}
