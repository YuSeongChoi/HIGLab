import CryptoKit
import Foundation

// HMAC 생성
let key = SymmetricKey(size: .bits256)
let message = "인증할 메시지"
let messageData = Data(message.utf8)

let hmac = HMAC<SHA256>.authenticationCode(for: messageData, using: key)
print("HMAC: \(Data(hmac).base64EncodedString())")
