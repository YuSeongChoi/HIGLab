import MultipeerConnectivity

class DataManager {
    
    let session: MCSession
    private let encoder = JSONEncoder()
    
    // 메시지 객체 전송
    func send(_ message: Message, to peers: [MCPeerID]) throws {
        let data = try encoder.encode(message)
        try session.send(data, toPeers: peers, with: .reliable)
    }
    
    // 텍스트 메시지 전송 헬퍼
    func sendText(_ text: String, to peers: [MCPeerID]) throws {
        let message = Message(type: .text, content: text)
        try send(message, to: peers)
    }
    
    // 이모지 전송
    func sendEmoji(_ emoji: String) throws {
        let message = Message(type: .emoji, content: emoji)
        try send(message, to: session.connectedPeers)
    }
}
