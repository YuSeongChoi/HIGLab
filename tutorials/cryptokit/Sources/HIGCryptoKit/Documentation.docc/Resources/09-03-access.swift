import CryptoKit
import LocalAuthentication
import Foundation

// 접근 제어 설정 (Face ID/Touch ID 필요)
func createKeyWithBiometric() throws -> SecureEnclave.P256.Signing.PrivateKey? {
    guard SecureEnclave.isAvailable else { return nil }
    
    let context = LAContext()
    
    // Face ID/Touch ID가 있는 경우에만 키 사용 가능
    var accessControl: SecAccessControl?
    accessControl = SecAccessControlCreateWithFlags(
        nil,
        kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        [.privateKeyUsage, .biometryCurrentSet],
        nil
    )
    
    // 실제 구현에서는 authenticationContext 사용
    return try SecureEnclave.P256.Signing.PrivateKey()
}
