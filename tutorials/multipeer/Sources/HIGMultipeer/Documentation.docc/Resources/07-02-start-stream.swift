import MultipeerConnectivity

class StreamManager: NSObject {
    
    let session: MCSession
    private var outputStreams: [MCPeerID: OutputStream] = [:]
    
    init(session: MCSession) {
        self.session = session
        super.init()
    }
    
    // 스트림 시작
    func startStream(to peer: MCPeerID, named name: String) throws {
        let outputStream = try session.startStream(withName: name, toPeer: peer)
        
        // 스트림 저장
        outputStreams[peer] = outputStream
        
        // 스트림 설정 및 시작
        setupOutputStream(outputStream)
    }
    
    private func setupOutputStream(_ stream: OutputStream) {
        // 다음 단계에서 구현
    }
}
