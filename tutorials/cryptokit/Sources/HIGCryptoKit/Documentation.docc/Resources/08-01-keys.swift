import CryptoKit
import Foundation

// 서명용 키 쌍 생성
let signingKey = Curve25519.Signing.PrivateKey()
let verifyingKey = signingKey.publicKey

// 키 내보내기
let privateKeyData = signingKey.rawRepresentation
let publicKeyData = verifyingKey.rawRepresentation

print("개인 키: \(privateKeyData.count)바이트") // 32바이트
print("공개 키: \(publicKeyData.count)바이트") // 32바이트
