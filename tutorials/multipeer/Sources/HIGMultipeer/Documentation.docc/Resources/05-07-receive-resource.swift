import MultipeerConnectivity

extension SessionManager: MCSessionDelegate {
    
    func session(
        _ session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        with progress: Progress
    ) {
        print("\(peerID.displayName)로부터 '\(resourceName)' 수신 시작")
        print("예상 크기: \(progress.totalUnitCount) bytes")
        
        // 진행률 관찰
        DispatchQueue.main.async {
            // progress.fractionCompleted로 UI 업데이트
        }
    }
    
    func session(
        _ session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        at localURL: URL?,
        withError error: Error?
    ) {
        if let error = error {
            print("수신 실패: \(error.localizedDescription)")
            return
        }
        
        guard let localURL = localURL else {
            print("localURL이 nil입니다")
            return
        }
        
        print("'\(resourceName)' 수신 완료: \(localURL)")
        
        // localURL은 임시 위치 - 영구 저장소로 이동 필요
        // 8장에서 자세히 다룸
    }
    
    // ... 다른 델리게이트 메서드들
}
