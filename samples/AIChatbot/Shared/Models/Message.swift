// Message.swift
// AI 채팅 메시지 모델 - 확장된 버전
// iOS 26+ | FoundationModels
//
// 메시지의 모든 측면을 표현: 텍스트, 도구 호출, 토큰 사용량 등

import Foundation

// MARK: - 메시지 역할

/// 메시지 발신자 역할
/// - user: 사용자가 보낸 메시지
/// - assistant: AI가 생성한 응답
/// - system: 시스템 메시지 (에러, 알림 등)
/// - tool: 도구 호출 결과
enum MessageRole: String, Codable, Sendable, CaseIterable {
    case user       // 사용자 메시지
    case assistant  // AI 응답
    case system     // 시스템 메시지
    case tool       // 도구 응답
    
    /// 역할 표시 이름
    var displayName: String {
        switch self {
        case .user: return "사용자"
        case .assistant: return "AI"
        case .system: return "시스템"
        case .tool: return "도구"
        }
    }
    
    /// 역할 아이콘
    var iconName: String {
        switch self {
        case .user: return "person.fill"
        case .assistant: return "brain"
        case .system: return "info.circle.fill"
        case .tool: return "wrench.and.screwdriver.fill"
        }
    }
}

// MARK: - 메시지 상태

/// 메시지 전송/생성 상태
enum MessageStatus: String, Codable, Sendable {
    case sending    // 전송 중
    case streaming  // 스트리밍 중
    case completed  // 완료됨
    case failed     // 실패
    case cancelled  // 취소됨
    
    /// 상태 표시 텍스트
    var displayText: String {
        switch self {
        case .sending: return "전송 중..."
        case .streaming: return "생성 중..."
        case .completed: return "완료"
        case .failed: return "실패"
        case .cancelled: return "취소됨"
        }
    }
    
    /// 완료 여부
    var isFinished: Bool {
        switch self {
        case .completed, .failed, .cancelled:
            return true
        case .sending, .streaming:
            return false
        }
    }
}

// MARK: - 도구 호출 정보

/// 메시지에 포함된 도구 호출 정보
struct ToolCallInfo: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    let toolName: String           // 도구 이름
    let arguments: [String: String] // 인자들
    let result: String?            // 실행 결과
    let executionTime: TimeInterval? // 실행 시간
    let isSuccess: Bool            // 성공 여부
    
    init(
        id: UUID = UUID(),
        toolName: String,
        arguments: [String: String] = [:],
        result: String? = nil,
        executionTime: TimeInterval? = nil,
        isSuccess: Bool = true
    ) {
        self.id = id
        self.toolName = toolName
        self.arguments = arguments
        self.result = result
        self.executionTime = executionTime
        self.isSuccess = isSuccess
    }
    
    /// 도구 아이콘
    var iconName: String {
        switch toolName.lowercased() {
        case "weather", "날씨": return "cloud.sun.fill"
        case "calculator", "계산기": return "plus.forwardslash.minus"
        case "datetime", "날짜시간": return "calendar"
        case "search", "검색": return "magnifyingglass"
        case "reminder", "알림": return "bell.fill"
        default: return "wrench.fill"
        }
    }
}

// MARK: - 토큰 사용량

/// 토큰 사용량 정보
struct TokenUsage: Codable, Sendable, Hashable {
    let promptTokens: Int      // 프롬프트 토큰 수
    let completionTokens: Int  // 생성 토큰 수
    let totalTokens: Int       // 총 토큰 수
    
    init(promptTokens: Int = 0, completionTokens: Int = 0) {
        self.promptTokens = promptTokens
        self.completionTokens = completionTokens
        self.totalTokens = promptTokens + completionTokens
    }
    
    /// 토큰 사용량 설명
    var description: String {
        "입력: \(promptTokens), 출력: \(completionTokens), 총: \(totalTokens)"
    }
    
