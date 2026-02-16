import CryptoKit
import Foundation

// SHA512 vs SHA256 비교
let message = "비교 테스트"
let data = Data(message.utf8)

let sha256 = SHA256.hash(data: data)
let sha512 = SHA512.hash(data: data)

print("SHA256: \(sha256.count * 8)비트") // 256비트
print("SHA512: \(sha512.count * 8)비트") // 512비트
