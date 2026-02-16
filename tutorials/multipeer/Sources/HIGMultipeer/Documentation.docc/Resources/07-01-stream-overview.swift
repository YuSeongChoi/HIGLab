import MultipeerConnectivity

// 스트림 전송 개념
// - OutputStream: 데이터를 쓰는 쪽 (송신자)
// - InputStream: 데이터를 읽는 쪽 (수신자)
// - 연속적인 데이터 흐름에 적합 (오디오, 비디오, 실시간 데이터)

// startStream 메서드로 OutputStream 생성
// 상대방은 session(_:didReceive:withName:fromPeer:)로 InputStream 수신

class StreamManager {
    
    let session: MCSession
    
    init(session: MCSession) {
        self.session = session
    }
    
    // 피어에게 스트림 시작
    func startStream(to peer: MCPeerID, named name: String) throws -> OutputStream {
        return try session.startStream(withName: name, toPeer: peer)
    }
}
