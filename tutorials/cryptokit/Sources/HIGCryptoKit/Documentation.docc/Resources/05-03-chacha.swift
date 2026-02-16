import CryptoKit
import Foundation

// ChaChaPoly - AES 대안
// 하드웨어 가속이 없는 환경에서 AES보다 빠름
let key = SymmetricKey(size: .bits256)
let message = Data("ChaChaPoly 테스트".utf8)

// 암호화
let sealedBox = try! ChaChaPoly.seal(message, using: key)

// 복호화
let decrypted = try! ChaChaPoly.open(sealedBox, using: key)
print("복호화: \(String(data: decrypted, encoding: .utf8)!)")

// AES-GCM과 동일한 SealedBox 인터페이스
print("Combined: \(sealedBox.combined.base64EncodedString())")
