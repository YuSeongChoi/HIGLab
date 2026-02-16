import MultipeerConnectivity
import SwiftUI

class BrowserManager: NSObject, ObservableObject {
    
    @Published var availablePeers: [MCPeerID] = []
    @Published var isBrowsing = false
    
    private var browser: MCNearbyServiceBrowser?
    private let peerID: MCPeerID
    private let serviceType = "fileshare"
    
    init(peerID: MCPeerID) {
        self.peerID = peerID
        super.init()
    }
}
