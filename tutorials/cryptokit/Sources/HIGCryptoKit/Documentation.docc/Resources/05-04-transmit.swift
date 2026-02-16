import CryptoKit
import Foundation

// 메시지 전송 - 암호화 후 Base64 인코딩
struct SecureMessage: Codable {
    let payload: String // Base64 인코딩된 암호문
    let timestamp: Date
}

func prepareForTransmit(_ message: String, key: SymmetricKey) throws -> SecureMessage {
    let sealed = try AES.GCM.seal(Data(message.utf8), using: key)
    return SecureMessage(
        payload: sealed.combined!.base64EncodedString(),
        timestamp: Date()
    )
}

let key = SymmetricKey(size: .bits256)
let secureMsg = try! prepareForTransmit("안녕하세요!", key: key)
print("전송 준비: \(secureMsg.payload)")
