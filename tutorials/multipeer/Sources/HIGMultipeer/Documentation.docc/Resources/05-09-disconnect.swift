import MultipeerConnectivity

class SessionManager: NSObject, ObservableObject {
    
    @Published var connectedPeers: [MCPeerID] = []
    
    let session: MCSession
    private let peerID: MCPeerID
    
    // 특정 피어와 연결 해제
    // 참고: MCSession은 개별 피어 연결 해제를 직접 지원하지 않음
    // disconnect()는 모든 피어와의 연결을 해제함
    // 개별 피어 관리가 필요하면 별도 세션을 사용해야 함
    
    func disconnectFromPeer(_ peer: MCPeerID) {
        // 해당 피어에게 연결 해제 메시지 전송
        let disconnectMessage = "DISCONNECT".data(using: .utf8)!
        try? session.send(disconnectMessage, toPeers: [peer], with: .reliable)
        
        // 목록에서 제거 (실제 연결 해제는 상대방이 처리)
        DispatchQueue.main.async {
            self.connectedPeers.removeAll { $0 == peer }
        }
    }
}
