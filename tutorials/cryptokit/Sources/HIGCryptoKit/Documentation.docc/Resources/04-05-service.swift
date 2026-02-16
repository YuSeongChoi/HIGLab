import CryptoKit
import Foundation

// 메시지 암호화 서비스
actor EncryptionService {
    private let key: SymmetricKey
    
    init() {
        self.key = SymmetricKey(size: .bits256)
    }
    
    func encrypt(_ message: String) throws -> Data {
        let data = Data(message.utf8)
        let sealed = try AES.GCM.seal(data, using: key)
        return sealed.combined!
    }
    
    func decrypt(_ data: Data) throws -> String {
        let sealed = try AES.GCM.SealedBox(combined: data)
        let decrypted = try AES.GCM.open(sealed, using: key)
        return String(data: decrypted, encoding: .utf8)!
    }
}
