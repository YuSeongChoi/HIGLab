import MultipeerConnectivity

class BrowserManager: NSObject, MCNearbyServiceBrowserDelegate {
    
    // 피어 발견
    func browser(
        _ browser: MCNearbyServiceBrowser,
        foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String: String]?
    ) {
        print("피어 발견: \(peerID.displayName)")
        if let info = info {
            print("추가 정보: \(info)")
        }
    }
    
    // 피어 손실
    func browser(
        _ browser: MCNearbyServiceBrowser,
        lostPeer peerID: MCPeerID
    ) {
        print("피어 손실: \(peerID.displayName)")
    }
    
    // 검색 실패
    func browser(
        _ browser: MCNearbyServiceBrowser,
        didNotStartBrowsingForPeers error: Error
    ) {
        print("검색 시작 실패: \(error)")
    }
}