    /// 두 토큰 사용량 합산
    static func + (lhs: TokenUsage, rhs: TokenUsage) -> TokenUsage {
        TokenUsage(
            promptTokens: lhs.promptTokens + rhs.promptTokens,
            completionTokens: lhs.completionTokens + rhs.completionTokens
        )
    }
}

// MARK: - 메시지 첨부 파일

/// 메시지 첨부 파일 타입
enum AttachmentType: String, Codable, Sendable {
    case image      // 이미지
    case file       // 파일
    case code       // 코드 블록
    case link       // 링크
}

/// 메시지 첨부 파일
struct MessageAttachment: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    let type: AttachmentType
    let name: String
    let data: Data?
    let url: URL?
    let mimeType: String?
    
    init(
        id: UUID = UUID(),
        type: AttachmentType,
        name: String,
        data: Data? = nil,
        url: URL? = nil,
        mimeType: String? = nil
    ) {
        self.id = id
        self.type = type
        self.name = name
        self.data = data
        self.url = url
        self.mimeType = mimeType
    }
}

// MARK: - 채팅 메시지

/// 채팅 메시지 모델 - 모든 메시지 정보를 포함
struct Message: Identifiable, Codable, Sendable, Hashable {
    
    // MARK: - 필수 속성
    
    let id: UUID                    // 고유 식별자
    let role: MessageRole           // 발신자 역할
    var content: String             // 메시지 내용
    let timestamp: Date             // 생성 시간
    
    // MARK: - 상태
    
    var status: MessageStatus       // 현재 상태
    var errorMessage: String?       // 에러 메시지 (실패 시)
    
    // MARK: - 메타데이터
    
    var toolCalls: [ToolCallInfo]   // 도구 호출 정보
    var tokenUsage: TokenUsage?     // 토큰 사용량
    var attachments: [MessageAttachment] // 첨부 파일
    var replyToId: UUID?            // 답장 대상 메시지 ID
    
    // MARK: - 스트리밍
    
    var isStreaming: Bool           // 스트리밍 중 여부
    var streamProgress: Double      // 스트리밍 진행률 (0.0~1.0)
    
    // MARK: - 초기화
    
    init(
        id: UUID = UUID(),
        role: MessageRole,
        content: String,
        timestamp: Date = Date(),
        status: MessageStatus = .completed,
        errorMessage: String? = nil,
        toolCalls: [ToolCallInfo] = [],
        tokenUsage: TokenUsage? = nil,
        attachments: [MessageAttachment] = [],
        replyToId: UUID? = nil,
        isStreaming: Bool = false,
        streamProgress: Double = 0.0
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
        self.status = status
        self.errorMessage = errorMessage
        self.toolCalls = toolCalls
        self.tokenUsage = tokenUsage
        self.attachments = attachments
        self.replyToId = replyToId
        self.isStreaming = isStreaming
        self.streamProgress = streamProgress
    }
}

// MARK: - 팩토리 메서드

extension Message {
    
    /// 사용자 메시지 생성
    /// - Parameters:
    ///   - content: 메시지 내용
    ///   - attachments: 첨부 파일
    /// - Returns: 사용자 메시지
    static func user(
        _ content: String,
        attachments: [MessageAttachment] = []
    ) -> Message {
        Message(
            role: .user,
            content: content,
            status: .completed,
            attachments: attachments
        )
    }
    
    /// AI 응답 메시지 생성
    /// - Parameters:
    ///   - content: 응답 내용
    ///   - toolCalls: 도구 호출 정보
    ///   - tokenUsage: 토큰 사용량
    /// - Returns: AI 응답 메시지
    static func assistant(
        _ content: String,
        toolCalls: [ToolCallInfo] = [],
        tokenUsage: TokenUsage? = nil
    ) -> Message {
        Message(
            role: .assistant,
            content: content,
            status: .completed,
            toolCalls: toolCalls,
            tokenUsage: tokenUsage
        )
    }
    
