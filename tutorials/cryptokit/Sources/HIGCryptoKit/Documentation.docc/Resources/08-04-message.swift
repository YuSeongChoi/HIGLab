import CryptoKit
import Foundation

// 서명된 메시지 구조
struct SignedMessage: Codable {
    let content: String
    let signature: Data
    let senderPublicKey: Data
    let timestamp: Date
    
    init(content: String, signingKey: Curve25519.Signing.PrivateKey) throws {
        self.content = content
        self.signature = try signingKey.signature(for: Data(content.utf8))
        self.senderPublicKey = signingKey.publicKey.rawRepresentation
        self.timestamp = Date()
    }
    
    func verify() throws -> Bool {
        let publicKey = try Curve25519.Signing.PublicKey(
            rawRepresentation: senderPublicKey
        )
        return publicKey.isValidSignature(signature, for: Data(content.utf8))
    }
}
