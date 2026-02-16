import CryptoKit
import Foundation

// 파일 해시 계산
func hashFile(at url: URL) throws -> String {
    let data = try Data(contentsOf: url)
    let hash = SHA256.hash(data: data)
    return hash.compactMap { String(format: "%02x", $0) }.joined()
}

// 파일 무결성 검증
func verifyFile(at url: URL, expectedHash: String) throws -> Bool {
    let actualHash = try hashFile(at: url)
    return actualHash == expectedHash
}
