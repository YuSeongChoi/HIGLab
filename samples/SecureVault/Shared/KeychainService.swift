import Foundation
import Security

// MARK: - 키체인 서비스
/// Security 프레임워크를 사용한 키체인 CRUD 작업
/// 민감한 데이터(비밀번호, 토큰 등)를 안전하게 저장

final class KeychainService {
    
    // MARK: - 싱글톤
    static let shared = KeychainService()
    private init() {}
    
    // MARK: - 상수
    
    /// 키체인 서비스 식별자
    private let service = "com.higlab.SecureVault"
    
    /// 비밀 목록 저장 키
    private let secretsKey = "secrets"
    
    // MARK: - 에러 정의
    
    enum KeychainError: LocalizedError {
        case saveFailed(OSStatus)
        case loadFailed(OSStatus)
        case deleteFailed(OSStatus)
        case dataEncodingFailed
        case dataDecodingFailed
        case itemNotFound
        case unexpectedData
        
        var errorDescription: String? {
            switch self {
            case .saveFailed(let status):
                return "키체인 저장 실패: \(SecCopyErrorMessageString(status, nil) as String? ?? "코드 \(status)")"
            case .loadFailed(let status):
                return "키체인 로드 실패: \(SecCopyErrorMessageString(status, nil) as String? ?? "코드 \(status)")"
            case .deleteFailed(let status):
                return "키체인 삭제 실패: \(SecCopyErrorMessageString(status, nil) as String? ?? "코드 \(status)")"
            case .dataEncodingFailed:
                return "데이터 인코딩에 실패했습니다"
            case .dataDecodingFailed:
                return "데이터 디코딩에 실패했습니다"
            case .itemNotFound:
                return "키체인에서 항목을 찾을 수 없습니다"
            case .unexpectedData:
                return "예상치 못한 데이터 형식입니다"
            }
        }
    }
    
    // MARK: - 비밀 목록 CRUD
    
    /// 모든 비밀 항목 불러오기
    func loadSecrets() throws -> [SecretItem] {
        do {
            guard let data = try loadData(for: secretsKey) else {
                // 데이터가 없으면 빈 배열 반환
                return []
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            do {
                return try decoder.decode([SecretItem].self, from: data)
            } catch {
                throw KeychainError.dataDecodingFailed
            }
        } catch KeychainError.itemNotFound {
            // 아직 저장된 데이터가 없음
            return []
        }
    }
    
    /// 비밀 목록 저장
    func saveSecrets(_ secrets: [SecretItem]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        guard let data = try? encoder.encode(secrets) else {
            throw KeychainError.dataEncodingFailed
        }
        
        try saveData(data, for: secretsKey)
    }
    
    /// 비밀 항목 추가
    func addSecret(_ secret: SecretItem) throws {
        var secrets = try loadSecrets()
        secrets.append(secret)
        try saveSecrets(secrets)
    }
    
    /// 비밀 항목 업데이트
    func updateSecret(_ secret: SecretItem) throws {
        var secrets = try loadSecrets()
        guard let index = secrets.firstIndex(where: { $0.id == secret.id }) else {
            throw KeychainError.itemNotFound
        }
        secrets[index] = secret
        try saveSecrets(secrets)
    }
    
    /// 비밀 항목 삭제
    func deleteSecret(id: UUID) throws {
        var secrets = try loadSecrets()
        secrets.removeAll { $0.id == id }
        try saveSecrets(secrets)
    }
    
    /// 모든 비밀 삭제
    func deleteAllSecrets() throws {
        try deleteData(for: secretsKey)
    }
    
    // MARK: - 저수준 키체인 작업
    
    /// 데이터 저장
    private func saveData(_ data: Data, for key: String) throws {
        // 기존 항목 삭제 시도 (있으면 삭제, 없으면 무시)
        try? deleteData(for: key)
        
        // 저장할 쿼리 생성
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            // 잠긴 상태에서 접근 불가 (보안 강화)
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }
    
    /// 데이터 불러오기
    private func loadData(for key: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        switch status {
        case errSecSuccess:
            guard let data = result as? Data else {
                throw KeychainError.unexpectedData
            }
            return data
            
        case errSecItemNotFound:
            throw KeychainError.itemNotFound
            
        default:
            throw KeychainError.loadFailed(status)
        }
    }
    
    /// 데이터 삭제
    private func deleteData(for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }
    
    // MARK: - 개별 값 저장/불러오기
    
    /// 문자열 값 저장
    func setString(_ value: String, for key: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.dataEncodingFailed
        }
        try saveData(data, for: key)
    }
    
    /// 문자열 값 불러오기
    func getString(for key: String) throws -> String? {
        guard let data = try loadData(for: key) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    /// Bool 값 저장
    func setBool(_ value: Bool, for key: String) throws {
        try setString(value ? "true" : "false", for: key)
    }
    
    /// Bool 값 불러오기
    func getBool(for key: String) throws -> Bool {
        guard let string = try getString(for: key) else {
            return false
        }
        return string == "true"
    }
}

// MARK: - 편의 확장
extension KeychainService {
    /// 설정 키 상수
    enum SettingsKey {
        static let requireAuthOnLaunch = "requireAuthOnLaunch"
        static let autoLockTimeout = "autoLockTimeout"
        static let useBiometrics = "useBiometrics"
    }
    
    /// 앱 실행 시 인증 필요 여부
    var requireAuthOnLaunch: Bool {
        get { (try? getBool(for: SettingsKey.requireAuthOnLaunch)) ?? true }
        set { try? setBool(newValue, for: SettingsKey.requireAuthOnLaunch) }
    }
    
    /// 생체 인증 사용 여부
    var useBiometrics: Bool {
        get { (try? getBool(for: SettingsKey.useBiometrics)) ?? true }
        set { try? setBool(newValue, for: SettingsKey.useBiometrics) }
    }
}
