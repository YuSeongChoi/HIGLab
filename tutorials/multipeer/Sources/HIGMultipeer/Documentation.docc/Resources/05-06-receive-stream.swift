import MultipeerConnectivity

extension SessionManager: MCSessionDelegate {
    
    func session(
        _ session: MCSession,
        didReceive stream: InputStream,
        withName streamName: String,
        fromPeer peerID: MCPeerID
    ) {
        print("\(peerID.displayName)로부터 스트림 수신: \(streamName)")
        
        // 스트림 처리는 별도 메서드에서
        handleIncomingStream(stream, named: streamName, from: peerID)
    }
    
    private func handleIncomingStream(
        _ stream: InputStream,
        named name: String,
        from peer: MCPeerID
    ) {
        // 스트림 처리 로직 (7장에서 자세히)
        stream.delegate = self
        stream.schedule(in: .main, forMode: .default)
        stream.open()
    }
    
    // ... 다른 델리게이트 메서드들
}
