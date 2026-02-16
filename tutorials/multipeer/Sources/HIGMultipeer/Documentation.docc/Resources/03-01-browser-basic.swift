import MultipeerConnectivity

// MCNearbyServiceBrowser: 주변 피어 검색
let peerID = MCPeerID(displayName: UIDevice.current.name)
let serviceType = "fileshare"

let browser = MCNearbyServiceBrowser(
    peer: peerID,
    serviceType: serviceType
)
