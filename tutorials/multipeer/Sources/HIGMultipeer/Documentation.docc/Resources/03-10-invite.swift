import MultipeerConnectivity

class BrowserManager: NSObject, ObservableObject {
    
    @Published var availablePeers: [MCPeerID] = []
    @Published var isBrowsing = false
    
    private var browser: MCNearbyServiceBrowser?
    private let peerID: MCPeerID
    private let serviceType = "fileshare"
    
    // 피어에게 연결 초대 보내기
    func invitePeer(_ peer: MCPeerID, to session: MCSession) {
        // context: 초대와 함께 보낼 추가 데이터 (선택적)
        let context = "Hello from \(peerID.displayName)".data(using: .utf8)
        
        // timeout: 응답 대기 시간 (초)
        browser?.invitePeer(
            peer,
            to: session,
            withContext: context,
            timeout: 30
        )
    }
    
    // 여러 피어에게 초대 보내기
    func inviteAllPeers(to session: MCSession) {
        for peer in availablePeers {
            invitePeer(peer, to: session)
        }
    }
}
