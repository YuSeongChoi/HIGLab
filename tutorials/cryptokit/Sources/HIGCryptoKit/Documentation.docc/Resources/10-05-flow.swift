import CryptoKit
import Foundation

// 전체 암호화 흐름
actor SecureMessenger {
    private let identity: UserIdentity
    private let sessionManager = SessionManager()
    
    init(userId: String) {
        self.identity = UserIdentity(userId: userId)
    }
    
    func sendMessage(
        _ content: String,
        to recipient: PublicKeyBundle
    ) async throws -> SecureEnvelope {
        // 1. 일회용 키 생성
        let ephemeral = Curve25519.KeyAgreement.PrivateKey()
        
        // 2. 공유 비밀 → 세션 키
        let recipientKey = try Curve25519.KeyAgreement.PublicKey(
            rawRepresentation: recipient.keyAgreement
        )
        let shared = try ephemeral.sharedSecretFromKeyAgreement(with: recipientKey)
        let sessionKey = shared.hkdfDerivedSymmetricKey(
            using: SHA256.self, salt: Data(), sharedInfo: Data(), outputByteCount: 32
        )
        
        // 3. 암호화
        let sealed = try AES.GCM.seal(Data(content.utf8), using: sessionKey)
        
        // 4. 서명
        let signature = try await identity.sign(sealed.combined!)
        
        return SecureEnvelope(
            senderId: await identity.userId,
            recipientId: recipient.userId,
            timestamp: Date(),
            ephemeralPublicKey: ephemeral.publicKey.rawRepresentation,
            encryptedContent: sealed.combined!,
            signature: signature
        )
    }
}
