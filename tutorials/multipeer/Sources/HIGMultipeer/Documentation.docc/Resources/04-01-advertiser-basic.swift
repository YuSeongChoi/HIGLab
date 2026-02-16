import MultipeerConnectivity

// MCNearbyServiceAdvertiser: 자신을 광고
let peerID = MCPeerID(displayName: UIDevice.current.name)
let serviceType = "fileshare"

// discoveryInfo: 검색자에게 전달할 추가 정보 (선택적)
let discoveryInfo: [String: String]? = nil

let advertiser = MCNearbyServiceAdvertiser(
    peer: peerID,
    discoveryInfo: discoveryInfo,
    serviceType: serviceType
)