    /// 시스템 메시지 생성
    /// - Parameter content: 시스템 메시지 내용
    /// - Returns: 시스템 메시지
    static func system(_ content: String) -> Message {
        Message(
            role: .system,
            content: content,
            status: .completed
        )
    }
    
    /// 도구 응답 메시지 생성
    /// - Parameters:
    ///   - toolName: 도구 이름
    ///   - result: 도구 실행 결과
    /// - Returns: 도구 응답 메시지
    static func toolResult(
        toolName: String,
        result: String
    ) -> Message {
        let toolCall = ToolCallInfo(
            toolName: toolName,
            result: result
        )
        return Message(
            role: .tool,
            content: result,
            status: .completed,
            toolCalls: [toolCall]
        )
    }
    
    /// 스트리밍 플레이스홀더 생성
    /// - Returns: 스트리밍 중인 빈 AI 응답
    static func streamingPlaceholder() -> Message {
        Message(
            role: .assistant,
            content: "",
            status: .streaming,
            isStreaming: true
        )
    }
    
    /// 에러 메시지 생성
    /// - Parameter error: 에러 정보
    /// - Returns: 에러 메시지
    static func error(_ error: Error) -> Message {
        Message(
            role: .system,
            content: "오류가 발생했습니다: \(error.localizedDescription)",
            status: .failed,
            errorMessage: error.localizedDescription
        )
    }
}

// MARK: - 날짜 포맷팅

extension Message {
    
    /// 시간 표시 (HH:mm)
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: timestamp)
    }
    
    /// 날짜 표시 (M월 d일)
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: timestamp)
    }
    
    /// 전체 날짜/시간 표시
    var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: timestamp)
    }
    
    /// 상대적 시간 표시 (방금 전, 5분 전 등)
    var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}

// MARK: - 유틸리티

extension Message {
    
    /// 내용이 비어있는지 확인
    var isEmpty: Bool {
        content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// 내용의 단어 수
    var wordCount: Int {
        content.split(separator: " ").count
    }
    
    /// 내용의 문자 수
    var characterCount: Int {
        content.count
    }
    
    /// 도구 호출이 있는지 확인
    var hasToolCalls: Bool {
        !toolCalls.isEmpty
    }
    
    /// 첨부 파일이 있는지 확인
    var hasAttachments: Bool {
        !attachments.isEmpty
    }
    
    /// 완료된 메시지인지 확인
    var isCompleted: Bool {
        status == .completed
    }
    
    /// 실패한 메시지인지 확인
    var isFailed: Bool {
        status == .failed
    }
}

// MARK: - Comparable

extension Message: Comparable {
    static func < (lhs: Message, rhs: Message) -> Bool {
        lhs.timestamp < rhs.timestamp
    }
}

// MARK: - 프리뷰 데이터

extension Message {
    
    /// 프리뷰용 샘플 사용자 메시지
    static let previewUser = Message.user("안녕하세요! 오늘 서울 날씨가 어때요?")
    
    /// 프리뷰용 샘플 AI 응답
    static let previewAssistant = Message.assistant(
        "안녕하세요! 오늘 서울 날씨를 확인해볼게요.",
        toolCalls: [
            ToolCallInfo(
                toolName: "weather",
                arguments: ["city": "서울"],
                result: "맑음, 18°C",
                executionTime: 0.5,
                isSuccess: true
            )
        ],
        tokenUsage: TokenUsage(promptTokens: 50, completionTokens: 30)
    )
    
    /// 프리뷰용 샘플 에러 메시지
    static let previewError = Message.error(
        NSError(domain: "ChatError", code: -1, userInfo: [
            NSLocalizedDescriptionKey: "네트워크 연결을 확인해주세요."
        ])
    )
    
    /// 프리뷰용 스트리밍 메시지
    static let previewStreaming: Message = {
        var msg = Message.streamingPlaceholder()
        msg.content = "응답을 생성하고 있습니다..."
        return msg
    }()
}
