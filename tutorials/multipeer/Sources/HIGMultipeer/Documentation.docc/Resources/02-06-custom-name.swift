import MultipeerConnectivity

class PeerManager: ObservableObject {
    
    @Published var displayName: String
    private(set) var peerID: MCPeerID
    
    init(displayName: String? = nil) {
        let name = displayName ?? UIDevice.current.name
        self.displayName = name
        self.peerID = MCPeerID(displayName: name)
    }
    
    // 사용자 정의 이름으로 PeerID 생성
    func createPeerID(with customName: String) -> MCPeerID {
        let validName = customName.isEmpty ? "Unknown" : customName
        return MCPeerID(displayName: validName)
    }
}
