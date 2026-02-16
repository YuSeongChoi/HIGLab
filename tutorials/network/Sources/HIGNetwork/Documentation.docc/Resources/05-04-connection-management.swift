import Network

class ChatServer {
    private var listener: NWListener?
    private var clients: [NWConnection] = []
    private let queue = DispatchQueue(label: "chat.server.queue")
    private let clientsLock = NSLock()
    
    var clientCount: Int {
        clientsLock.lock()
        defer { clientsLock.unlock() }
        return clients.count
    }
    
    private func addClient(_ connection: NWConnection) {
        clientsLock.lock()
        clients.append(connection)
        clientsLock.unlock()
        
        print("클라이언트 추가됨. 현재 \(clientCount)명")
    }
    
    private func removeClient(_ connection: NWConnection) {
        clientsLock.lock()
        clients.removeAll { $0 === connection }
        clientsLock.unlock()
        
        print("클라이언트 제거됨. 현재 \(clientCount)명")
    }
    
    // 모든 클라이언트 순회
    private func forEachClient(_ action: (NWConnection) -> Void) {
        clientsLock.lock()
        let currentClients = clients
        clientsLock.unlock()
        
        for client in currentClients {
            action(client)
        }
    }
}
