import CryptoKit
import Foundation

// 수신한 메시지 복호화
struct SecureMessage: Codable {
    let payload: String
    let timestamp: Date
}

func receiveMessage(_ secureMsg: SecureMessage, key: SymmetricKey) throws -> String {
    guard let data = Data(base64Encoded: secureMsg.payload) else {
        throw CryptoKitError.authenticationFailure
    }
    
    let sealedBox = try AES.GCM.SealedBox(combined: data)
    let decrypted = try AES.GCM.open(sealedBox, using: key)
    
    return String(data: decrypted, encoding: .utf8)!
}
