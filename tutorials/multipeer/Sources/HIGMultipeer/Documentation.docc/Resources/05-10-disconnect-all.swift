import MultipeerConnectivity

class SessionManager: NSObject, ObservableObject {
    
    @Published var connectedPeers: [MCPeerID] = []
    
    let session: MCSession
    private let peerID: MCPeerID
    
    // 모든 피어와 연결 해제
    func disconnectAll() {
        session.disconnect()
        
        DispatchQueue.main.async {
            self.connectedPeers.removeAll()
        }
    }
    
    // 세션 재설정 (새 연결을 위해)
    func resetSession() -> MCSession {
        disconnectAll()
        
        let newSession = MCSession(
            peer: peerID,
            securityIdentity: nil,
            encryptionPreference: .required
        )
        newSession.delegate = self
        
        return newSession
    }
    
    deinit {
        disconnectAll()
    }
}
