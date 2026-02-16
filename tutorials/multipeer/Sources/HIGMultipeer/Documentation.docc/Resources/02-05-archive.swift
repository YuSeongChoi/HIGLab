import MultipeerConnectivity

class PeerManager {
    
    private static let peerIDKey = "savedPeerID"
    
    // NSKeyedArchiver를 사용한 PeerID 직렬화
    func savePeerID(_ peerID: MCPeerID) throws {
        let data = try NSKeyedArchiver.archivedData(
            withRootObject: peerID,
            requiringSecureCoding: true
        )
        UserDefaults.standard.set(data, forKey: Self.peerIDKey)
    }
    
    // NSKeyedUnarchiver를 사용한 PeerID 복원
    func loadPeerID() throws -> MCPeerID? {
        guard let data = UserDefaults.standard.data(forKey: Self.peerIDKey) else {
            return nil
        }
        
        return try NSKeyedUnarchiver.unarchivedObject(
            ofClass: MCPeerID.self,
            from: data
        )
    }
    
    // PeerID 삭제
    func deletePeerID() {
        UserDefaults.standard.removeObject(forKey: Self.peerIDKey)
    }
}
