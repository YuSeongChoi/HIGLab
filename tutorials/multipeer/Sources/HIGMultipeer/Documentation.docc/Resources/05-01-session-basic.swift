import MultipeerConnectivity

// MCSession: 연결된 피어 간 통신 세션
let peerID = MCPeerID(displayName: UIDevice.current.name)

// 기본 세션 생성
let session = MCSession(peer: peerID)

// 또는 보안 옵션 지정
let secureSession = MCSession(
    peer: peerID,
    securityIdentity: nil,        // 인증서 (선택)
    encryptionPreference: .required  // 암호화 설정
)
