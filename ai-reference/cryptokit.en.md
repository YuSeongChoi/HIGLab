# CryptoKit AI Reference

> Encryption and hashing guide. Read this document to generate CryptoKit code.

## Overview

CryptoKit is a Swift-native framework for encryption, hashing, and key management.
It supports AES, SHA, HMAC, public key cryptography, and more.

## Required Import

```swift
import CryptoKit
```

## Core Components

### 1. Hashing

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

### 2. Symmetric Encryption (AES-GCM)

```swift
// Key generation
let key = SymmetricKey(size: .bits256)

// Encryption
func encrypt(data: Data, key: SymmetricKey) throws -> Data {
    let sealedBox = try AES.GCM.seal(data, using: key)
    return sealedBox.combined!
}

// Decryption
func decrypt(data: Data, key: SymmetricKey) throws -> Data {
    let sealedBox = try AES.GCM.SealedBox(combined: data)
    return try AES.GCM.open(sealedBox, using: key)
}
```

### 3. HMAC (Message Authentication)

```swift
let key = SymmetricKey(size: .bits256)
let data = "message".data(using: .utf8)!

// Generate HMAC
let authCode = HMAC<SHA256>.authenticationCode(for: data, using: key)
let authString = Data(authCode).base64EncodedString()

// Verify HMAC
let isValid = HMAC<SHA256>.isValidAuthenticationCode(authCode, authenticating: data, using: key)
```

## Complete Working Example

```swift
import SwiftUI
import CryptoKit

// MARK: - Crypto Manager
class CryptoManager {
    private var key: SymmetricKey
    
    init() {
        // Load or generate key
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
        case .encodingFailed: return "Encoding failed"
        case .decodingFailed: return "Decoding failed"
        case .encryptionFailed: return "Encryption failed"
        case .decryptionFailed: return "Decryption failed"
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
                Section("Input") {
                    TextField("Enter text", text: $inputText)
                }
                
                Section("Encryption") {
                    Button("Encrypt") {
                        encryptedText = (try? crypto.encrypt(inputText)) ?? "Failed"
                    }
                    .disabled(inputText.isEmpty)
                    
                    if !encryptedText.isEmpty {
                        Text(encryptedText)
                            .font(.caption)
                            .textSelection(.enabled)
                    }
                    
                    Button("Decrypt") {
                        decryptedText = (try? crypto.decrypt(encryptedText)) ?? "Failed"
                    }
                    .disabled(encryptedText.isEmpty)
                    
                    if !decryptedText.isEmpty {
                        Text("Result: \(decryptedText)")
                            .foregroundStyle(.green)
                    }
                }
                
                Section("Hashing (SHA-256)") {
                    Button("Generate Hash") {
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
            .navigationTitle("Encryption")
        }
    }
}
```

## Advanced Patterns

### 1. Public Key Cryptography (P256)

```swift
// Generate key pair
let privateKey = P256.KeyAgreement.PrivateKey()
let publicKey = privateKey.publicKey

// Serialize keys
let publicKeyData = publicKey.rawRepresentation
let privateKeyData = privateKey.rawRepresentation

// Restore keys
let restoredPublic = try P256.KeyAgreement.PublicKey(rawRepresentation: publicKeyData)
let restoredPrivate = try P256.KeyAgreement.PrivateKey(rawRepresentation: privateKeyData)
```

### 2. Key Exchange (Diffie-Hellman)

```swift
// Alice's keys
let alicePrivate = P256.KeyAgreement.PrivateKey()
let alicePublic = alicePrivate.publicKey

// Bob's keys
let bobPrivate = P256.KeyAgreement.PrivateKey()
let bobPublic = bobPrivate.publicKey

// Generate shared secret
let aliceShared = try alicePrivate.sharedSecretFromKeyAgreement(with: bobPublic)
let bobShared = try bobPrivate.sharedSecretFromKeyAgreement(with: alicePublic)

// Derive symmetric key
let symmetricKey = aliceShared.hkdfDerivedSymmetricKey(
    using: SHA256.self,
    salt: Data(),
    sharedInfo: Data("encryption".utf8),
    outputByteCount: 32
)
```

### 3. Digital Signatures

```swift
// Sign
let signingKey = P256.Signing.PrivateKey()
let data = "Sign this message".data(using: .utf8)!
let signature = try signingKey.signature(for: data)

// Verify
let verifyingKey = signingKey.publicKey
let isValid = verifyingKey.isValidSignature(signature, for: data)
```

### 4. ChaCha20-Poly1305 (Alternative Encryption)

```swift
let key = SymmetricKey(size: .bits256)
let data = "Secret message".data(using: .utf8)!

// Encrypt
let sealedBox = try ChaChaPoly.seal(data, using: key)

// Decrypt
let decrypted = try ChaChaPoly.open(sealedBox, using: key)
```

## Important Notes

1. **Key Storage**
   - Never store in plaintext
   - Recommend using Keychain
   - Use Secure Enclave when possible

2. **Random Generation**
   ```swift
   // Secure random
   var randomBytes = [UInt8](repeating: 0, count: 32)
   _ = SecRandomCopyBytes(kSecRandomDefault, 32, &randomBytes)
   
   // Or
   let key = SymmetricKey(size: .bits256)  // Uses secure random internally
   ```

3. **Hash Usage**
   - SHA-256: General hashing
   - Passwords: Recommend salt + iterative hashing or Argon2

4. **Performance**
   - CryptoKit utilizes hardware acceleration
   - Use streaming for large data
   ```swift
   var hasher = SHA256()
   hasher.update(data: chunk1)
   hasher.update(data: chunk2)
   let hash = hasher.finalize()
   ```
