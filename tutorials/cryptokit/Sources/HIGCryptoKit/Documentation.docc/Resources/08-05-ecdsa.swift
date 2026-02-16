import CryptoKit
import Foundation

// P256 ECDSA 서명 (호환성이 필요한 경우)
let p256Key = P256.Signing.PrivateKey()
let message = Data("ECDSA 테스트".utf8)

// 서명
let ecdsaSignature = try! p256Key.signature(for: message)

// 검증
let isValid = p256Key.publicKey.isValidSignature(ecdsaSignature, for: message)
print("ECDSA 유효: \(isValid)")

// DER 형식으로 내보내기 (다른 시스템과 호환)
let derSignature = ecdsaSignature.derRepresentation
print("DER 서명: \(derSignature.base64EncodedString())")
