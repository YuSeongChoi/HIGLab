import MultipeerConnectivity

extension StreamManager: MCSessionDelegate {
    
    func session(
        _ session: MCSession,
        didReceive stream: InputStream,
        withName streamName: String,
        fromPeer peerID: MCPeerID
    ) {
        print("\(peerID.displayName)로부터 스트림 '\(streamName)' 수신")
        
        // 스트림 이름으로 데이터 종류 구분
        switch streamName {
        case "audio":
            handleAudioStream(stream, from: peerID)
        case "drawing":
            handleDrawingStream(stream, from: peerID)
        default:
            handleGenericStream(stream, from: peerID)
        }
    }
    
    private func handleAudioStream(_ stream: InputStream, from peer: MCPeerID) {
        // 오디오 스트림 처리
        setupInputStream(stream)
    }
    
    private func handleDrawingStream(_ stream: InputStream, from peer: MCPeerID) {
        // 드로잉 스트림 처리
        setupInputStream(stream)
    }
    
    private func handleGenericStream(_ stream: InputStream, from peer: MCPeerID) {
        setupInputStream(stream)
    }
    
    private func setupInputStream(_ stream: InputStream) {
        stream.delegate = self
        stream.schedule(in: .main, forMode: .default)
        stream.open()
    }
    
    // 다른 필수 델리게이트 메서드들...
}
