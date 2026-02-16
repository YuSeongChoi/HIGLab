import CryptoKit
import Foundation

// HMAC 검증
let key = SymmetricKey(size: .bits256)
let message = "인증할 메시지"
let messageData = Data(message.utf8)

// HMAC 생성
let hmac = HMAC<SHA256>.authenticationCode(for: messageData, using: key)

// 검증 (동일한 키와 메시지로)
let isValid = HMAC<SHA256>.isValidAuthenticationCode(
    hmac,
    authenticating: messageData,
    using: key
)
print("검증 결과: \(isValid)") // true
