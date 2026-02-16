import MultipeerConnectivity

class StreamManager: NSObject, StreamDelegate {
    
    let session: MCSession
    private var outputStreams: [MCPeerID: OutputStream] = [:]
    private var pendingData: [MCPeerID: Data] = [:]
    
    // StreamDelegate - 이벤트 처리
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        guard let outputStream = aStream as? OutputStream else { return }
        
        switch eventCode {
        case .openCompleted:
            print("OutputStream 열림")
            
        case .hasSpaceAvailable:
            // 대기 중인 데이터가 있으면 전송
            if let peer = findPeer(for: outputStream),
               let data = pendingData[peer], !data.isEmpty {
                let written = write(data, to: peer)
                if written > 0 {
                    pendingData[peer] = data.dropFirst(written).data
                }
            }
            
        case .errorOccurred:
            if let error = outputStream.streamError {
                print("스트림 오류: \(error)")
            }
            closeStream(outputStream)
            
        case .endEncountered:
            print("스트림 종료됨")
            closeStream(outputStream)
            
        default:
            break
        }
    }
    
    private func findPeer(for stream: OutputStream) -> MCPeerID? {
        outputStreams.first { $0.value === stream }?.key
    }
    
    private func closeStream(_ stream: OutputStream) {
        stream.close()
        stream.remove(from: .current, forMode: .default)
    }
}

extension Data.SubSequence {
    var data: Data { Data(self) }
}
