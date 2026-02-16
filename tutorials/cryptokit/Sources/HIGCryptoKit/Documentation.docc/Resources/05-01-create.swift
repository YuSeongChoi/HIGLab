import CryptoKit
import Foundation

// Sealed Box 구조 이해
let key = SymmetricKey(size: .bits256)
let message = Data("Sealed Box 테스트".utf8)

let sealedBox = try! AES.GCM.seal(message, using: key)

// Sealed Box 구성 요소
print("Nonce: \(sealedBox.nonce)")           // 12바이트
print("Ciphertext: \(sealedBox.ciphertext)") // 평문과 동일 크기
print("Tag: \(sealedBox.tag)")               // 16바이트 (인증 태그)

// Combined: 전송/저장용 (nonce + ciphertext + tag)
if let combined = sealedBox.combined {
    print("Combined 크기: \(combined.count)바이트")
}
