import CryptoKit
import Foundation

// 암호화 메시지 구조
struct SecureEnvelope: Codable {
    let version: Int = 1
    let senderId: String
    let recipientId: String
    let timestamp: Date
    let ephemeralPublicKey: Data
    let encryptedContent: Data
    let signature: Data
    
    // 메타데이터 (암호화되지 않음)
    var metadata: MessageMetadata {
        MessageMetadata(
            senderId: senderId,
            recipientId: recipientId,
            timestamp: timestamp,
            size: encryptedContent.count
        )
    }
}

struct MessageMetadata: Codable {
    let senderId: String
    let recipientId: String
    let timestamp: Date
    let size: Int
}
