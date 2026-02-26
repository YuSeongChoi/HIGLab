import Foundation
import LocalAuthentication
import CryptoKit
import AuthenticationServices

@Observable
final class AuthManager {
    private(set) var isUnlocked = false
    private(set) var biometricType: BiometricType = .none
    private(set) var encryptionKey: SymmetricKey?
    
    private let keychain = KeychainHelper()
    
    enum BiometricType {
        case none, touchID, faceID
    }
    
    init() {
        checkBiometricType()
        loadOrCreateKey()
    }
    
    // MARK: - Biometric Check
    private func checkBiometricType() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .touchID:
                biometricType = .touchID
            case .faceID:
                biometricType = .faceID
            default:
                biometricType = .none
            }
        }
    }
    
    // MARK: - Biometric Authentication
    @MainActor
    func authenticateWithBiometrics() async -> Bool {
        let context = LAContext()
        let reason = "메모를 보려면 인증이 필요합니다"
        
        do {
            let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            if success {
                isUnlocked = true
            }
            return success
        } catch {
            return false
        }
    }
    
    // MARK: - Encryption Key Management
    private func loadOrCreateKey() {
        if let keyData = keychain.load(key: "encryptionKey") {
            encryptionKey = SymmetricKey(data: keyData)
        } else {
            let newKey = SymmetricKey(size: .bits256)
            let keyData = newKey.withUnsafeBytes { Data($0) }
            keychain.save(key: "encryptionKey", data: keyData)
            encryptionKey = newKey
        }
    }
    
    // MARK: - Lock
    func lock() {
        isUnlocked = false
    }
}

// MARK: - Keychain Helper
class KeychainHelper {
    func save(key: String, data: Data) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    func load(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        return result as? Data
    }
}
