import CryptoKit
import Foundation

// 메시지 서명
let signingKey = Curve25519.Signing.PrivateKey()
let message = "서명할 중요한 메시지"
let messageData = Data(message.utf8)

// 서명 생성
let signature = try! signingKey.signature(for: messageData)
print("서명: \(signature.base64EncodedString())")
print("서명 크기: \(signature.count)바이트") // 64바이트
