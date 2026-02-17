import FoundationModels
import Foundation

// 대화 기록 저장/복원을 위한 모델
struct ConversationRecord: Codable {
    let id: UUID
    let systemPrompt: String
    let messages: [StoredMessage]
    let createdAt: Date
}

struct StoredMessage: Codable {
    let role: String  // "user" or "assistant"
    let content: String
    let timestamp: Date
}

class ConversationManager {
    private let storage = UserDefaults.standard
    private let storageKey = "saved_conversations"
    
    // 현재 세션의 대화를 저장
    func saveConversation(
        id: UUID,
        systemPrompt: String,
        messages: [(role: String, content: String)]
    ) {
        let storedMessages = messages.map { msg in
            StoredMessage(role: msg.role, content: msg.content, timestamp: Date())
        }
        
        let record = ConversationRecord(
            id: id,
            systemPrompt: systemPrompt,
            messages: storedMessages,
            createdAt: Date()
        )
        
        var conversations = loadAllConversations()
        conversations[id] = record
        
        if let data = try? JSONEncoder().encode(conversations) {
            storage.set(data, forKey: storageKey)
        }
    }
    
    // 저장된 대화를 새 세션으로 복원
    func restoreSession(conversationId: UUID) -> LanguageModel.Session? {
        guard let record = loadAllConversations()[conversationId] else {
            return nil
        }
        
        // 새 세션 생성 후 기존 메시지로 컨텍스트 재구성
        var session = LanguageModel.default.createSession(
            systemPrompt: record.systemPrompt
        )
        
        // 이전 대화를 컨텍스트로 주입
        for message in record.messages {
            session.appendToHistory(
                role: message.role == "user" ? .user : .assistant,
                content: message.content
            )
        }
        
        return session
    }
    
    private func loadAllConversations() -> [UUID: ConversationRecord] {
        guard let data = storage.data(forKey: storageKey),
              let conversations = try? JSONDecoder().decode([UUID: ConversationRecord].self, from: data)
        else {
            return [:]
        }
        return conversations
    }
}
