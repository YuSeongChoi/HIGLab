import MultipeerConnectivity

class AdvertiserManager: NSObject, ObservableObject {
    
    @Published var isAdvertising = false
    @Published var pendingInvitation: PendingInvitation?
    
    private var advertiser: MCNearbyServiceAdvertiser?
    private let peerID: MCPeerID
    private let serviceType = "fileshare"
    private let session: MCSession
    
    struct PendingInvitation {
        let peerID: MCPeerID
        let context: Data?
        let handler: (Bool, MCSession?) -> Void
    }
    
    // 초대 수락
    func acceptInvitation() {
        pendingInvitation?.handler(true, session)
        pendingInvitation = nil
    }
    
    // 초대 거절
    func declineInvitation() {
        pendingInvitation?.handler(false, nil)
        pendingInvitation = nil
    }
}

extension AdvertiserManager: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        // UI에서 확인받기 위해 저장
        DispatchQueue.main.async {
            self.pendingInvitation = PendingInvitation(
                peerID: peerID,
                context: context,
                handler: invitationHandler
            )
        }
    }
}
