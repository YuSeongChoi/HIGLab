import MultipeerConnectivity

// MCEncryptionPreference 옵션
// - .none: 암호화 없음
// - .optional: 가능하면 암호화 (기본값)
// - .required: 필수 암호화 (암호화 미지원 피어와 연결 불가)

// 암호화 필수 세션
let encryptedSession = MCSession(
    peer: peerID,
    securityIdentity: nil,
    encryptionPreference: .required
)

// securityIdentity: 피어 인증용 인증서
// - [SecIdentity, SecCertificate...] 형태의 배열
// - nil이면 피어 인증 없음
