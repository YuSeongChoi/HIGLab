# CryptoKit AI Reference

> 암호화 및 해싱 가이드. 이 문서를 읽고 CryptoKit 코드를 생성할 수 있습니다.

## 개요

CryptoKit은 암호화, 해싱, 키 관리를 위한 Swift 네이티브 프레임워크입니다.
AES, SHA, HMAC, 공개키 암호화 등을 지원합니다.

## 필수 Import

```swift
import CryptoKit
```

## 핵심 구성요소

### 1. 해싱 (Hash)

```swift
// SHA-256
let data = "Hello, World!".data(using: .utf8)!
let hash = SHA256.hash(data: data)
let hashString = hash.compactMap { String(format: "%02x", $0) }.joined()

// SHA-384
let hash384 = SHA384.hash(data: data)

// SHA-512
let hash512 = SHA512.hash(data: data)
```

### 2. 대칭 암호화 (AES-GCM)

```swift
// 키 생성
let key = SymmetricKey(size: .bits256)

// 암호화
func encrypt(data: Data, key: SymmetricKey) throws -> Data {
    let sealedBox = try AES.GCM.seal(data, using: key)
    return sealedBox.combined!
}

// 복호화
func decrypt(data: Data, key: SymmetricKey) throws -> Data {
    let sealedBox = try AES.GCM.SealedBox(combined: data)
    return try AES.GCM.open(sealedBox, using: key)
}
```

### 3. HMAC (메시지 인증)

```swift
let key = SymmetricKey(size: .bits256)
let data = "message".data(using: .utf8)!

// HMAC 생성
let authCode = HMAC<SHA256>.authenticationCode(for: data, using: key)
let authString = Data(authCode).base64EncodedString()

// HMAC 검증
let isValid = HMAC<SHA256>.isValidAuthenticationCode(authCode, authenticating: data, using: key)
```

## 전체 작동 예제

```swift
import SwiftUI
import CryptoKit

// MARK: - Crypto Manager
class CryptoManager {
    private var key: SymmetricKey
    
    init() {
        // 키 로드 또는 생성
        if let savedKey = Self.loadKey() {
            key = savedKey
        } else {
            key = SymmetricKey(size: .bits256)
            Self.saveKey(key)
        }
    }
    
    // MARK: - Encryption
    func encrypt(_ string: String) throws -> String {
        guard let data = string.data(using: .utf8) else {
            throw CryptoError.encodingFailed
        }
        
        let sealedBox = try AES.GCM.seal(data, using: key)
        
        guard let combined = sealedBox.combined else {
            throw CryptoError.encryptionFailed
        }
        
        return combined.base64EncodedString()
    }
    
    func decrypt(_ base64String: String) throws -> String {
        guard let data = Data(base64Encoded: base64String) else {
            throw CryptoError.decodingFailed
        }
        
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        
        guard let string = String(data: decryptedData, encoding: .utf8) else {
            throw CryptoError.decodingFailed
        }
        
        return string
    }
    
    // MARK: - Hashing
    func hash(_ string: String) -> String {
        let data = Data(string.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    func verifyHash(_ string: String, against hashString: String) -> Bool {
        return hash(string) == hashString
    }
    
    // MARK: - Password Hashing (with salt)
    func hashPassword(_ password: String, salt: Data? = nil) -> (hash: String, salt: String) {
        let saltData = salt ?? Self.generateSalt()
        
        var passwordData = Data(password.utf8)
        passwordData.append(saltData)
        
        let hash = SHA256.hash(data: passwordData)
        let hashString = hash.compactMap { String(format: "%02x", $0) }.joined()
        let saltString = saltData.base64EncodedString()
        
        return (hashString, saltString)
    }
    
    func verifyPassword(_ password: String, hash: String, salt: String) -> Bool {
        guard let saltData = Data(base64Encoded: salt) else { return false }
        let result = hashPassword(password, salt: saltData)
        return result.hash == hash
    }
    
    // MARK: - Key Management
    private static func generateSalt() -> Data {
        var salt = Data(count: 16)
        _ = salt.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, 16, $0.baseAddress!) }
        return salt
    }
    
    private static func saveKey(_ key: SymmetricKey) {
        let keyData = key.withUnsafeBytes { Data($0) }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "encryptionKey",
            kSecValueData as String: keyData
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private static func loadKey() -> SymmetricKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "encryptionKey",
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let keyData = result as? Data else {
            return nil
        }
        
        return SymmetricKey(data: keyData)
    }
}

enum CryptoError: Error, LocalizedError {
    case encodingFailed
    case decodingFailed
    case encryptionFailed
    case decryptionFailed
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed: return "인코딩 실패"
        case .decodingFailed: return "디코딩 실패"
        case .encryptionFailed: return "암호화 실패"
        case .decryptionFailed: return "복호화 실패"
        }
    }
}

// MARK: - View
struct CryptoView: View {
    @State private var crypto = CryptoManager()
    @State private var inputText = ""
    @State private var encryptedText = ""
    @State private var decryptedText = ""
    @State private var hashText = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("입력") {
                    TextField("텍스트 입력", text: $inputText)
                }
                
                Section("암호화") {
                    Button("암호화") {
                        encryptedText = (try? crypto.encrypt(inputText)) ?? "실패"
                    }
                    .disabled(inputText.isEmpty)
                    
                    if !encryptedText.isEmpty {
                        Text(encryptedText)
                            .font(.caption)
                            .textSelection(.enabled)
                    }
                    
                    Button("복호화") {
                        decryptedText = (try? crypto.decrypt(encryptedText)) ?? "실패"
                    }
                    .disabled(encryptedText.isEmpty)
                    
                    if !decryptedText.isEmpty {
                        Text("결과: \(decryptedText)")
                            .foregroundStyle(.green)
                    }
                }
                
                Section("해싱 (SHA-256)") {
                    Button("해시 생성") {
                        hashText = crypto.hash(inputText)
                    }
                    .disabled(inputText.isEmpty)
                    
                    if !hashText.isEmpty {
                        Text(hashText)
                            .font(.caption.monospaced())
                            .textSelection(.enabled)
                    }
                }
            }
            .navigationTitle("암호화")
        }
    }
}
```

