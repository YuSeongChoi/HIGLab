import Foundation
import Security
import LocalAuthentication

// MARK: - 키체인 서비스
/// Security 프레임워크를 사용한 키체인 CRUD 작업
/// 민감한 데이터(비밀번호, 토큰, 암호화 키 등)를 안전하게 저장
/// - Note: 키체인은 앱 삭제 후에도 데이터가 유지될 수 있음 (iCloud Keychain 동기화 시)

final class KeychainService: Sendable {
    
    // MARK: - 싱글톤
    
    /// 공유 인스턴스
    static let shared = KeychainService()
    
    // MARK: - 상수
    
    /// 키체인 서비스 식별자
    private let service: String = "com.higlab.SecureVault"
    
    /// 비밀 목록 저장 키
    private let secretsKey = "vault.secrets"
    
    /// 암호화 키 저장용 접두사
    private let encryptionKeyPrefix = "crypto.key."
    
    /// 사용자 설정 저장용 접두사
    private let settingsPrefix = "settings."
    
    /// Apple ID 저장 키
    private let appleUserIdKey = "auth.appleUserId"
    
    // MARK: - 초기화
    
    private init() {}
    
    // MARK: - 접근성 옵션
    
    /// 키체인 항목 접근성 수준
    /// - Note: 보안 수준과 사용 편의성 사이의 균형을 고려하여 선택
    enum AccessibilityLevel {
        /// 기기 잠금 해제 상태에서만 접근 가능 (가장 안전)
        case whenUnlockedThisDeviceOnly
        
        /// 기기 잠금 해제 상태 + 다른 기기로 마이그레이션 가능
        case whenUnlocked
        
        /// 첫 잠금 해제 후 항상 접근 가능 (백그라운드 작업용)
        case afterFirstUnlockThisDeviceOnly
        
        /// 항상 접근 가능 (권장하지 않음)
        case always
        
        /// 생체 인증 필수
        case whenPasscodeSetThisDeviceOnly
        
        var secAttrValue: CFString {
            switch self {
            case .whenUnlockedThisDeviceOnly:
                return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            case .whenUnlocked:
                return kSecAttrAccessibleWhenUnlocked
            case .afterFirstUnlockThisDeviceOnly:
                return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            case .always:
                return kSecAttrAccessibleAlways
            case .whenPasscodeSetThisDeviceOnly:
                return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
            }
        }
    }
    
    // MARK: - 생체 인증 연동 저장
    
