import Foundation
import CryptoKit
import Security
import LocalAuthentication

// MARK: - 암호화 서비스
/// CryptoKit을 사용한 암호화 작업 관리
///
/// ## 지원하는 암호화 기능:
/// - **AES-GCM**: 대칭키 암호화 (256비트)
/// - **ChaChaPoly**: 대체 대칭키 암호화
/// - **SHA256/SHA512**: 해시 함수
/// - **HMAC**: 메시지 인증 코드
/// - **P256 (Secure Enclave)**: 비대칭키 암호화 및 서명
///
/// ## 보안 고려사항:
/// - 키는 Keychain에 안전하게 저장
/// - Secure Enclave 사용 가능 시 P256 키를 SE에 저장
/// - nonce/IV는 매 암호화마다 새로 생성

final class CryptoService: Sendable {
    
    // MARK: - 싱글톤
    
    static let shared = CryptoService()
    
    private init() {}
    
    // MARK: - 상수
    
    /// 기본 암호화 키 식별자
    private let defaultKeyIdentifier = "default.encryption.key"
    
    /// Secure Enclave 키 태그
    private let secureEnclaveKeyTag = "com.higlab.SecureVault.secureenclave.key"
    
    /// 키 크기 (비트)
    private let symmetricKeySize = SymmetricKeySize.bits256
    
    // MARK: - 대칭키 관리
    
    /// SymmetricKey 생성 (256비트)
    /// - Returns: 새로 생성된 대칭키
    func generateSymmetricKey() -> SymmetricKey {
        SymmetricKey(size: symmetricKeySize)
    }
    
    /// 대칭키를 Data로 변환
    /// - Parameter key: 변환할 대칭키
    /// - Returns: 키 데이터
    func keyToData(_ key: SymmetricKey) -> Data {
        key.withUnsafeBytes { Data($0) }
    }
    
    /// Data를 대칭키로 변환
    /// - Parameter data: 키 데이터
    /// - Returns: 대칭키
    /// - Throws: 데이터 크기가 유효하지 않으면 에러
    func dataToKey(_ data: Data) throws -> SymmetricKey {
        guard data.count == 32 else { // 256 bits = 32 bytes
            throw SecurityError.invalidKey
        }
        return SymmetricKey(data: data)
    }
    
    /// 키체인에 대칭키 저장
    /// - Parameters:
    ///   - key: 저장할 대칭키
    ///   - identifier: 키 식별자
    func saveKeyToKeychain(_ key: SymmetricKey, identifier: String = "default") throws {
        let keyData = keyToData(key)
        try KeychainService.shared.saveEncryptionKey(keyData, identifier: identifier)
    }
    
    /// 키체인에서 대칭키 로드
    /// - Parameter identifier: 키 식별자
    /// - Returns: 대칭키 (없으면 nil)
    func loadKeyFromKeychain(identifier: String = "default") throws -> SymmetricKey? {
        guard let keyData = try KeychainService.shared.loadEncryptionKey(identifier: identifier) else {
            return nil
        }
        return try dataToKey(keyData)
    }
    
    /// 키체인에서 대칭키 로드하거나 새로 생성
    /// - Parameter identifier: 키 식별자
    /// - Returns: 대칭키
    func loadOrCreateKey(identifier: String = "default") throws -> SymmetricKey {
        if let existingKey = try loadKeyFromKeychain(identifier: identifier) {
            return existingKey
        }
        
        let newKey = generateSymmetricKey()
        try saveKeyToKeychain(newKey, identifier: identifier)
        return newKey
    }
    
    /// 키체인에서 대칭키 삭제
    func deleteKeyFromKeychain(identifier: String = "default") throws {
        try KeychainService.shared.deleteEncryptionKey(identifier: identifier)
    }
    
    // MARK: - AES-GCM 암호화
    
