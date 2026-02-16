import MultipeerConnectivity

class SessionManager: NSObject, MCSessionDelegate {
    
    // 피어 연결 상태 변화
    func session(
        _ session: MCSession,
        peer peerID: MCPeerID,
        didChange state: MCSessionState
    ) {
        // 구현 필요
    }
    
    // 데이터 수신
    func session(
        _ session: MCSession,
        didReceive data: Data,
        fromPeer peerID: MCPeerID
    ) {
        // 구현 필요
    }
    
    // 스트림 수신
    func session(
        _ session: MCSession,
        didReceive stream: InputStream,
        withName streamName: String,
        fromPeer peerID: MCPeerID
    ) {
        // 구현 필요
    }
    
    // 리소스 수신 시작
    func session(
        _ session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        with progress: Progress
    ) {
        // 구현 필요
    }
    
    // 리소스 수신 완료
    func session(
        _ session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        at localURL: URL?,
        withError error: Error?
    ) {
        // 구현 필요
    }
}
