import CryptoKit
import Foundation

// 서명 검증
let signingKey = Curve25519.Signing.PrivateKey()
let verifyingKey = signingKey.publicKey

let message = Data("검증할 메시지".utf8)
let signature = try! signingKey.signature(for: message)

// 검증 (공개 키로)
let isValid = verifyingKey.isValidSignature(signature, for: message)
print("서명 유효: \(isValid)") // true

// 변조된 메시지 검증
let tamperedMessage = Data("변조된 메시지".utf8)
let isTamperedValid = verifyingKey.isValidSignature(signature, for: tamperedMessage)
print("변조 서명 유효: \(isTamperedValid)") // false