    /// AES-GCM으로 데이터 암호화
    /// - Parameters:
    ///   - data: 암호화할 데이터
    ///   - key: 암호화 키
    /// - Returns: (암호문, nonce, 인증 태그)
    func encryptAESGCM(
        _ data: Data,
        using key: SymmetricKey
    ) throws -> (ciphertext: Data, nonce: Data, tag: Data) {
        do {
            // 새 nonce 생성 (12바이트)
            let nonce = AES.GCM.Nonce()
            
            // 암호화
            let sealedBox = try AES.GCM.seal(data, using: key, nonce: nonce)
            
            guard let ciphertext = sealedBox.ciphertext.withUnsafeBytes({ Data($0) }) as Data?,
                  let tag = sealedBox.tag.withUnsafeBytes({ Data($0) }) as Data? else {
                throw SecurityError.encryptionFailed(underlying: nil)
            }
            
            let nonceData = Data(nonce)
            
            return (ciphertext, nonceData, tag)
        } catch let error as CryptoKitError {
            throw SecurityError.encryptionFailed(underlying: error)
        } catch {
            throw SecurityError.encryptionFailed(underlying: error)
        }
    }
    
    /// AES-GCM으로 데이터 복호화
    /// - Parameters:
    ///   - ciphertext: 암호문
    ///   - nonce: 암호화에 사용된 nonce
    ///   - tag: 인증 태그
    ///   - key: 복호화 키
    /// - Returns: 원본 데이터
    func decryptAESGCM(
        ciphertext: Data,
        nonce: Data,
        tag: Data,
        using key: SymmetricKey
    ) throws -> Data {
        do {
            // Nonce 재구성
            let gcmNonce = try AES.GCM.Nonce(data: nonce)
            
            // SealedBox 재구성
            let sealedBox = try AES.GCM.SealedBox(
                nonce: gcmNonce,
                ciphertext: ciphertext,
                tag: tag
            )
            
            // 복호화 (태그 검증 포함)
            return try AES.GCM.open(sealedBox, using: key)
        } catch CryptoKitError.authenticationFailure {
            // 태그 불일치 = 데이터 변조 가능성
            throw SecurityError.integrityCheckFailed
        } catch {
            throw SecurityError.decryptionFailed(underlying: error)
        }
    }
    
