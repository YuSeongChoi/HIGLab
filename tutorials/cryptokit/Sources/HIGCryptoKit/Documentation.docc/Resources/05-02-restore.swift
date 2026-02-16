import CryptoKit
import Foundation

// Combined 데이터에서 Sealed Box 복원
let key = SymmetricKey(size: .bits256)
let originalMessage = "복원 테스트"

// 암호화
let sealed = try! AES.GCM.seal(Data(originalMessage.utf8), using: key)
let combined = sealed.combined!

// 전송 시뮬레이션...
let receivedData = combined

// 복원 및 복호화
do {
    let restoredBox = try AES.GCM.SealedBox(combined: receivedData)
    let decrypted = try AES.GCM.open(restoredBox, using: key)
    print("복원: \(String(data: decrypted, encoding: .utf8)!)")
} catch {
    print("복원 실패: \(error)")
}
