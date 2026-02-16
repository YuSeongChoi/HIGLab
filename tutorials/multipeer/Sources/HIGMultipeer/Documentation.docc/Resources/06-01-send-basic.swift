import MultipeerConnectivity

class DataManager {
    
    let session: MCSession
    
    init(session: MCSession) {
        self.session = session
    }
    
    // 기본 데이터 전송
    func send(_ data: Data, to peers: [MCPeerID]) throws {
        try session.send(data, toPeers: peers, with: .reliable)
    }
    
    // 연결된 모든 피어에게 전송
    func sendToAll(_ data: Data) throws {
        guard !session.connectedPeers.isEmpty else {
            throw DataError.noPeersConnected
        }
        try session.send(data, toPeers: session.connectedPeers, with: .reliable)
    }
}

enum DataError: Error {
    case noPeersConnected
    case encodingFailed
}
