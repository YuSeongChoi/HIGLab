import CryptoKit
import Foundation

// Nonce 이해하기
// Nonce = Number used ONCE (한 번만 사용하는 숫자)
// 같은 키로 같은 평문을 암호화해도 매번 다른 암호문 생성

let key = SymmetricKey(size: .bits256)
let message = Data("같은 메시지".utf8)

// 자동 Nonce 생성 (권장)
let sealed1 = try! AES.GCM.seal(message, using: key)
let sealed2 = try! AES.GCM.seal(message, using: key)

// 암호문이 다름!
print("암호문1: \(sealed1.ciphertext.base64EncodedString())")
print("암호문2: \(sealed2.ciphertext.base64EncodedString())")

// 커스텀 Nonce (특수한 경우에만)
let nonce = try! AES.GCM.Nonce(data: Data(count: 12))
