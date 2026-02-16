import CryptoKit
import Foundation

// Secure Enclave에서 P256 키 생성
// 주의: Curve25519는 지원되지 않음!

func createSecureEnclaveKey() throws -> SecureEnclave.P256.Signing.PrivateKey {
    guard SecureEnclave.isAvailable else {
        throw CryptoKitError.incorrectKeySize
    }
    
    return try SecureEnclave.P256.Signing.PrivateKey()
}

// 사용 예시
if SecureEnclave.isAvailable {
    let key = try! createSecureEnclaveKey()
    print("공개 키: \(key.publicKey.rawRepresentation.base64EncodedString())")
    // 개인 키는 Secure Enclave 내부에만 존재!
}
