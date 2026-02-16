import MultipeerConnectivity

class DrawingStreamManager: NSObject {
    
    let session: MCSession
    private var outputStreams: [MCPeerID: OutputStream] = [:]
    private let encoder = JSONEncoder()
    
    init(session: MCSession) {
        self.session = session
        super.init()
    }
    
    // 드로잉 스트림 시작
    func startDrawingStream(to peer: MCPeerID) throws {
        let stream = try session.startStream(withName: "drawing", toPeer: peer)
        stream.delegate = self
        stream.schedule(in: .main, forMode: .default)
        stream.open()
        outputStreams[peer] = stream
    }
    
    // 드로잉 포인트 전송
    func sendDrawingPoint(_ point: DrawingPoint) {
        guard let data = try? encoder.encode(point) else { return }
        
        // 길이 프리픽스 추가 (4바이트)
        var length = UInt32(data.count).bigEndian
        let lengthData = Data(bytes: &length, count: 4)
        
        let packet = lengthData + data
        
        for (_, stream) in outputStreams where stream.hasSpaceAvailable {
            packet.withUnsafeBytes { buffer in
                if let pointer = buffer.baseAddress?.assumingMemoryBound(to: UInt8.self) {
                    stream.write(pointer, maxLength: packet.count)
                }
            }
        }
    }
}

extension DrawingStreamManager: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        // 이벤트 처리
    }
}
