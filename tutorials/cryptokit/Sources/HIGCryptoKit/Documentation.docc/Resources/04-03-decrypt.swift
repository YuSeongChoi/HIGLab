import CryptoKit
import Foundation

// AES-GCM 복호화
func decrypt(sealedBox: AES.GCM.SealedBox, key: SymmetricKey) throws -> String {
    let decryptedData = try AES.GCM.open(sealedBox, using: key)
    guard let message = String(data: decryptedData, encoding: .utf8) else {
        throw CryptoKitError.authenticationFailure
    }
    return message
}

// 사용 예시
let key = SymmetricKey(size: .bits256)
let sealedBox = try! AES.GCM.seal(Data("비밀".utf8), using: key)
let decrypted = try! decrypt(sealedBox: sealedBox, key: key)
print("복호화: \(decrypted)")
