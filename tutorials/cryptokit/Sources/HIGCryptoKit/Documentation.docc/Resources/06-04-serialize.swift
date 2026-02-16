import CryptoKit
import Foundation

// 공개 키 직렬화/역직렬화
let privateKey = Curve25519.KeyAgreement.PrivateKey()
let publicKey = privateKey.publicKey

// 직렬화 (Base64)
let publicKeyBase64 = publicKey.rawRepresentation.base64EncodedString()
print("공유용: \(publicKeyBase64)")

// 역직렬화
func restorePublicKey(from base64: String) throws -> Curve25519.KeyAgreement.PublicKey {
    guard let data = Data(base64Encoded: base64) else {
        throw CryptoKitError.authenticationFailure
    }
    return try Curve25519.KeyAgreement.PublicKey(rawRepresentation: data)
}

let restored = try! restorePublicKey(from: publicKeyBase64)
