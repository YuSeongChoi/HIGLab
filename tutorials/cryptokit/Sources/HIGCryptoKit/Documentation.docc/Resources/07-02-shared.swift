import CryptoKit
import Foundation

// ECDH 공유 비밀 생성
let alicePrivate = Curve25519.KeyAgreement.PrivateKey()
let bobPrivate = Curve25519.KeyAgreement.PrivateKey()

// Alice: Bob의 공개 키와 자신의 개인 키로 공유 비밀 계산
let aliceShared = try! alicePrivate.sharedSecretFromKeyAgreement(
    with: bobPrivate.publicKey
)

// Bob: Alice의 공개 키와 자신의 개인 키로 공유 비밀 계산
let bobShared = try! bobPrivate.sharedSecretFromKeyAgreement(
    with: alicePrivate.publicKey
)

// 동일한 공유 비밀!
print("공유 비밀 일치: \(aliceShared == bobShared)") // true
