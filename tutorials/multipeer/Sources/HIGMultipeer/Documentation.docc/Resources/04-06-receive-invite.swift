import MultipeerConnectivity

extension AdvertiserManager: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        // 간단한 구현: 모든 초대 자동 수락
        invitationHandler(true, session)
        
        print("\(peerID.displayName)의 초대를 수락했습니다")
    }
    
    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didNotStartAdvertisingPeer error: Error
    ) {
        DispatchQueue.main.async {
            self.isAdvertising = false
        }
        print("광고 실패: \(error.localizedDescription)")
    }
}
