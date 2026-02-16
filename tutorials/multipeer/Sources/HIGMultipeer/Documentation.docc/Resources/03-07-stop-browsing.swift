import MultipeerConnectivity

class BrowserManager: NSObject, ObservableObject {
    
    @Published var availablePeers: [MCPeerID] = []
    @Published var isBrowsing = false
    
    private var browser: MCNearbyServiceBrowser?
    private let peerID: MCPeerID
    private let serviceType = "fileshare"
    
    func startBrowsing() {
        stopBrowsing()
        
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
        
        DispatchQueue.main.async {
            self.isBrowsing = true
        }
    }
    
    func stopBrowsing() {
        browser?.stopBrowsingForPeers()
        browser?.delegate = nil
        browser = nil
        
        DispatchQueue.main.async {
            self.isBrowsing = false
            self.availablePeers.removeAll()
        }
    }
    
    deinit {
        stopBrowsing()
    }
}
