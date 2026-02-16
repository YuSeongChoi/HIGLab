import Network
import Security

class SecureChatClient: ObservableObject {
    private var connection: NWConnection?
    private let queue = DispatchQueue(label: "secure.chat.queue")
    
    @Published var isConnected = false
    @Published var messages: [String] = []
    
    func connect(to host: String, port: UInt16 = 443) {
        let parameters = createTLSParameters()
        
        let endpoint = NWEndpoint.hostPort(
            host: NWEndpoint.Host(host),
            port: NWEndpoint.Port(integerLiteral: port)
        )
        
        connection = NWConnection(to: endpoint, using: parameters)
        
        connection?.stateUpdateHandler = { [weak self] state in
            DispatchQueue.main.async {
                self?.isConnected = (state == .ready)
            }
            
            if case .ready = state {
                self?.startReceiving()
            }
        }
        
        connection?.start(queue: queue)
    }
    
    private func createTLSParameters() -> NWParameters {
        let tlsOptions = NWProtocolTLS.Options()
        
        // TLS 1.2 이상 강제
        sec_protocol_options_set_min_tls_protocol_version(
            tlsOptions.securityProtocolOptions,
            .TLSv12
        )
        
        let tcpOptions = NWProtocolTCP.Options()
        tcpOptions.enableKeepalive = true
        
        return NWParameters(tls: tlsOptions, tcp: tcpOptions)
    }
    
    func send(_ message: String) {
        guard let data = message.data(using: .utf8) else { return }
        
        connection?.send(
            content: data,
            contentContext: .defaultMessage,
            isComplete: true,
            completion: .contentProcessed { _ in }
        )
    }
    
    private func startReceiving() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, _ in
            if let data = data, let message = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self?.messages.append(message)
                }
            }
            if !isComplete {
                self?.startReceiving()
            }
        }
    }
}
