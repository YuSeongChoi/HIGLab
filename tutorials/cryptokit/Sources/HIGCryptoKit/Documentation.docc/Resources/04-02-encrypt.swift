import CryptoKit
import Foundation

// AES-GCM 암호화
let key = SymmetricKey(size: .bits256)
let message = "비밀 메시지입니다"
let messageData = Data(message.utf8)

do {
    let sealedBox = try AES.GCM.seal(messageData, using: key)
    
    // combined: nonce + ciphertext + tag
    if let combined = sealedBox.combined {
        print("암호화 완료: \(combined.base64EncodedString())")
    }
} catch {
    print("암호화 실패: \(error)")
}
