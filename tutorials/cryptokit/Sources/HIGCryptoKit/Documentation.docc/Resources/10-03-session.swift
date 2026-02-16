import CryptoKit
import Foundation

// 세션 키 관리
actor SessionManager {
    private var sessions: [String: SymmetricKey] = [:]
    
    func getOrCreateSession(
        myKey: Curve25519.KeyAgreement.PrivateKey,
        theirKey: Curve25519.KeyAgreement.PublicKey,
        sessionId: String
    ) throws -> SymmetricKey {
        if let existing = sessions[sessionId] {
            return existing
        }
        
        let shared = try myKey.sharedSecretFromKeyAgreement(with: theirKey)
        let sessionKey = shared.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: Data(sessionId.utf8),
            sharedInfo: Data("SessionKey".utf8),
            outputByteCount: 32
        )
        
        sessions[sessionId] = sessionKey
        return sessionKey
    }
    
    func invalidateSession(_ sessionId: String) {
        sessions.removeValue(forKey: sessionId)
    }
}
