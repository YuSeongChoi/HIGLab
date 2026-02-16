import MultipeerConnectivity

class StreamManager: NSObject {
    
    private var inputStreams: [MCPeerID: InputStream] = [:]
    private var outputStreams: [MCPeerID: OutputStream] = [:]
    
    // InputStream 정리
    private func closeInputStream(_ stream: InputStream) {
        stream.close()
        stream.remove(from: .main, forMode: .default)
        stream.delegate = nil
        
        // 딕셔너리에서 제거
        if let peer = inputStreams.first(where: { $0.value === stream })?.key {
            inputStreams.removeValue(forKey: peer)
        }
    }
    
    // 특정 피어의 모든 스트림 정리
    func closeStreams(for peer: MCPeerID) {
        if let input = inputStreams[peer] {
            closeInputStream(input)
        }
        if let output = outputStreams[peer] {
            output.close()
            output.remove(from: .current, forMode: .default)
            output.delegate = nil
            outputStreams.removeValue(forKey: peer)
        }
    }
    
    // 전체 정리
    func cleanup() {
        for (peer, _) in inputStreams {
            closeStreams(for: peer)
        }
        for (peer, _) in outputStreams {
            closeStreams(for: peer)
        }
    }
    
    deinit {
        cleanup()
    }
}
