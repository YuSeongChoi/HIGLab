import MultipeerConnectivity

class SessionManager: NSObject, ObservableObject {
    
    @Published var connectedPeers: [MCPeerID] = []
    
    let session: MCSession
    private let peerID: MCPeerID
    
    init(peerID: MCPeerID) {
        self.peerID = peerID
        self.session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        super.init()
        session.delegate = self
    }
}

extension SessionManager: MCSessionDelegate {
    
    func session(
        _ session: MCSession,
        peer peerID: MCPeerID,
        didChange state: MCSessionState
    ) {
        // UI 업데이트는 메인 스레드에서
        DispatchQueue.main.async {
            switch state {
            case .notConnected:
                print("\(peerID.displayName) 연결 해제됨")
                self.connectedPeers.removeAll { $0 == peerID }
                
            case .connecting:
                print("\(peerID.displayName) 연결 중...")
                
            case .connected:
                print("\(peerID.displayName) 연결됨")
                if !self.connectedPeers.contains(peerID) {
                    self.connectedPeers.append(peerID)
                }
                
            @unknown default:
                break
            }
        }
    }
    
    // 나머지 델리게이트 메서드들...
}
