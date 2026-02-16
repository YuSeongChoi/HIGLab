import CryptoKit
import Foundation

// 사용자 키 관리자
actor UserKeyManager {
    private var keyAgreementKey: Curve25519.KeyAgreement.PrivateKey
    private var signingKey: Curve25519.Signing.PrivateKey
    
    init() {
        self.keyAgreementKey = Curve25519.KeyAgreement.PrivateKey()
        self.signingKey = Curve25519.Signing.PrivateKey()
    }
    
    var publicKeyAgreementKey: Curve25519.KeyAgreement.PublicKey {
        keyAgreementKey.publicKey
    }
    
    var publicSigningKey: Curve25519.Signing.PublicKey {
        signingKey.publicKey
    }
    
    // 키 번들 (상대방에게 전송)
    var keyBundle: Data {
        var data = Data()
        data.append(keyAgreementKey.publicKey.rawRepresentation)
        data.append(signingKey.publicKey.rawRepresentation)
        return data
    }
}
