import Network

class ChatServer {
    private var listener: NWListener?
    private let queue = DispatchQueue(label: "chat.server.queue")
    
    // 특정 포트로 리스너 생성
    func start(port: UInt16) throws {
        let parameters = NWParameters.tcp
        
        listener = try NWListener(
            using: parameters,
            on: NWEndpoint.Port(integerLiteral: port)
        )
    }
    
    // 시스템이 포트 자동 할당
    func startWithAnyPort() throws {
        let parameters = NWParameters.tcp
        
        // 포트 0은 시스템이 사용 가능한 포트 자동 할당
        listener = try NWListener(using: parameters)
    }
}
