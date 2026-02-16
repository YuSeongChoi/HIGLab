import CryptoKit
import Foundation

// Secure Enclave 키로 서명
func signWithSecureEnclave(
    message: Data,
    key: SecureEnclave.P256.Signing.PrivateKey
) throws -> P256.Signing.ECDSASignature {
    return try key.signature(for: message)
}

// 서명 검증 (공개 키로)
func verifySignature(
    _ signature: P256.Signing.ECDSASignature,
    for message: Data,
    publicKey: P256.Signing.PublicKey
) -> Bool {
    return publicKey.isValidSignature(signature, for: message)
}

// 사용 예시
if SecureEnclave.isAvailable {
    let key = try! SecureEnclave.P256.Signing.PrivateKey()
    let message = Data("Secure Enclave 서명".utf8)
    let signature = try! signWithSecureEnclave(message: message, key: key)
    print("서명 완료: \(signature)")
}
