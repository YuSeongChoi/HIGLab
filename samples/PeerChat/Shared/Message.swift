// Message.swift
// PeerChat - MultipeerConnectivity 기반 P2P 채팅
// 메시지 모델 정의

import Foundation

/// 메시지 타입 정의
enum MessageType: String, Codable {
    case text           // 텍스트 메시지
    case file           // 파일 전송
    case system         // 시스템 메시지 (입장/퇴장 등)
    case typing         // 타이핑 중 표시
}

/// 채팅 메시지 모델
struct ChatMessage: Identifiable, Codable, Equatable {
    let id: UUID
    let senderID: String        // 발신자 피어 ID
    let senderName: String      // 발신자 표시 이름
    let type: MessageType       // 메시지 타입
    let content: String         // 메시지 내용 (텍스트 또는 파일명)
    let timestamp: Date         // 전송 시간
    let fileData: Data?         // 파일 데이터 (파일 전송 시)
    let fileMimeType: String?   // 파일 MIME 타입
    
    /// 텍스트 메시지 생성
    static func text(
        senderID: String,
        senderName: String,
        content: String
    ) -> ChatMessage {
        ChatMessage(
            id: UUID(),
            senderID: senderID,
            senderName: senderName,
            type: .text,
            content: content,
            timestamp: Date(),
            fileData: nil,
            fileMimeType: nil
        )
    }
    
    /// 파일 메시지 생성
    static func file(
        senderID: String,
        senderName: String,
        fileName: String,
        fileData: Data,
        mimeType: String
    ) -> ChatMessage {
        ChatMessage(
            id: UUID(),
            senderID: senderID,
            senderName: senderName,
            type: .file,
            content: fileName,
            timestamp: Date(),
            fileData: fileData,
            fileMimeType: mimeType
        )
    }
    
    /// 시스템 메시지 생성
    static func system(content: String) -> ChatMessage {
        ChatMessage(
            id: UUID(),
            senderID: "system",
            senderName: "시스템",
            type: .system,
            content: content,
            timestamp: Date(),
            fileData: nil,
            fileMimeType: nil
        )
    }
    
    /// 타이핑 표시 메시지 생성
    static func typing(senderID: String, senderName: String) -> ChatMessage {
        ChatMessage(
            id: UUID(),
            senderID: senderID,
            senderName: senderName,
            type: .typing,
            content: "",
            timestamp: Date(),
            fileData: nil,
            fileMimeType: nil
        )
    }
    
    /// 포맷된 시간 문자열
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: timestamp)
    }
    
    /// 포맷된 날짜 문자열
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter.string(from: timestamp)
    }
    
    /// 파일 크기 포맷
    var formattedFileSize: String? {
        guard let data = fileData else { return nil }
        let bytes = data.count
        if bytes < 1024 {
            return "\(bytes) B"
        } else if bytes < 1024 * 1024 {
            return String(format: "%.1f KB", Double(bytes) / 1024)
        } else {
            return String(format: "%.1f MB", Double(bytes) / (1024 * 1024))
        }
    }
}

/// 메시지 래퍼 (전송용)
struct MessageWrapper: Codable {
    let message: ChatMessage
    let sessionID: String       // 세션 식별자
    
    init(message: ChatMessage, sessionID: String) {
        self.message = message
        self.sessionID = sessionID
    }
    
    /// JSON 데이터로 인코딩
    func encoded() -> Data? {
        try? JSONEncoder().encode(self)
    }
    
    /// JSON 데이터에서 디코딩
    static func decoded(from data: Data) -> MessageWrapper? {
        try? JSONDecoder().decode(MessageWrapper.self, from: data)
    }
}
