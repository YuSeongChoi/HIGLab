import Network
import Combine

class ChatClient: ObservableObject {
    private var connection: NWConnection?
    private let queue = DispatchQueue(label: "chat.client.queue")
    
    @Published var isConnected = false
    @Published var messages: [String] = []
    @Published var errorMessage: String?
    
    func connect(to host: String, port: UInt16) {
        let endpoint = NWEndpoint.hostPort(
            host: NWEndpoint.Host(host),
            port: NWEndpoint.Port(integerLiteral: port)
        )
        
        connection = NWConnection(to: endpoint, using: .tcp)
        
        connection?.stateUpdateHandler = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .ready:
                    self?.isConnected = true
                    self?.errorMessage = nil
                case .failed(let error):
                    self?.isConnected = false
                    self?.errorMessage = error.localizedDescription
                case .cancelled:
                    self?.isConnected = false
                default:
                    break
                }
            }
            
            if case .ready = state {
                self?.startReceiving()
            }
        }
        
        connection?.start(queue: queue)
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
