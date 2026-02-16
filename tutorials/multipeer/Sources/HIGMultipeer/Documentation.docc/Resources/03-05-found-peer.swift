import MultipeerConnectivity

extension BrowserManager: MCNearbyServiceBrowserDelegate {
    
    func browser(
        _ browser: MCNearbyServiceBrowser,
        foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String: String]?
    ) {
        // 메인 스레드에서 UI 업데이트
        DispatchQueue.main.async {
            // 중복 방지
            if !self.availablePeers.contains(peerID) {
                self.availablePeers.append(peerID)
            }
        }
        
        // discoveryInfo 활용 예시
        if let deviceType = info?["deviceType"] {
            print("\(peerID.displayName)의 기기 유형: \(deviceType)")
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        // 다음 단계에서 구현
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("검색 실패: \(error)")
    }
}