## 고급 패턴

### 1. 공개키 암호화 (P256)

```swift
// 키 쌍 생성
let privateKey = P256.KeyAgreement.PrivateKey()
let publicKey = privateKey.publicKey

// 키 직렬화
let publicKeyData = publicKey.rawRepresentation
let privateKeyData = privateKey.rawRepresentation

// 키 복원
let restoredPublic = try P256.KeyAgreement.PublicKey(rawRepresentation: publicKeyData)
let restoredPrivate = try P256.KeyAgreement.PrivateKey(rawRepresentation: privateKeyData)
```

### 2. 키 교환 (Diffie-Hellman)

```swift
// Alice의 키
let alicePrivate = P256.KeyAgreement.PrivateKey()
let alicePublic = alicePrivate.publicKey

// Bob의 키
let bobPrivate = P256.KeyAgreement.PrivateKey()
let bobPublic = bobPrivate.publicKey

// 공유 비밀 생성
let aliceShared = try alicePrivate.sharedSecretFromKeyAgreement(with: bobPublic)
let bobShared = try bobPrivate.sharedSecretFromKeyAgreement(with: alicePublic)

// 대칭키 도출
let symmetricKey = aliceShared.hkdfDerivedSymmetricKey(
    using: SHA256.self,
    salt: Data(),
    sharedInfo: Data("encryption".utf8),
    outputByteCount: 32
)
```

### 3. 디지털 서명

```swift
// 서명
let signingKey = P256.Signing.PrivateKey()
let data = "Sign this message".data(using: .utf8)!
let signature = try signingKey.signature(for: data)

// 검증
let verifyingKey = signingKey.publicKey
let isValid = verifyingKey.isValidSignature(signature, for: data)
```

### 4. ChaCha20-Poly1305 (대안 암호화)

```swift
let key = SymmetricKey(size: .bits256)
let data = "Secret message".data(using: .utf8)!

// 암호화
let sealedBox = try ChaChaPoly.seal(data, using: key)

// 복호화
let decrypted = try ChaChaPoly.open(sealedBox, using: key)
```

## 주의사항

1. **키 저장**
   - 평문으로 저장 금지
   - Keychain 사용 권장
   - Secure Enclave 활용 (가능 시)

2. **랜덤 생성**
   ```swift
   // 안전한 랜덤
   var randomBytes = [UInt8](repeating: 0, count: 32)
   _ = SecRandomCopyBytes(kSecRandomDefault, 32, &randomBytes)
   
   // 또는
   let key = SymmetricKey(size: .bits256)  // 내부적으로 안전한 랜덤 사용
   ```

3. **해시 용도**
   - SHA-256: 일반 해싱
   - 비밀번호: salt + 반복 해싱 또는 Argon2 권장

4. **성능**
   - CryptoKit은 하드웨어 가속 활용
   - 대용량 데이터는 스트리밍 처리
   ```swift
   var hasher = SHA256()
   hasher.update(data: chunk1)
   hasher.update(data: chunk2)
   let hash = hasher.finalize()
   ```
