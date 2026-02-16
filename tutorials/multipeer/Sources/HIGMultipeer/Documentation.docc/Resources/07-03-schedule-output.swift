import MultipeerConnectivity

class StreamManager: NSObject, StreamDelegate {
    
    let session: MCSession
    private var outputStreams: [MCPeerID: OutputStream] = [:]
    
    // OutputStream 설정
    private func setupOutputStream(_ stream: OutputStream) {
        stream.delegate = self
        
        // RunLoop에 스케줄링 (비동기 처리를 위해)
        stream.schedule(in: .current, forMode: .default)
        
        // 스트림 열기
        stream.open()
    }
    
    // StreamDelegate
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .openCompleted:
            print("스트림 열림")
        case .hasSpaceAvailable:
            print("쓰기 가능")
        case .errorOccurred:
            print("스트림 오류: \(aStream.streamError?.localizedDescription ?? "알 수 없음")")
        case .endEncountered:
            print("스트림 종료")
        default:
            break
        }
    }
}
