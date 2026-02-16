import MultipeerConnectivity

class MultipeerManager: NSObject {
    
    static let serviceType = "fileshare"
    
    private var peerID: MCPeerID
    private var session: MCSession?
    private var browser: MCNearbyServiceBrowser?
    private var advertiser: MCNearbyServiceAdvertiser?
    
    override init() {
        self.peerID = MCPeerID(displayName: UIDevice.current.name)
        super.init()
    }
}
