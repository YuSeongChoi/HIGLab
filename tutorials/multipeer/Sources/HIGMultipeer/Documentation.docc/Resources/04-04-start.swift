import MultipeerConnectivity

class AdvertiserManager: NSObject, ObservableObject {
    
    @Published var isAdvertising = false
    
    private var advertiser: MCNearbyServiceAdvertiser?
    private let peerID: MCPeerID
    private let serviceType = "fileshare"
    private let session: MCSession
    
    init(peerID: MCPeerID, session: MCSession) {
        self.peerID = peerID
        self.session = session
        super.init()
    }
    
    func startAdvertising() {
        // 이미 광고 중이면 중지
        stopAdvertising()
        
        let discoveryInfo: [String: String] = [
            "deviceType": UIDevice.current.model
        ]
        
        advertiser = MCNearbyServiceAdvertiser(
            peer: peerID,
            discoveryInfo: discoveryInfo,
            serviceType: serviceType
        )
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
        
        DispatchQueue.main.async {
            self.isAdvertising = true
        }
    }
}
