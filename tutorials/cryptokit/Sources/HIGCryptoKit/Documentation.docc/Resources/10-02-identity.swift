import CryptoKit
import Foundation

// 사용자 신원 관리
actor UserIdentity {
    let userId: String
    private let keyAgreementKey: Curve25519.KeyAgreement.PrivateKey
    private let signingKey: Curve25519.Signing.PrivateKey
    
    init(userId: String) {
        self.userId = userId
        self.keyAgreementKey = Curve25519.KeyAgreement.PrivateKey()
        self.signingKey = Curve25519.Signing.PrivateKey()
    }
    
    var publicBundle: PublicKeyBundle {
        PublicKeyBundle(
            keyAgreement: keyAgreementKey.publicKey.rawRepresentation,
            signing: signingKey.publicKey.rawRepresentation,
            userId: userId
        )
    }
    
    func createSharedSecret(with theirKey: Data) throws -> SharedSecret {
        let publicKey = try Curve25519.KeyAgreement.PublicKey(rawRepresentation: theirKey)
        return try keyAgreementKey.sharedSecretFromKeyAgreement(with: publicKey)
    }
    
    func sign(_ data: Data) throws -> Data {
        try signingKey.signature(for: data)
    }
}