    /// 생체 인증이 필요한 항목 저장
    /// - Parameters:
    ///   - data: 저장할 데이터
    ///   - key: 식별 키
    ///   - requireBiometrics: 접근 시 생체 인증 필수 여부
    ///   - authenticationPrompt: 인증 시 표시할 메시지
    func saveWithBiometricProtection(
        _ data: Data,
        for key: String,
        authenticationPrompt: String = "키체인 항목에 접근하려면 인증이 필요합니다"
    ) throws {
        // 기존 항목 삭제
        try? deleteData(for: key)
        
        // 접근 제어 플래그 생성 (생체 인증 또는 기기 암호 필수)
        var error: Unmanaged<CFError>?
        guard let accessControl = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            [.biometryCurrentSet, .or, .devicePasscode],
            &error
        ) else {
            throw SecurityError.keyGenerationFailed(reason: "접근 제어 생성 실패")
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessControl as String: accessControl,
            kSecUseAuthenticationContext as String: createAuthContext(prompt: authenticationPrompt)
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw status.toSecurityError(for: .save)
        }
    }
    
    /// 생체 인증 보호 항목 로드
    func loadWithBiometricProtection(
        for key: String,
        authenticationPrompt: String = "키체인 항목에 접근하려면 인증이 필요합니다"
    ) async throws -> Data {
        let context = createAuthContext(prompt: authenticationPrompt)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecUseAuthenticationContext as String: context
        ]
        
        // 비동기 키체인 접근 (메인 스레드 블로킹 방지)
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                var result: AnyObject?
                let status = SecItemCopyMatching(query as CFDictionary, &result)
                
                switch status {
                case errSecSuccess:
                    if let data = result as? Data {
                        continuation.resume(returning: data)
                    } else {
                        continuation.resume(throwing: SecurityError.unexpectedDataFormat)
                    }
                case errSecItemNotFound:
                    continuation.resume(throwing: SecurityError.keychainItemNotFound)
                case errSecAuthFailed:
                    continuation.resume(throwing: SecurityError.biometricAuthenticationFailed)
                case errSecUserCanceled:
                    continuation.resume(throwing: SecurityError.biometricUserCancelled)
                default:
                    continuation.resume(throwing: status.toSecurityError(for: .load))
                }
            }
        }
    }
    
    /// LAContext 생성 헬퍼
    private func createAuthContext(prompt: String) -> LAContext {
        let context = LAContext()
        context.localizedReason = prompt
        context.localizedCancelTitle = "취소"
        context.localizedFallbackTitle = "암호 입력"
        // 생체 인증 재사용 시간 (60초)
        context.touchIDAuthenticationAllowableReuseDuration = 60
        return context
    }
    
    // MARK: - 비밀 목록 CRUD
    
    /// 모든 비밀 항목 불러오기
    func loadSecrets() throws -> [SecretItem] {
        do {
            guard let data = try loadData(for: secretsKey) else {
                return []
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            do {
                return try decoder.decode([SecretItem].self, from: data)
            } catch let decodingError {
                throw SecurityError.dataDecodingFailed(underlying: decodingError)
            }
        } catch SecurityError.keychainItemNotFound {
            return []
        }
    }
    
    /// 비밀 목록 저장
    func saveSecrets(_ secrets: [SecretItem]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .sortedKeys // 일관된 출력을 위해
        
        guard let data = try? encoder.encode(secrets) else {
            throw SecurityError.dataEncodingFailed(underlying: nil)
        }
        
        try saveData(data, for: secretsKey, accessibility: .whenUnlockedThisDeviceOnly)
    }
    
    /// 비밀 항목 추가
    func addSecret(_ secret: SecretItem) throws -> SecretItem {
        var secrets = try loadSecrets()
        secrets.append(secret)
        try saveSecrets(secrets)
        return secret
    }
    
    /// 비밀 항목 업데이트
    func updateSecret(_ secret: SecretItem) throws -> SecretItem {
        var secrets = try loadSecrets()
        guard let index = secrets.firstIndex(where: { $0.id == secret.id }) else {
            throw SecurityError.keychainItemNotFound
        }
        
        var updatedSecret = secret
        updatedSecret.modifiedAt = Date()
        secrets[index] = updatedSecret
        try saveSecrets(secrets)
        return updatedSecret
    }
    
    /// 비밀 항목 삭제
    func deleteSecret(id: UUID) throws {
        var secrets = try loadSecrets()
        let initialCount = secrets.count
        secrets.removeAll { $0.id == id }
        
        guard secrets.count < initialCount else {
            throw SecurityError.keychainItemNotFound
        }
        
        try saveSecrets(secrets)
    }
    
    /// 여러 비밀 항목 삭제
    func deleteSecrets(ids: Set<UUID>) throws {
        var secrets = try loadSecrets()
        secrets.removeAll { ids.contains($0.id) }
        try saveSecrets(secrets)
    }
    
    /// 모든 비밀 삭제
    func deleteAllSecrets() throws {
        try deleteData(for: secretsKey)
    }
    
    /// 비밀 항목 열람 기록
    func recordAccess(for secretId: UUID) throws {
        var secrets = try loadSecrets()
        guard let index = secrets.firstIndex(where: { $0.id == secretId }) else {
            return
        }
        secrets[index].recordAccess()
        try saveSecrets(secrets)
    }
    
    // MARK: - 암호화 키 관리
    
    /// 암호화 키 저장
    func saveEncryptionKey(_ keyData: Data, identifier: String) throws {
        let key = encryptionKeyPrefix + identifier
        try saveData(keyData, for: key, accessibility: .whenUnlockedThisDeviceOnly)
    }
    
    /// 암호화 키 로드
    func loadEncryptionKey(identifier: String) throws -> Data? {
        let key = encryptionKeyPrefix + identifier
        return try loadData(for: key)
    }
    
    /// 암호화 키 삭제
    func deleteEncryptionKey(identifier: String) throws {
        let key = encryptionKeyPrefix + identifier
        try deleteData(for: key)
    }
    
    /// 모든 암호화 키 삭제
    func deleteAllEncryptionKeys() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        
        // 모든 항목 조회
        var result: AnyObject?
        let searchQuery = query.merging([
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]) { _, new in new }
        
        let status = SecItemCopyMatching(searchQuery as CFDictionary, &result)
        
        guard status == errSecSuccess, let items = result as? [[String: Any]] else {
            return
        }
        
        // 암호화 키만 필터링하여 삭제
        for item in items {
            if let account = item[kSecAttrAccount as String] as? String,
               account.hasPrefix(encryptionKeyPrefix) {
                try? deleteData(for: account)
            }
        }
    }
    
    // MARK: - Apple ID 관리
    
    /// Apple ID 사용자 식별자 저장
    func saveAppleUserId(_ userId: String) throws {
        guard let data = userId.data(using: .utf8) else {
            throw SecurityError.dataEncodingFailed(underlying: nil)
        }
        try saveData(data, for: appleUserIdKey, accessibility: .whenUnlockedThisDeviceOnly)
    }
    
    /// Apple ID 사용자 식별자 로드
    func loadAppleUserId() throws -> String? {
        guard let data = try loadData(for: appleUserIdKey) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    /// Apple ID 삭제
    func deleteAppleUserId() throws {
        try deleteData(for: appleUserIdKey)
    }
    
    // MARK: - 저수준 키체인 작업
    
    /// 데이터 저장
    func saveData(
        _ data: Data,
        for key: String,
        accessibility: AccessibilityLevel = .whenUnlockedThisDeviceOnly
    ) throws {
        // 기존 항목이 있으면 업데이트, 없으면 추가
        let existingData = try? loadData(for: key)
        
        if existingData != nil {
            try updateData(data, for: key, accessibility: accessibility)
        } else {
            try addData(data, for: key, accessibility: accessibility)
        }
    }
    
    /// 데이터 추가 (내부용)
    private func addData(
        _ data: Data,
        for key: String,
        accessibility: AccessibilityLevel
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: accessibility.secAttrValue,
            // 동기화 비활성화 (보안상 로컬에만 저장)
            kSecAttrSynchronizable as String: kCFBooleanFalse as Any
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            // 이미 존재하면 업데이트
            try updateData(data, for: key, accessibility: accessibility)
        default:
            throw status.toSecurityError(for: .save)
        }
    }
    
    /// 데이터 업데이트 (내부용)
    private func updateData(
        _ data: Data,
        for key: String,
        accessibility: AccessibilityLevel
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: accessibility.secAttrValue
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        
        guard status == errSecSuccess else {
            throw status.toSecurityError(for: .update)
        }
    }
    
    /// 데이터 불러오기
    func loadData(for key: String) throws -> Data? {
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
                throw SecurityError.unexpectedDataFormat
            }
            return data
            
        case errSecItemNotFound:
            return nil
            
        default:
            throw status.toSecurityError(for: .load)
        }
    }
    
    /// 데이터 삭제
    func deleteData(for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw status.toSecurityError(for: .delete)
        }
    }
    
    /// 키 존재 여부 확인
    func exists(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: false
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    // MARK: - 개별 값 저장/불러오기
    
    /// 문자열 값 저장
    func setString(_ value: String, for key: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw SecurityError.dataEncodingFailed(underlying: nil)
        }
        try saveData(data, for: settingsPrefix + key)
    }
    
    /// 문자열 값 불러오기
    func getString(for key: String) throws -> String? {
        guard let data = try loadData(for: settingsPrefix + key) else {
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
    
    /// Int 값 저장
    func setInt(_ value: Int, for key: String) throws {
        try setString(String(value), for: key)
    }
    
    /// Int 값 불러오기
    func getInt(for key: String) throws -> Int? {
        guard let string = try getString(for: key) else {
            return nil
        }
        return Int(string)
    }
    
    /// Date 값 저장
    func setDate(_ value: Date, for key: String) throws {
        try setString(ISO8601DateFormatter().string(from: value), for: key)
    }
    
    /// Date 값 불러오기
    func getDate(for key: String) throws -> Date? {
        guard let string = try getString(for: key) else {
            return nil
        }
        return ISO8601DateFormatter().date(from: string)
    }
    
    // MARK: - 모든 데이터 삭제
    
    /// 이 앱의 모든 키체인 데이터 삭제
    func deleteAllData() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw status.toSecurityError(for: .delete)
        }
    }
    
    // MARK: - 진단 및 디버깅
    
    #if DEBUG
    /// 저장된 모든 키 목록 (디버그용)
    func listAllKeys() -> [String] {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let items = result as? [[String: Any]] else {
            return []
        }
        
        return items.compactMap { $0[kSecAttrAccount as String] as? String }
    }
    
    /// 키체인 상태 출력 (디버그용)
    func printStatus() {
        print("=== KeychainService Status ===")
        print("Service: \(service)")
        print("Keys stored: \(listAllKeys())")
        
        do {
            let secrets = try loadSecrets()
            print("Secrets count: \(secrets.count)")
        } catch {
            print("Error loading secrets: \(error)")
        }
        print("==============================")
    }
    #endif
}

