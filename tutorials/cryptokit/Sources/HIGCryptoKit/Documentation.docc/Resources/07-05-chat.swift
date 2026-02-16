import CryptoKit
import Foundation

// E2E 암호화 채팅 시뮬레이션
let alicePrivate = Curve25519.KeyAgreement.PrivateKey()
let bobPrivate = Curve25519.KeyAgreement.PrivateKey()

// Alice → Bob 채널
let aliceToBob = E2EChannel(
    myPrivateKey: alicePrivate,
    theirPublicKey: bobPrivate.publicKey
)

// Bob → Alice 채널 (동일한 키 사용)
let bobToAlice = E2EChannel(
    myPrivateKey: bobPrivate,
    theirPublicKey: alicePrivate.publicKey
)

// Alice가 메시지 전송
let encrypted = try! aliceToBob.encrypt("안녕, Bob!")

// Bob이 메시지 수신
let decrypted = try! bobToAlice.decrypt(encrypted)
print("Bob 수신: \(decrypted)") // "안녕, Bob!"
