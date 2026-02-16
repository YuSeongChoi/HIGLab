import MultipeerConnectivity

class AdvertiserManager: NSObject, ObservableObject {
    
    @Published var isAdvertising = false
    
    private var advertiser: MCNearbyServiceAdvertiser?
    private let peerID: MCPeerID
    private let serviceType = "fileshare"
    private let session: MCSession
    
    func startAdvertising() {
        stopAdvertising()
        
        advertiser = MCNearbyServiceAdvertiser(
            peer: peerID,
            discoveryInfo: ["deviceType": UIDevice.current.model],
            serviceType: serviceType
        )
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
        
        DispatchQueue.main.async {
            self.isAdvertising = true
        }
    }
    
    func stopAdvertising() {
        advertiser?.stopAdvertisingPeer()
        advertiser?.delegate = nil
        advertiser = nil
        
        DispatchQueue.main.async {
            self.isAdvertising = false
        }
    }
    
    deinit {
        stopAdvertising()
    }
}
