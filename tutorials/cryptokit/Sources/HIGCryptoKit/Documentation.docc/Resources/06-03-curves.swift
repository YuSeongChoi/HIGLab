import CryptoKit
import Foundation

// 다양한 타원 곡선 지원

// P256 (secp256r1) - 가장 널리 사용
let p256Key = P256.KeyAgreement.PrivateKey()
print("P256 공개 키: \(p256Key.publicKey.rawRepresentation.count)바이트")

// P384 - 더 높은 보안
let p384Key = P384.KeyAgreement.PrivateKey()
print("P384 공개 키: \(p384Key.publicKey.rawRepresentation.count)바이트")

// P521 - 최고 수준 보안
let p521Key = P521.KeyAgreement.PrivateKey()
print("P521 공개 키: \(p521Key.publicKey.rawRepresentation.count)바이트")

// Curve25519 - 현대적이고 빠름 (권장)
let curve25519Key = Curve25519.KeyAgreement.PrivateKey()
