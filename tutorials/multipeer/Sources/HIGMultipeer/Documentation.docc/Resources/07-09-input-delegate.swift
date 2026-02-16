import MultipeerConnectivity

extension StreamManager: StreamDelegate {
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        if let inputStream = aStream as? InputStream {
            handleInputStreamEvent(inputStream, event: eventCode)
        } else if let outputStream = aStream as? OutputStream {
            handleOutputStreamEvent(outputStream, event: eventCode)
        }
    }
    
    private func handleInputStreamEvent(_ stream: InputStream, event: Stream.Event) {
        switch event {
        case .openCompleted:
            print("InputStream 열림")
            
        case .hasBytesAvailable:
            // 데이터 읽기
            let data = readFromStream(stream)
            if !data.isEmpty {
                if let peer = findPeer(for: stream) {
                    DispatchQueue.main.async {
                        self.onDataReceived?(data, peer)
                    }
                }
            }
            
        case .errorOccurred:
            print("InputStream 오류: \(stream.streamError?.localizedDescription ?? "알 수 없음")")
            closeInputStream(stream)
            
        case .endEncountered:
            print("InputStream 종료")
            closeInputStream(stream)
            
        default:
            break
        }
    }
    
    private func handleOutputStreamEvent(_ stream: OutputStream, event: Stream.Event) {
        // 이전에 구현한 로직
    }
    
    private func findPeer(for stream: InputStream) -> MCPeerID? {
        inputStreams.first { $0.value === stream }?.key
    }
}