    /// 결합된 AES-GCM 암호화 (nonce + ciphertext + tag 하나로 결합)
    /// - Parameters:
    ///   - data: 암호화할 데이터
    ///   - key: 암호화 키
    /// - Returns: 결합된 암호화 데이터
    func encryptAESGCMCombined(_ data: Data, using key: SymmetricKey) throws -> Data {
        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            return sealedBox.combined!
        } catch {
            throw SecurityError.encryptionFailed(underlying: error)
        }
    }
    
    /// 결합된 AES-GCM 복호화
    /// - Parameters:
    ///   - combined: 결합된 암호화 데이터
    ///   - key: 복호화 키
    /// - Returns: 원본 데이터
    func decryptAESGCMCombined(_ combined: Data, using key: SymmetricKey) throws -> Data {
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: combined)
            return try AES.GCM.open(sealedBox, using: key)
        } catch CryptoKitError.authenticationFailure {
            throw SecurityError.integrityCheckFailed
        } catch {
            throw SecurityError.decryptionFailed(underlying: error)
        }
    }
    
    // MARK: - ChaChaPoly 암호화
    
    /// ChaChaPoly로 데이터 암호화
    /// - Note: AES-GCM의 대안으로, 일부 환경에서 더 빠름
    /// - Parameters:
    ///   - data: 암호화할 데이터
    ///   - key: 암호화 키
    /// - Returns: (암호문, nonce, 태그)
    func encryptChaCha(
        _ data: Data,
        using key: SymmetricKey
    ) throws -> (ciphertext: Data, nonce: Data, tag: Data) {
        do {
            let nonce = ChaChaPoly.Nonce()
            let sealedBox = try ChaChaPoly.seal(data, using: key, nonce: nonce)
            
            let nonceData = Data(nonce)
            let ciphertext = sealedBox.ciphertext
            let tag = sealedBox.tag
            
            return (ciphertext, nonceData, tag)
        } catch {
            throw SecurityError.encryptionFailed(underlying: error)
        }
    }
    
    /// ChaChaPoly로 데이터 복호화
    func decryptChaCha(
        ciphertext: Data,
        nonce: Data,
        tag: Data,
        using key: SymmetricKey
    ) throws -> Data {
        do {
            let chachaNonce = try ChaChaPoly.Nonce(data: nonce)
            let sealedBox = try ChaChaPoly.SealedBox(
                nonce: chachaNonce,
                ciphertext: ciphertext,
                tag: tag
            )
            return try ChaChaPoly.open(sealedBox, using: key)
        } catch CryptoKitError.authenticationFailure {
            throw SecurityError.integrityCheckFailed
        } catch {
            throw SecurityError.decryptionFailed(underlying: error)
        }
    }
    
    /// 결합된 ChaChaPoly 암호화
    func encryptChaChaCombined(_ data: Data, using key: SymmetricKey) throws -> Data {
        do {
            let sealedBox = try ChaChaPoly.seal(data, using: key)
            return sealedBox.combined
        } catch {
            throw SecurityError.encryptionFailed(underlying: error)
        }
    }
    
    /// 결합된 ChaChaPoly 복호화
    func decryptChaChaCombined(_ combined: Data, using key: SymmetricKey) throws -> Data {
        do {
            let sealedBox = try ChaChaPoly.SealedBox(combined: combined)
            return try ChaChaPoly.open(sealedBox, using: key)
        } catch CryptoKitError.authenticationFailure {
            throw SecurityError.integrityCheckFailed
        } catch {
            throw SecurityError.decryptionFailed(underlying: error)
        }
    }
    
    // MARK: - 해시 함수
    
    /// SHA-256 해시 계산
    /// - Parameter data: 해시할 데이터
    /// - Returns: 해시 값 (Data)
    func sha256(_ data: Data) -> Data {
        Data(SHA256.hash(data: data))
    }
    
    /// SHA-256 해시 (16진수 문자열)
    func sha256Hex(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
    
    /// SHA-256 해시 (문자열 입력)
    func sha256Hex(_ string: String) -> String {
        guard let data = string.data(using: .utf8) else { return "" }
        return sha256Hex(data)
    }
    
    /// SHA-512 해시 계산
    func sha512(_ data: Data) -> Data {
        Data(SHA512.hash(data: data))
    }
    
    /// SHA-512 해시 (16진수 문자열)
    func sha512Hex(_ data: Data) -> String {
        SHA512.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
    
    /// SHA-384 해시 계산
    func sha384(_ data: Data) -> Data {
        Data(SHA384.hash(data: data))
    }
    
    // MARK: - HMAC
    
    /// HMAC-SHA256 생성
    /// - Parameters:
    ///   - data: 인증할 데이터
    ///   - key: HMAC 키
    /// - Returns: 인증 코드 (Data)
    func hmacSHA256(_ data: Data, using key: SymmetricKey) -> Data {
        let authCode = HMAC<SHA256>.authenticationCode(for: data, using: key)
        return Data(authCode)
    }
    
    /// HMAC-SHA256 생성 (16진수 문자열)
    func hmacSHA256Hex(_ data: Data, using key: SymmetricKey) -> String {
        let authCode = HMAC<SHA256>.authenticationCode(for: data, using: key)
        return authCode.map { String(format: "%02x", $0) }.joined()
    }
    
    /// HMAC-SHA512 생성
    func hmacSHA512(_ data: Data, using key: SymmetricKey) -> Data {
        let authCode = HMAC<SHA512>.authenticationCode(for: data, using: key)
        return Data(authCode)
    }
    
    /// HMAC 검증
    /// - Parameters:
    ///   - data: 원본 데이터
    ///   - authCode: 검증할 인증 코드
    ///   - key: HMAC 키
    /// - Returns: 유효 여부
    func verifyHMAC(_ data: Data, authCode: Data, using key: SymmetricKey) -> Bool {
        HMAC<SHA256>.isValidAuthenticationCode(authCode, authenticating: data, using: key)
    }
    
    // MARK: - P256 비대칭 키 (Secure Enclave)
    
    /// Secure Enclave 사용 가능 여부
    var isSecureEnclaveAvailable: Bool {
        SecureEnclave.isAvailable
    }
    
    /// Secure Enclave에 P256 키 쌍 생성
    /// - Parameter requireBiometrics: 키 사용 시 생체 인증 필수 여부
    /// - Returns: 개인키 (Secure Enclave에 저장됨)
    func createSecureEnclaveKey(requireBiometrics: Bool = true) throws -> SecureEnclave.P256.Signing.PrivateKey {
        guard isSecureEnclaveAvailable else {
            throw SecurityError.secureEnclaveNotAvailable
        }
        
        do {
            // 접근 제어 설정
            var accessControl: SecAccessControl?
            
            if requireBiometrics {
                var error: Unmanaged<CFError>?
                accessControl = SecAccessControlCreateWithFlags(
                    kCFAllocatorDefault,
                    kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                    [.privateKeyUsage, .biometryCurrentSet],
                    &error
                )
                
                if let error = error?.takeRetainedValue() {
                    throw SecurityError.keyGenerationFailed(reason: error.localizedDescription)
                }
            }
            
            // 키 생성
            let privateKey: SecureEnclave.P256.Signing.PrivateKey
            
            if let accessControl = accessControl {
                privateKey = try SecureEnclave.P256.Signing.PrivateKey(
                    accessControl: accessControl
                )
            } else {
                privateKey = try SecureEnclave.P256.Signing.PrivateKey()
            }
            
            // 키 데이터 저장 (복원용)
            try saveSecureEnclaveKeyData(privateKey.dataRepresentation)
            
            return privateKey
        } catch let error as SecurityError {
            throw error
        } catch {
            throw SecurityError.secureEnclaveKeyGenerationFailed
        }
    }
    
    /// 저장된 Secure Enclave 키 로드
    func loadSecureEnclaveKey() throws -> SecureEnclave.P256.Signing.PrivateKey? {
        guard isSecureEnclaveAvailable else {
            return nil
        }
        
        guard let keyData = try loadSecureEnclaveKeyData() else {
            return nil
        }
        
        do {
            return try SecureEnclave.P256.Signing.PrivateKey(dataRepresentation: keyData)
        } catch {
            throw SecurityError.invalidKey
        }
    }
    
    /// Secure Enclave 키 데이터 저장
    private func saveSecureEnclaveKeyData(_ data: Data) throws {
        try KeychainService.shared.saveEncryptionKey(data, identifier: "secureenclave.p256")
    }
    
    /// Secure Enclave 키 데이터 로드
    private func loadSecureEnclaveKeyData() throws -> Data? {
        try KeychainService.shared.loadEncryptionKey(identifier: "secureenclave.p256")
    }
    
    /// Secure Enclave 키 삭제
    func deleteSecureEnclaveKey() throws {
        try KeychainService.shared.deleteEncryptionKey(identifier: "secureenclave.p256")
    }
    
    // MARK: - 일반 P256 키 (Secure Enclave 미사용)
    
    /// 일반 P256 키 쌍 생성
    func createP256Key() -> P256.Signing.PrivateKey {
        P256.Signing.PrivateKey()
    }
    
    /// P256 키를 PEM 형식으로 변환
    func keyToPEM(_ privateKey: P256.Signing.PrivateKey) -> String {
        privateKey.pemRepresentation
    }
    
    /// PEM에서 P256 키 복원
    func keyFromPEM(_ pem: String) throws -> P256.Signing.PrivateKey {
        do {
            return try P256.Signing.PrivateKey(pemRepresentation: pem)
        } catch {
            throw SecurityError.invalidKey
        }
    }
    
    // MARK: - P256 서명
    
    /// Secure Enclave 키로 서명 생성
    func signWithSecureEnclave(
        _ data: Data,
        privateKey: SecureEnclave.P256.Signing.PrivateKey
    ) throws -> Data {
        do {
            let signature = try privateKey.signature(for: data)
            return signature.rawRepresentation
        } catch {
            throw SecurityError.signatureCreationFailed
        }
    }
    
    /// 일반 P256 키로 서명 생성
    func sign(_ data: Data, with privateKey: P256.Signing.PrivateKey) throws -> Data {
        do {
            let signature = try privateKey.signature(for: data)
            return signature.rawRepresentation
        } catch {
            throw SecurityError.signatureCreationFailed
        }
    }
    
    /// P256 서명 검증
    func verifySignature(
        _ signature: Data,
        for data: Data,
        publicKey: P256.Signing.PublicKey
    ) -> Bool {
        guard let ecdsaSignature = try? P256.Signing.ECDSASignature(rawRepresentation: signature) else {
            return false
        }
        return publicKey.isValidSignature(ecdsaSignature, for: data)
    }
    
    /// Secure Enclave 공개키로 서명 검증
    func verifySignatureWithSecureEnclavePublicKey(
        _ signature: Data,
        for data: Data,
        privateKey: SecureEnclave.P256.Signing.PrivateKey
    ) -> Bool {
        guard let ecdsaSignature = try? P256.Signing.ECDSASignature(rawRepresentation: signature) else {
            return false
        }
        return privateKey.publicKey.isValidSignature(ecdsaSignature, for: data)
    }
    
    // MARK: - P256 키 교환 (ECDH)
    
    /// P256 키 교환용 키 쌍 생성
    func createKeyAgreementKey() -> P256.KeyAgreement.PrivateKey {
        P256.KeyAgreement.PrivateKey()
    }
    
    /// P256 키 교환 수행 (공유 비밀 생성)
    /// - Parameters:
    ///   - privateKey: 내 개인키
    ///   - publicKey: 상대방 공개키
    /// - Returns: 공유 비밀에서 파생된 대칭키
    func deriveSharedKey(
        privateKey: P256.KeyAgreement.PrivateKey,
        publicKey: P256.KeyAgreement.PublicKey
    ) throws -> SymmetricKey {
        do {
            let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: publicKey)
            
            // HKDF로 키 파생
            let derivedKey = sharedSecret.hkdfDerivedSymmetricKey(
                using: SHA256.self,
                salt: "SecureVault".data(using: .utf8)!,
                sharedInfo: Data(),
                outputByteCount: 32
            )
            
            return derivedKey
        } catch {
            throw SecurityError.keyGenerationFailed(reason: "키 교환 실패")
        }
    }
    
    // MARK: - 편의 메서드
    
    /// 문자열 암호화 (AES-GCM, 기본 키 사용)
    func encryptString(_ string: String) throws -> Data {
        guard let data = string.data(using: .utf8) else {
            throw SecurityError.dataEncodingFailed(underlying: nil)
        }
        
        let key = try loadOrCreateKey()
        return try encryptAESGCMCombined(data, using: key)
    }
    
    /// 데이터를 문자열로 복호화
    func decryptToString(_ encryptedData: Data) throws -> String {
        let key = try loadOrCreateKey()
        let decryptedData = try decryptAESGCMCombined(encryptedData, using: key)
        
        guard let string = String(data: decryptedData, encoding: .utf8) else {
            throw SecurityError.dataDecodingFailed(underlying: nil)
        }
        
        return string
    }
    
    /// SecretItem 콘텐츠 암호화
    func encryptSecretContent(_ secret: SecretItem) throws -> SecretItem {
        let key = try loadOrCreateKey()
        
        guard let contentData = secret.content.data(using: .utf8) else {
            throw SecurityError.dataEncodingFailed(underlying: nil)
        }
        
        let (ciphertext, nonce, tag) = try encryptAESGCM(contentData, using: key)
        
        var encrypted = secret
        encrypted.content = ciphertext.base64EncodedString()
        encrypted.isEncrypted = true
        encrypted.encryptionKeyId = defaultKeyIdentifier
        encrypted.encryptionNonce = nonce
        encrypted.authTag = tag
        encrypted.contentHash = sha256Hex(contentData)
        
        return encrypted
    }
    
    /// SecretItem 콘텐츠 복호화
    func decryptSecretContent(_ secret: SecretItem) throws -> SecretItem {
        guard secret.isEncrypted else {
            return secret
        }
        
        guard let nonce = secret.encryptionNonce,
              let tag = secret.authTag,
              let ciphertext = Data(base64Encoded: secret.content) else {
            throw SecurityError.dataDecodingFailed(underlying: nil)
        }
        
        let keyId = secret.encryptionKeyId ?? defaultKeyIdentifier
        
        guard let key = try loadKeyFromKeychain(identifier: keyId) else {
            throw SecurityError.invalidKey
        }
        
        let decryptedData = try decryptAESGCM(
            ciphertext: ciphertext,
            nonce: nonce,
            tag: tag,
            using: key
        )
        
        guard let content = String(data: decryptedData, encoding: .utf8) else {
            throw SecurityError.dataDecodingFailed(underlying: nil)
        }
        
        // 무결성 검증
        if let savedHash = secret.contentHash {
            let currentHash = sha256Hex(decryptedData)
            guard savedHash == currentHash else {
                throw SecurityError.integrityCheckFailed
            }
        }
        
        var decrypted = secret
        decrypted.content = content
        decrypted.isEncrypted = false
        
        return decrypted
    }
    
    // MARK: - 키 파생
    
    /// 비밀번호 기반 키 파생 (PBKDF2 대체용 HKDF)
    /// - Note: 실제 PBKDF2가 필요하면 Security 프레임워크 사용
    func deriveKeyFromPassword(
        _ password: String,
        salt: Data
    ) -> SymmetricKey {
        guard let passwordData = password.data(using: .utf8) else {
            return generateSymmetricKey()
        }
        
        let inputKey = SymmetricKey(data: passwordData)
        
        // HKDF 사용 (CryptoKit에서는 PBKDF2 미지원)
        return HKDF<SHA256>.deriveKey(
            inputKeyMaterial: inputKey,
            salt: salt,
            info: "SecureVault.KeyDerivation".data(using: .utf8)!,
            outputByteCount: 32
        )
    }
    
    /// 랜덤 salt 생성
    func generateSalt(length: Int = 32) -> Data {
        var bytes = [UInt8](repeating: 0, count: length)
        _ = SecRandomCopyBytes(kSecRandomDefault, length, &bytes)
        return Data(bytes)
    }
}

