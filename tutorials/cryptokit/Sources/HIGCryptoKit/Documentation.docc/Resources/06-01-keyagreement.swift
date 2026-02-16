import CryptoKit
import Foundation

// 키 교환용 키 쌍 (Curve25519)
let privateKey = Curve25519.KeyAgreement.PrivateKey()
let publicKey = privateKey.publicKey

// 공개 키를 Data로 변환 (전송용)
let publicKeyData = publicKey.rawRepresentation
print("공개 키: \(publicKeyData.base64EncodedString())")
print("크기: \(publicKeyData.count)바이트") // 32바이트

// 개인 키도 저장 가능 (안전하게 보관!)
let privateKeyData = privateKey.rawRepresentation
