import Network
import Foundation

class SecureGameClient {
    private var connection: NWConnection?
    private let queue = DispatchQueue(label: "secure.game.queue")
    
    func connect(to host: String, port: UInt16) {
        let parameters = createDTLSParameters()
        
        let endpoint = NWEndpoint.hostPort(
            host: NWEndpoint.Host(host),
            port: NWEndpoint.Port(integerLiteral: port)
        )
        
        connection = NWConnection(to: endpoint, using: parameters)
        connection?.start(queue: queue)
    }
    
    // 암호화된 게임 데이터 전송
    func sendGameState(_ state: PlayerState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        
        // DTLS가 자동으로 암호화
        connection?.send(
            content: data,
            contentContext: .defaultMessage,
            isComplete: true,
            completion: .idempotent
        )
    }
    
    // 암호화된 데이터 수신
    func startReceiving(handler: @escaping (PlayerState) -> Void) {
        connection?.receiveMessage { [weak self] data, _, _, error in
            if let data = data,
               let state = try? JSONDecoder().decode(PlayerState.self, from: data) {
                handler(state)
            }
            self?.startReceiving(handler: handler)
        }
    }
    
    private func createDTLSParameters() -> NWParameters {
        let dtlsOptions = NWProtocolTLS.Options()
        sec_protocol_options_set_min_tls_protocol_version(
            dtlsOptions.securityProtocolOptions,
            .DTLSv12
        )
        return NWParameters(dtls: dtlsOptions, udp: NWProtocolUDP.Options())
    }
}
