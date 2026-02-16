import MultipeerConnectivity

extension SessionManager: MCSessionDelegate {
    
    func session(
        _ session: MCSession,
        didReceive data: Data,
        fromPeer peerID: MCPeerID
    ) {
        // 데이터 처리
        DispatchQueue.main.async {
            // 문자열로 변환
            if let message = String(data: data, encoding: .utf8) {
                print("\(peerID.displayName): \(message)")
                // UI 업데이트 또는 데이터 저장
            }
        }
    }
    
    // ... 다른 델리게이트 메서드들
}
