import CryptoKit
import Foundation

// 메시지 중복 검사
class MessageDeduplicator {
    private var seenHashes: Set<String> = []
    
    func isDuplicate(_ message: String) -> Bool {
        let hash = SHA256.hash(data: Data(message.utf8))
        let hashString = hash.compactMap { String(format: "%02x", $0) }.joined()
        
        if seenHashes.contains(hashString) {
            return true
        }
        seenHashes.insert(hashString)
        return false
    }
}
