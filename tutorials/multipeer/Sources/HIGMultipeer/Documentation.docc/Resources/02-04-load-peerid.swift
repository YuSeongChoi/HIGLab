import MultipeerConnectivity

class PeerManager {
    
    private static let peerIDKey = "savedPeerID"
    
    // 저장된 PeerID 불러오기 또는 새로 생성
    func loadOrCreatePeerID() -> MCPeerID {
        if let data = UserDefaults.standard.data(forKey: Self.peerIDKey),
           let peerID = try? NSKeyedUnarchiver.unarchivedObject(
               ofClass: MCPeerID.self,
               from: data
           ) {
            return peerID
        }
        
        // 저장된 PeerID가 없으면 새로 생성
        let newPeerID = MCPeerID(displayName: UIDevice.current.name)
        savePeerID(newPeerID)
        return newPeerID
    }
    
    func savePeerID(_ peerID: MCPeerID) {
        // 이전 코드와 동일
    }
}
