import Foundation
import SwiftData
import CryptoKit

@Model
final class SecureNote {
    var title: String
    var encryptedContent: Data
    var nonce: Data
    var tag: Data
    var createdAt: Date
    var updatedAt: Date
    
    init(title: String, content: String, key: SymmetricKey) throws {
        self.title = title
        self.createdAt = Date()
        self.updatedAt = Date()
        
        // AES-GCM 암호화
        let contentData = Data(content.utf8)
        let sealedBox = try AES.GCM.seal(contentData, using: key)
        
        self.encryptedContent = sealedBox.ciphertext
        self.nonce = Data(sealedBox.nonce)
        self.tag = sealedBox.tag
    }
    
    func decrypt(with key: SymmetricKey) throws -> String {
        let nonce = try AES.GCM.Nonce(data: self.nonce)
        let sealedBox = try AES.GCM.SealedBox(nonce: nonce, ciphertext: encryptedContent, tag: tag)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        return String(data: decryptedData, encoding: .utf8) ?? ""
    }
    
    func update(content: String, key: SymmetricKey) throws {
        let contentData = Data(content.utf8)
        let sealedBox = try AES.GCM.seal(contentData, using: key)
        
        self.encryptedContent = sealedBox.ciphertext
        self.nonce = Data(sealedBox.nonce)
        self.tag = sealedBox.tag
        self.updatedAt = Date()
    }
}
