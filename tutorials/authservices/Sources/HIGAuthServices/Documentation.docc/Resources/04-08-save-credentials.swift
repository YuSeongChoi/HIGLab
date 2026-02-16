import Foundation
import Security

struct AppleUserCredentials: Codable {
    let userIdentifier: String
    let email: String?
    let firstName: String?
    let lastName: String?
}

class KeychainManager {
    
    static let service = "com.example.myapp.appleid"
    
    // Keychain에 사용자 정보 저장
    static func saveCredentials(_ credentials: AppleUserCredentials) throws {
        let data = try JSONEncoder().encode(credentials)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: credentials.userIdentifier,
            kSecValueData as String: data
        ]
        
        // 기존 항목 삭제
        SecItemDelete(query as CFDictionary)
        
        // 새 항목 추가
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed
        }
    }
    
    // Keychain에서 사용자 정보 로드
    static func loadCredentials(
        userIdentifier: String
    ) -> AppleUserCredentials? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: userIdentifier,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        
        guard let data = result as? Data else { return nil }
        return try? JSONDecoder().decode(
            AppleUserCredentials.self, 
            from: data
        )
    }
}

enum KeychainError: Error {
    case saveFailed
}
