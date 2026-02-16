import CryptoKit
import Foundation

// SHA256 해시 생성
let message = "암호화할 메시지"
let messageData = Data(message.utf8)

let hash = SHA256.hash(data: messageData)
print("SHA256: \(hash)")
// 출력: SHA256 digest: 64바이트 해시값
