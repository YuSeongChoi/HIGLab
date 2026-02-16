import MultipeerConnectivity

class DataManager {
    
    let session: MCSession
    
    // Reliable 모드: 순서와 전달 보장 (TCP와 유사)
    // - 중요한 메시지, 파일 정보, 명령어 등
    func sendReliable(_ data: Data, to peers: [MCPeerID]) throws {
        try session.send(data, toPeers: peers, with: .reliable)
    }
    
    // Unreliable 모드: 순서와 전달 보장 안함 (UDP와 유사)
    // - 실시간 위치, 센서 데이터, 게임 상태 등
    // - 일부 손실이 허용되는 빈번한 업데이트
    func sendUnreliable(_ data: Data, to peers: [MCPeerID]) throws {
        try session.send(data, toPeers: peers, with: .unreliable)
    }
}
