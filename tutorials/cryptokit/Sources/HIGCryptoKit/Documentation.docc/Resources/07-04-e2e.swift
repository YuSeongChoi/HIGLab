import CryptoKit
import Foundation

// E2E 암호화 통합
struct E2EChannel {
    let myPrivateKey: Curve25519.KeyAgreement.PrivateKey
    let theirPublicKey: Curve25519.KeyAgreement.PublicKey
    
    private var symmetricKey: SymmetricKey {
        let shared = try! myPrivateKey.sharedSecretFromKeyAgreement(with: theirPublicKey)
        return shared.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: Data(),
            sharedInfo: Data("E2E".utf8),
            outputByteCount: 32
        )
    }
    
    func encrypt(_ message: String) throws -> Data {
        let sealed = try AES.GCM.seal(Data(message.utf8), using: symmetricKey)
        return sealed.combined!
    }
    
    func decrypt(_ data: Data) throws -> String {
        let sealed = try AES.GCM.SealedBox(combined: data)
        let decrypted = try AES.GCM.open(sealed, using: symmetricKey)
        return String(data: decrypted, encoding: .utf8)!
    }
}
