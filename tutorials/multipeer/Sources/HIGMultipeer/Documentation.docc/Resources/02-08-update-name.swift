import MultipeerConnectivity

class PeerManager: ObservableObject {
    
    @Published var displayName: String
    private(set) var peerID: MCPeerID
    
    private static let peerIDKey = "savedPeerID"
    private static let displayNameKey = "displayName"
    
    init() {
        // 저장된 이름 불러오기
        if let savedName = UserDefaults.standard.string(forKey: Self.displayNameKey) {
            self.displayName = savedName
        } else {
            self.displayName = UIDevice.current.name
        }
        
        self.peerID = MCPeerID(displayName: displayName)
    }
    
    // 이름 변경 시 새 PeerID 생성 및 저장
    func updateName(_ newName: String) {
        guard !newName.isEmpty else { return }
        
        displayName = newName
        peerID = MCPeerID(displayName: newName)
        
        // 저장
        UserDefaults.standard.set(newName, forKey: Self.displayNameKey)
        try? savePeerID(peerID)
        
        // 세션 재설정이 필요할 수 있음
        NotificationCenter.default.post(name: .peerIDChanged, object: peerID)
    }
    
    private func savePeerID(_ peerID: MCPeerID) throws {
        let data = try NSKeyedArchiver.archivedData(
            withRootObject: peerID,
            requiringSecureCoding: true
        )
        UserDefaults.standard.set(data, forKey: Self.peerIDKey)
    }
}

extension Notification.Name {
    static let peerIDChanged = Notification.Name("peerIDChanged")
}
