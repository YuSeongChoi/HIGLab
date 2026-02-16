import Network
import Foundation

class ChatClient {
    private var connection: NWConnection?
    private let queue = DispatchQueue(label: "chat.client.queue")
    
    var onConnected: (() -> Void)?
    var onDisconnected: (() -> Void)?
    var onMessageReceived: ((String) -> Void)?
    var onError: ((Error) -> Void)?
    
    func connect(to host: String, port: UInt16) {
        let endpoint = NWEndpoint.hostPort(
            host: NWEndpoint.Host(host),
            port: NWEndpoint.Port(integerLiteral: port)
        )
        
        connection = NWConnection(to: endpoint, using: .tcp)
        
        connection?.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                DispatchQueue.main.async {
                    self?.onConnected?()
                }
                self?.startReceiving()
            case .failed(let error):
                DispatchQueue.main.async {
                    self?.onError?(error)
                }
            case .cancelled:
                DispatchQueue.main.async {
                    self?.onDisconnected?()
                }
            default:
                break
            }
        }
        
        connection?.start(queue: queue)
    }
    
    func send(_ message: String) {
        guard let data = message.data(using: .utf8) else { return }
        
        connection?.send(
            content: data,
            contentContext: .defaultMessage,
            isComplete: true,
            completion: .contentProcessed { [weak self] error in
                if let error = error {
                    DispatchQueue.main.async {
                        self?.onError?(error)
                    }
                }
            }
        )
    }
    
    private func startReceiving() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            if let data = data, let message = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self?.onMessageReceived?(message)
                }
            }
            
            if !isComplete && error == nil {
                self?.startReceiving()
            }
        }
    }
    
    func disconnect() {
        connection?.cancel()
    }
}
