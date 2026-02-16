import MultipeerConnectivity
import SwiftUI
import Combine

class MultipeerManager: NSObject, ObservableObject {
    
    static let serviceType = "fileshare"
    
    @Published var connectedPeers: [MCPeerID] = []
    @Published var availablePeers: [MCPeerID] = []
    @Published var isAdvertising = false
    @Published var isBrowsing = false
    
    private var peerID: MCPeerID
    private var session: MCSession?
    private var browser: MCNearbyServiceBrowser?
    private var advertiser: MCNearbyServiceAdvertiser?
    
    override init() {
        self.peerID = MCPeerID(displayName: UIDevice.current.name)
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        session?.delegate = self
    }
}
