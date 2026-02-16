import MultipeerConnectivity

// 초대 컨텍스트 활용 예시

// 초대자 측 (Browser)
struct InvitationContext: Codable {
    let senderName: String
    let appVersion: String
    let timestamp: Date
}

func invitePeerWithContext(_ peer: MCPeerID, to session: MCSession) {
    let context = InvitationContext(
        senderName: "사용자",
        appVersion: "1.0.0",
        timestamp: Date()
    )
    
    let contextData = try? JSONEncoder().encode(context)
    
    browser?.invitePeer(
        peer,
        to: session,
        withContext: contextData,
        timeout: 30
    )
}

// 수신자 측 (Advertiser)
extension AdvertiserManager: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        // 컨텍스트 파싱
        if let context = context,
           let invitationContext = try? JSONDecoder().decode(InvitationContext.self, from: context) {
            print("보낸 사람: \(invitationContext.senderName)")
            print("앱 버전: \(invitationContext.appVersion)")
            
            // 앱 버전 호환성 확인 등
        }
        
        // 수락/거절 처리
        invitationHandler(true, session)
    }
}
