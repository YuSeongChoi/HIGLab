import MultipeerConnectivity

class SessionManager: NSObject, ObservableObject {
    
    @Published var connectedPeers: [MCPeerID] = []
    @Published var peerStates: [MCPeerID: MCSessionState] = [:]
    
    let session: MCSession
    private let peerID: MCPeerID
    
    init(peerID: MCPeerID) {
        self.peerID = peerID
        self.session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        super.init()
        session.delegate = self
    }
    
    // 현재 연결된 피어 수
    var connectedPeerCount: Int {
        session.connectedPeers.count
    }
    
    // 특정 피어가 연결되어 있는지 확인
    func isConnected(to peer: MCPeerID) -> Bool {
        session.connectedPeers.contains(peer)
    }
    
    // 피어 상태 확인
    func state(of peer: MCPeerID) -> MCSessionState {
        peerStates[peer] ?? .notConnected
    }
}
