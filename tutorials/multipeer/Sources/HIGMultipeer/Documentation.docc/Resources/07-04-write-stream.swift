import MultipeerConnectivity

class StreamManager: NSObject {
    
    let session: MCSession
    private var outputStreams: [MCPeerID: OutputStream] = [:]
    
    // 스트림에 데이터 쓰기
    func write(_ data: Data, to peer: MCPeerID) -> Int {
        guard let stream = outputStreams[peer],
              stream.hasSpaceAvailable else {
            return 0
        }
        
        return data.withUnsafeBytes { buffer in
            guard let pointer = buffer.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                return 0
            }
            return stream.write(pointer, maxLength: data.count)
        }
    }
    
    // 문자열을 스트림에 쓰기
    func write(_ string: String, to peer: MCPeerID) -> Int {
        guard let data = string.data(using: .utf8) else { return 0 }
        return write(data, to: peer)
    }
    
    // 연속적인 데이터 쓰기 (예: 실시간 센서 데이터)
    func streamData(_ data: Data, to peer: MCPeerID) {
        var offset = 0
        let bufferSize = 1024
        
        while offset < data.count {
            let chunk = data.subdata(in: offset..<min(offset + bufferSize, data.count))
            let written = write(chunk, to: peer)
            if written <= 0 { break }
            offset += written
        }
    }
}
