import Network

extension UDPClient {
    // 여러 메시지를 빠르게 전송
    func sendBurst(_ messages: [String]) {
        for (index, message) in messages.enumerated() {
            guard let data = message.data(using: .utf8) else { continue }
            
            connection?.send(
                content: data,
                contentContext: .defaultMessage,
                isComplete: true,
                completion: .contentProcessed { error in
                    if error == nil {
                        print("패킷 \(index) 전송됨")
                    }
                }
            )
        }
    }
    
    // 위치 업데이트처럼 빠른 전송이 필요한 경우
    func sendPosition(x: Float, y: Float, z: Float) {
        var data = Data()
        withUnsafeBytes(of: x) { data.append(contentsOf: $0) }
        withUnsafeBytes(of: y) { data.append(contentsOf: $0) }
        withUnsafeBytes(of: z) { data.append(contentsOf: $0) }
        
        connection?.send(
            content: data,
            contentContext: .defaultMessage,
            isComplete: true,
            completion: .idempotent  // 결과 무시, 최대 속도
        )
    }
}
