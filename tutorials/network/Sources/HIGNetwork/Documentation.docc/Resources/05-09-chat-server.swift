import Network
import Foundation

class P2PChatServer {
    private var listener: NWListener?
    private var clients: [NWConnection] = []
    private let queue = DispatchQueue(label: "p2p.server.queue")
    
    var onClientConnected: ((String) -> Void)?
    var onClientDisconnected: ((String) -> Void)?
    var onMessageReceived: ((String, String) -> Void)?  // (clientId, message)
    
    func start(name: String) throws {
        let parameters = NWParameters.tcp
        
        listener = try NWListener(using: parameters)
        listener?.service = NWListener.Service(name: name, type: "_p2pchat._tcp")
        
        listener?.stateUpdateHandler = { [weak self] state in
            if case .ready = state, let port = self?.listener?.port {
                print("서버 시작: 포트 \(port)")
            }
        }
        
        listener?.newConnectionHandler = { [weak self] connection in
            self?.handleNewConnection(connection)
        }
        
        listener?.start(queue: queue)
    }
    
    private func handleNewConnection(_ connection: NWConnection) {
        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                self?.clients.append(connection)
                self?.onClientConnected?(connection.endpoint.debugDescription)
                self?.startReceiving(from: connection)
                
            case .failed, .cancelled:
                self?.removeClient(connection)
                self?.onClientDisconnected?(connection.endpoint.debugDescription)
                
            default:
                break
            }
        }
        
        connection.start(queue: queue)
    }
    
    private func removeClient(_ connection: NWConnection) {
        clients.removeAll { $0 === connection }
    }
    
    private func startReceiving(from connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, _ in
            if let data = data, let message = String(data: data, encoding: .utf8) {
                self?.onMessageReceived?(connection.endpoint.debugDescription, message)
                self?.broadcast(message, except: connection)
            }
            
            if !isComplete {
                self?.startReceiving(from: connection)
            }
        }
    }
    
    func broadcast(_ message: String, except sender: NWConnection? = nil) {
        guard let data = message.data(using: .utf8) else { return }
        
        for client in clients where client !== sender {
            client.send(content: data, contentContext: .defaultMessage, isComplete: true, completion: .contentProcessed { _ in })
        }
    }
    
    func stop() {
        for client in clients {
            client.cancel()
        }
        clients.removeAll()
        listener?.cancel()
    }
}
