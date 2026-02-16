import MultipeerConnectivity

class PeerManager {
    
    private static let peerIDKey = "savedPeerID"
    
    // PeerID를 UserDefaults에 저장
    func savePeerID(_ peerID: MCPeerID) {
        do {
            let data = try NSKeyedArchiver.archivedData(
                withRootObject: peerID,
                requiringSecureCoding: true
            )
            UserDefaults.standard.set(data, forKey: Self.peerIDKey)
        } catch {
            print("PeerID 저장 실패: \(error)")
        }
    }
}
