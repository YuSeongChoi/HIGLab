import MultipeerConnectivity

class StreamManager: NSObject {
    
    let session: MCSession
    private var outputStreams: [MCPeerID: OutputStream] = [:]
    
    // 특정 피어의 스트림 종료
    func closeStream(to peer: MCPeerID) {
        guard let stream = outputStreams[peer] else { return }
        
        stream.close()
        stream.remove(from: .current, forMode: .default)
        stream.delegate = nil
        
        outputStreams.removeValue(forKey: peer)
    }
    
    // 모든 스트림 종료
    func closeAllStreams() {
        for (peer, _) in outputStreams {
            closeStream(to: peer)
        }
    }
    
    deinit {
        closeAllStreams()
    }
}