// MARK: - 설정 키 상수
extension KeychainService {
    /// 앱 설정 키
    enum SettingsKey {
        static let requireAuthOnLaunch = "requireAuthOnLaunch"
        static let autoLockTimeout = "autoLockTimeout"
        static let useBiometrics = "useBiometrics"
        static let lastUnlockDate = "lastUnlockDate"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let preferredAuthMethod = "preferredAuthMethod"
        static let autoFillEnabled = "autoFillEnabled"
    }
}

// MARK: - 편의 속성
extension KeychainService {
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
    
    /// 자동 잠금 시간 (초)
    var autoLockTimeout: Int {
        get { (try? getInt(for: SettingsKey.autoLockTimeout)) ?? 60 }
        set { try? setInt(newValue, for: SettingsKey.autoLockTimeout) }
    }
    
    /// 마지막 잠금 해제 시간
    var lastUnlockDate: Date? {
        get { try? getDate(for: SettingsKey.lastUnlockDate) }
        set {
            if let date = newValue {
                try? setDate(date, for: SettingsKey.lastUnlockDate)
            }
        }
    }
    
    /// 온보딩 완료 여부
    var hasCompletedOnboarding: Bool {
        get { (try? getBool(for: SettingsKey.hasCompletedOnboarding)) ?? false }
        set { try? setBool(newValue, for: SettingsKey.hasCompletedOnboarding) }
    }
}