// MARK: - 암호화 알고리즘 열거형
extension CryptoService {
    /// 지원하는 암호화 알고리즘
    enum Algorithm: String, CaseIterable, Identifiable, Codable {
        case aesGCM = "AES-GCM"
        case chaChaPoly = "ChaCha20-Poly1305"
        
        var id: String { rawValue }
        
        var displayName: String {
            switch self {
            case .aesGCM:
                return "AES-256-GCM"
            case .chaChaPoly:
                return "ChaCha20-Poly1305"
            }
        }
        
        var description: String {
            switch self {
            case .aesGCM:
                return "표준 대칭키 암호화. 대부분의 환경에서 하드웨어 가속 지원."
            case .chaChaPoly:
                return "AES 대안. 소프트웨어 구현에서 빠르고 안전함."
            }
        }
    }
    
    /// 지원하는 해시 알고리즘
    enum HashAlgorithm: String, CaseIterable, Identifiable {
        case sha256 = "SHA-256"
        case sha384 = "SHA-384"
        case sha512 = "SHA-512"
        
        var id: String { rawValue }
        
        var outputSize: Int {
            switch self {
            case .sha256: return 32
            case .sha384: return 48
            case .sha512: return 64
            }
        }
    }
}

// MARK: - 미리보기/테스트 지원
#if DEBUG
extension CryptoService {
    /// 테스트용 고정 키 생성
    static var testKey: SymmetricKey {
        let testData = Data(repeating: 0xAB, count: 32)
        return SymmetricKey(data: testData)
    }
    
    /// 암호화 테스트
    static func test() {
        let service = CryptoService.shared
        let testData = "Hello, SecureVault!".data(using: .utf8)!
        
        print("=== CryptoService Test ===")
        
        // SHA256
        let hash = service.sha256Hex(testData)
        print("SHA256: \(hash)")
        
        // AES-GCM
        do {
            let key = service.generateSymmetricKey()
            let encrypted = try service.encryptAESGCMCombined(testData, using: key)
            let decrypted = try service.decryptAESGCMCombined(encrypted, using: key)
            print("AES-GCM: \(String(data: decrypted, encoding: .utf8)!)")
        } catch {
            print("AES-GCM Error: \(error)")
        }
        
        // Secure Enclave
        print("Secure Enclave Available: \(service.isSecureEnclaveAvailable)")
        
        print("==========================")
    }
}
#endif
