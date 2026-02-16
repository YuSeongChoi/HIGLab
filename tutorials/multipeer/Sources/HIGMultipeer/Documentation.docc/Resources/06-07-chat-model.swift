import Foundation
import MultipeerConnectivity

// 확장된 채팅 메시지 모델
struct ChatMessage: Codable, Identifiable {
    let id: UUID
    let senderName: String
    let senderId: String  // PeerID의 displayName 또는 고유 ID
    let type: ChatMessageType
    let content: String
    let timestamp: Date
    
    var isFromMe: Bool = false
    
    init(sender: MCPeerID, type: ChatMessageType, content: String) {
        self.id = UUID()
        self.senderName = sender.displayName
        self.senderId = sender.displayName
        self.type = type
        self.content = content
        self.timestamp = Date()
    }
}

enum ChatMessageType: String, Codable {
    case text
    case image
    case file
    case system
}
