import CryptoKit
import Foundation

// 서명용 키 쌍 (Ed25519)
let signingKey = Curve25519.Signing.PrivateKey()
let verifyingKey = signingKey.publicKey

// 공개 키 내보내기
let verifyingKeyData = verifyingKey.rawRepresentation
print("검증 키: \(verifyingKeyData.base64EncodedString())")

// 키 복원
let restoredKey = try! Curve25519.Signing.PublicKey(
    rawRepresentation: verifyingKeyData
)
