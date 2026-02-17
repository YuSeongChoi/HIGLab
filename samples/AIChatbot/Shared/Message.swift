// Message.swift
// AIChatbot 채팅 메시지 모델
// iOS 26+ | FoundationModels

import Foundation

/// 메시지 발신자 역할
enum MessageRole: String, Codable, Sendable {
    case user       // 사용자 메시지
    case assistant  // AI 응답
}

/// 채팅 메시지 모델
struct Message: Identifiable, Codable, Sendable {
    let id: UUID
    let role: MessageRole
    let content: String
    let timestamp: Date
    
    /// 새 메시지 생성
    init(
        id: UUID = UUID(),
        role: MessageRole,
        content: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
    
    /// 사용자 메시지 생성 헬퍼
    static func user(_ content: String) -> Message {
        Message(role: .user, content: content)
    }
    
    /// AI 응답 메시지 생성 헬퍼
    static func assistant(_ content: String) -> Message {
        Message(role: .assistant, content: content)
    }
}

// MARK: - 메시지 그룹화 (날짜별)

extension Message {
    /// 날짜 포맷터 (표시용)
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}
