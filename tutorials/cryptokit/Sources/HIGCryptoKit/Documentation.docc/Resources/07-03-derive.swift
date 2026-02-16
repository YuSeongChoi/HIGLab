import CryptoKit
import Foundation

// HKDF로 대칭 키 파생
let alicePrivate = Curve25519.KeyAgreement.PrivateKey()
let bobPrivate = Curve25519.KeyAgreement.PrivateKey()

let sharedSecret = try! alicePrivate.sharedSecretFromKeyAgreement(
    with: bobPrivate.publicKey
)

// HKDF (HMAC-based Key Derivation Function)
let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
    using: SHA256.self,
    salt: Data("SecureChat".utf8),      // 앱 고유 salt
    sharedInfo: Data("E2E-Key".utf8),   // 컨텍스트 정보
    outputByteCount: 32                  // 256비트 키
)

print("파생된 대칭 키 준비 완료!")
