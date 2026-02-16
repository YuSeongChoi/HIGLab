import CryptoKit
import Foundation

// 해시를 16진수 문자열로 변환
let message = "암호화할 메시지"
let hash = SHA256.hash(data: Data(message.utf8))

let hexString = hash.compactMap { String(format: "%02x", $0) }.joined()
print("Hex: \(hexString)")
// 64자리 16진수 문자열 출력
