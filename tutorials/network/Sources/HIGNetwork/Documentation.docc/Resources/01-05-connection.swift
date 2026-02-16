import Network

let connection = NWConnection(
    host: "chat.example.com",
    port: 8080,
    using: .tcp
)

// 연결 상태 핸들러
connection.stateUpdateHandler = { state in
    switch state {
    case .setup:
        print("연결 준비 중...")
    case .preparing:
        print("연결 설정 중...")
    case .ready:
        print("연결 성공! 데이터 송수신 가능")
    case .waiting(let error):
        print("대기 중: \(error.localizedDescription)")
    case .failed(let error):
        print("연결 실패: \(error.localizedDescription)")
    case .cancelled:
        print("연결 취소됨")
    @unknown default:
        break
    }
}

// 연결 시작 (DispatchQueue 지정)
connection.start(queue: .main)
