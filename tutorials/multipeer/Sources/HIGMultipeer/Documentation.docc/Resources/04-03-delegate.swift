import MultipeerConnectivity

class AdvertiserManager: NSObject, MCNearbyServiceAdvertiserDelegate {
    
    // 연결 초대 수신
    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        print("\(peerID.displayName)로부터 초대를 받았습니다")
        
        // context가 있으면 확인
        if let context = context,
           let message = String(data: context, encoding: .utf8) {
            print("초대 메시지: \(message)")
        }
        
        // 여기서 수락/거절 결정
    }
    
    // 광고 시작 실패
    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didNotStartAdvertisingPeer error: Error
    ) {
        print("광고 시작 실패: \(error)")
    }
}
