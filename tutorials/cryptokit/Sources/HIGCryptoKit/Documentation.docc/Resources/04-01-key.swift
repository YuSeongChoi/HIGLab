import CryptoKit
import Foundation

// 대칭 키 생성
let key128 = SymmetricKey(size: .bits128)
let key192 = SymmetricKey(size: .bits192)
let key256 = SymmetricKey(size: .bits256) // 권장

// 키를 Data로 변환 (저장용)
let keyData = key256.withUnsafeBytes { Data($0) }
print("키 크기: \(keyData.count)바이트") // 32바이트

// Data에서 키 복원
let restoredKey = SymmetricKey(data: keyData)
