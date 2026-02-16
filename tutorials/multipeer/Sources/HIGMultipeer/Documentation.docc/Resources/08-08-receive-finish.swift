import MultipeerConnectivity

extension ResourceManager: MCSessionDelegate {
    
    func session(
        _ session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        at localURL: URL?,
        withError error: Error?
    ) {
        // 수신 목록에서 제거
        DispatchQueue.main.async {
            self.receivingResources.removeAll { 
                $0.resourceName == resourceName && $0.fromPeer == peerID 
            }
        }
        
        if let error = error {
            print("수신 실패: \(error.localizedDescription)")
            return
        }
        
        guard let localURL = localURL else {
            print("localURL이 nil입니다")
            return
        }
        
        print("수신 완료: \(resourceName)")
        print("임시 위치: \(localURL)")
        
        // 중요: localURL은 임시 위치이므로 영구 저장소로 이동해야 함!
        saveReceivedFile(from: localURL, named: resourceName)
    }
    
    private func saveReceivedFile(from tempURL: URL, named name: String) {
        // 다음 단계에서 구현
    }
}
