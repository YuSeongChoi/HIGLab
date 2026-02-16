import Foundation

// Codable을 채택한 메시지 모델
struct Message: Codable, Identifiable {
    let id: UUID
    let type: MessageType
    let content: String
    let timestamp: Date
    
    init(type: MessageType, content: String) {
        self.id = UUID()
        self.type = type
        self.content = content
        self.timestamp = Date()
    }
}

enum MessageType: String, Codable {
    case text
    case emoji
    case system
    case fileInfo
}
