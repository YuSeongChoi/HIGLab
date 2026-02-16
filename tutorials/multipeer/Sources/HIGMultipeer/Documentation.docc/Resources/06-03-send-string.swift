import MultipeerConnectivity

class DataManager {
    
    let session: MCSession
    
    // 문자열 전송
    func send(_ message: String, to peers: [MCPeerID]) throws {
        guard let data = message.data(using: .utf8) else {
            throw DataError.encodingFailed
        }
        try session.send(data, toPeers: peers, with: .reliable)
    }
    
    // 연결된 모든 피어에게 문자열 전송
    func broadcast(_ message: String) throws {
        try send(message, to: session.connectedPeers)
    }
}
