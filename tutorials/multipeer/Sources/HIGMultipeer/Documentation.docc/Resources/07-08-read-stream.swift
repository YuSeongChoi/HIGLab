import MultipeerConnectivity

class StreamManager: NSObject {
    
    private var inputStreams: [MCPeerID: InputStream] = [:]
    var onDataReceived: ((Data, MCPeerID) -> Void)?
    
    // InputStream에서 데이터 읽기
    func readFromStream(_ stream: InputStream) -> Data {
        var data = Data()
        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }
        
        while stream.hasBytesAvailable {
            let bytesRead = stream.read(buffer, maxLength: bufferSize)
            
            if bytesRead > 0 {
                data.append(buffer, count: bytesRead)
            } else if bytesRead < 0 {
                // 오류 발생
                if let error = stream.streamError {
                    print("읽기 오류: \(error)")
                }
                break
            } else {
                // bytesRead == 0: 더 이상 데이터 없음
                break
            }
        }
        
        return data
    }
}
