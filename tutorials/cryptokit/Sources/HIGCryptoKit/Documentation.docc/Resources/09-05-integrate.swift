import CryptoKit
import Foundation

// 메시지 앱 Secure Enclave 통합
actor SecureIdentity {
    private let signingKey: SecureEnclave.P256.Signing.PrivateKey?
    private let fallbackKey: P256.Signing.PrivateKey
    
    init() throws {
        if SecureEnclave.isAvailable {
            self.signingKey = try SecureEnclave.P256.Signing.PrivateKey()
            self.fallbackKey = P256.Signing.PrivateKey() // 미사용
        } else {
            self.signingKey = nil
            self.fallbackKey = P256.Signing.PrivateKey()
        }
    }
    
    var publicKey: P256.Signing.PublicKey {
        signingKey?.publicKey ?? fallbackKey.publicKey
    }
    
    func sign(_ message: Data) throws -> P256.Signing.ECDSASignature {
        if let seKey = signingKey {
            return try seKey.signature(for: message)
        }
        return try fallbackKey.signature(for: message)
    }
    
    var isHardwareBacked: Bool {
        signingKey != nil
    }
}
