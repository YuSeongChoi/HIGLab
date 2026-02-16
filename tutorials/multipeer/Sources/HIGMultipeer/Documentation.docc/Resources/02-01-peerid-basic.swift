import MultipeerConnectivity

// MCPeerID: 피어를 고유하게 식별하는 객체
// - displayName: 사용자에게 표시되는 이름
// - 내부적으로 고유 ID를 가짐

let peerID = MCPeerID(displayName: "나의 iPhone")

// displayName 접근
print(peerID.displayName) // "나의 iPhone"
