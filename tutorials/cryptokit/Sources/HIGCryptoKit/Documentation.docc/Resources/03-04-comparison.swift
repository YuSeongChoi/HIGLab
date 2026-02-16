import CryptoKit
import Foundation

// HMAC vs 단순 해시 비교
let message = "중요한 메시지"
let data = Data(message.utf8)

// 단순 해시: 누구나 계산 가능
let hash = SHA256.hash(data: data)

// HMAC: 비밀 키가 있어야만 생성 가능
let key = SymmetricKey(size: .bits256)
let hmac = HMAC<SHA256>.authenticationCode(for: data, using: key)

// 공격자가 메시지를 변조하려면?
// - 단순 해시: 새 해시를 계산하면 됨 (위험!)
// - HMAC: 키가 없으면 유효한 HMAC 생성 불가 (안전!)
