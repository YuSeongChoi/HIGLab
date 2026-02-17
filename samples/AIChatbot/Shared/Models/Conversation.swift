// Conversation.swift
// 대화 세션 모델
// iOS 26+ | FoundationModels
//
// 여러 대화 세션을 관리하고 각 세션의 설정과 메시지를 저장

import Foundation

// MARK: - 대화 세션

/// 대화 세션 모델 - 하나의 채팅 스레드를 표현
struct Conversation: Identifiable, Codable, Sendable, Hashable {
    
    // MARK: - 기본 속성
    
    let id: UUID                        // 고유 식별자
    var title: String                   // 대화 제목
    var messages: [Message]             // 메시지 목록
    let createdAt: Date                 // 생성 시간
    var updatedAt: Date                 // 마지막 업데이트 시간
    
    // MARK: - 설정
    
    var systemPrompt: String            // 시스템 프롬프트
    var settings: ConversationSettings  // 대화별 설정
    
    // MARK: - 메타데이터
    
    var isPinned: Bool                  // 고정 여부
    var isArchived: Bool                // 보관 여부
    var tags: [String]                  // 태그
    var summary: String?                // AI 생성 요약
    
    // MARK: - 통계
    
    var totalTokenUsage: TokenUsage     // 총 토큰 사용량
    
    // MARK: - 초기화
    
    init(
        id: UUID = UUID(),
        title: String = "새 대화",
        messages: [Message] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        systemPrompt: String = ConversationSettings.defaultSystemPrompt,
        settings: ConversationSettings = ConversationSettings(),
        isPinned: Bool = false,
        isArchived: Bool = false,
        tags: [String] = [],
        summary: String? = nil,
        totalTokenUsage: TokenUsage = TokenUsage()
    ) {
        self.id = id
        self.title = title
        self.messages = messages
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.systemPrompt = systemPrompt
        self.settings = settings
        self.isPinned = isPinned
        self.isArchived = isArchived
        self.tags = tags
        self.summary = summary
        self.totalTokenUsage = totalTokenUsage
    }
}

// MARK: - 대화 설정

/// 대화별 설정
struct ConversationSettings: Codable, Sendable, Hashable {
    
    // MARK: - 생성 옵션
    
    var temperature: Double             // 창의성 (0.0~2.0, 기본 0.7)
    var topP: Double                    // 확률 누적 (0.0~1.0, 기본 1.0)
    var maxTokens: Int                  // 최대 토큰 수 (기본 4096)
    var presencePenalty: Double         // 반복 패널티 (0.0~2.0)
    var frequencyPenalty: Double        // 빈도 패널티 (0.0~2.0)
    
    // MARK: - 기능 설정
    
    var enableTools: Bool               // 도구 사용 활성화
    var enabledTools: Set<String>       // 활성화된 도구 목록
    var streamResponse: Bool            // 스트리밍 응답 사용
    var autoGenerateTitle: Bool         // 자동 제목 생성
    
    // MARK: - 안전 설정
    
    var safetyLevel: SafetyLevel        // 안전 설정 수준
    
    // MARK: - 기본값
    
    static let defaultSystemPrompt = """
        당신은 친절하고 도움이 되는 AI 어시스턴트입니다.
        사용자의 질문에 정확하고 유용한 답변을 제공합니다.
        한국어로 대화하며, 필요시 도구를 활용하여 정보를 제공합니다.
        """
    
    // MARK: - 초기화
    
    init(
        temperature: Double = 0.7,
        topP: Double = 1.0,
        maxTokens: Int = 4096,
        presencePenalty: Double = 0.0,
        frequencyPenalty: Double = 0.0,
        enableTools: Bool = true,
        enabledTools: Set<String> = ["weather", "calculator", "datetime"],
        streamResponse: Bool = true,
        autoGenerateTitle: Bool = true,
        safetyLevel: SafetyLevel = .standard
    ) {
        self.temperature = temperature
        self.topP = topP
        self.maxTokens = maxTokens
        self.presencePenalty = presencePenalty
        self.frequencyPenalty = frequencyPenalty
        self.enableTools = enableTools
        self.enabledTools = enabledTools
        self.streamResponse = streamResponse
        self.autoGenerateTitle = autoGenerateTitle
        self.safetyLevel = safetyLevel
    }
    
    // MARK: - 프리셋
    
    /// 창의적인 대화용 프리셋
    static let creative = ConversationSettings(
        temperature: 1.2,
        topP: 0.95,
        presencePenalty: 0.5,
        frequencyPenalty: 0.5
    )
    
    /// 정확한 답변용 프리셋
    static let precise = ConversationSettings(
        temperature: 0.3,
        topP: 0.9,
        presencePenalty: 0.0,
        frequencyPenalty: 0.0
    )
    
    /// 코딩 도우미용 프리셋
    static let coding = ConversationSettings(
        temperature: 0.2,
        topP: 0.95,
        maxTokens: 8192,
        enableTools: false
    )
}

// MARK: - 안전 설정 수준

/// 안전 설정 수준
enum SafetyLevel: String, Codable, Sendable, CaseIterable {
    case strict     // 엄격 - 최대 필터링
    case standard   // 표준 - 기본 설정
    case relaxed    // 완화 - 최소 필터링
    
    /// 표시 이름
    var displayName: String {
        switch self {
        case .strict: return "엄격"
        case .standard: return "표준"
        case .relaxed: return "완화"
        }
    }
    
    /// 설명
    var description: String {
        switch self {
        case .strict:
            return "최대 수준의 콘텐츠 필터링을 적용합니다."
        case .standard:
            return "일반적인 대화에 적합한 필터링을 적용합니다."
        case .relaxed:
            return "최소한의 필터링만 적용합니다."
        }
    }
    
    /// 아이콘
    var iconName: String {
        switch self {
        case .strict: return "shield.fill"
        case .standard: return "shield.lefthalf.filled"
        case .relaxed: return "shield"
        }
    }
}

// MARK: - 대화 메서드

extension Conversation {
    
    // MARK: - 메시지 관리
    
    /// 메시지 추가
    /// - Parameter message: 추가할 메시지
    mutating func addMessage(_ message: Message) {
        messages.append(message)
        updatedAt = Date()
        
        // 토큰 사용량 누적
        if let usage = message.tokenUsage {
            totalTokenUsage = totalTokenUsage + usage
        }
    }
    
    /// 마지막 메시지 업데이트 (스트리밍용)
    /// - Parameter content: 새 내용
    mutating func updateLastMessage(content: String) {
        guard !messages.isEmpty else { return }
        messages[messages.count - 1].content = content
        updatedAt = Date()
    }
    
    /// 마지막 메시지 완료 처리
    /// - Parameters:
    ///   - content: 최종 내용
    ///   - tokenUsage: 토큰 사용량
    mutating func completeLastMessage(
        content: String,
        tokenUsage: TokenUsage? = nil
    ) {
        guard !messages.isEmpty else { return }
        var lastMessage = messages[messages.count - 1]
        lastMessage.content = content
        lastMessage.status = .completed
        lastMessage.isStreaming = false
        lastMessage.tokenUsage = tokenUsage
        messages[messages.count - 1] = lastMessage
        updatedAt = Date()
        
        // 토큰 사용량 누적
        if let usage = tokenUsage {
            totalTokenUsage = totalTokenUsage + usage
        }
    }
    
    /// 메시지 삭제
    /// - Parameter messageId: 삭제할 메시지 ID
    mutating func removeMessage(_ messageId: UUID) {
        messages.removeAll { $0.id == messageId }
        updatedAt = Date()
    }
    
    /// 메시지 ID로부터 이후 모든 메시지 삭제 (재생성용)
    /// - Parameter messageId: 기준 메시지 ID
    mutating func removeMessagesFrom(_ messageId: UUID) {
        if let index = messages.firstIndex(where: { $0.id == messageId }) {
            messages.removeSubrange(index...)
            updatedAt = Date()
        }
    }
    
    // MARK: - 제목 관리
    
    /// 첫 메시지 기반으로 제목 자동 생성
    mutating func generateTitle() {
        guard let firstUserMessage = messages.first(where: { $0.role == .user }) else {
            return
        }
        
        // 첫 메시지의 앞 30자를 제목으로 사용
        let content = firstUserMessage.content
        if content.count > 30 {
            title = String(content.prefix(27)) + "..."
        } else {
            title = content
        }
    }
    
    // MARK: - 통계
    
    /// 총 메시지 수
    var messageCount: Int {
        messages.count
    }
    
    /// 사용자 메시지 수
    var userMessageCount: Int {
        messages.filter { $0.role == .user }.count
    }
    
    /// AI 응답 수
    var assistantMessageCount: Int {
        messages.filter { $0.role == .assistant }.count
    }
    
    /// 도구 호출 횟수
    var toolCallCount: Int {
        messages.flatMap { $0.toolCalls }.count
    }
    
    /// 마지막 메시지
    var lastMessage: Message? {
        messages.last
    }
    
    /// 마지막 사용자 메시지
    var lastUserMessage: Message? {
        messages.last { $0.role == .user }
    }
    
    /// 마지막 AI 응답
    var lastAssistantMessage: Message? {
        messages.last { $0.role == .assistant }
    }
    
    /// 대화가 비어있는지
    var isEmpty: Bool {
        messages.isEmpty
    }
    
    /// 현재 스트리밍 중인지
    var isStreaming: Bool {
        messages.last?.isStreaming ?? false
    }
}

// MARK: - 날짜 포맷팅

extension Conversation {
    
    /// 생성 시간 표시
    var formattedCreatedAt: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: createdAt)
    }
    
    /// 마지막 업데이트 상대 시간
    var relativeUpdatedAt: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: updatedAt, relativeTo: Date())
    }
    
    /// 날짜별 그룹 키 (YYYY-MM-DD)
    var dateGroupKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: updatedAt)
    }
}

// MARK: - 내보내기/가져오기

extension Conversation {
    
    /// JSON으로 내보내기
    /// - Returns: JSON 데이터
    func exportToJSON() throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(self)
    }
    
    /// JSON에서 가져오기
    /// - Parameter data: JSON 데이터
    /// - Returns: 대화 객체
    static func importFromJSON(_ data: Data) throws -> Conversation {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Conversation.self, from: data)
    }
    
    /// Markdown으로 내보내기
    /// - Returns: Markdown 문자열
    func exportToMarkdown() -> String {
        var md = "# \(title)\n\n"
        md += "- 생성: \(formattedCreatedAt)\n"
        md += "- 메시지 수: \(messageCount)\n"
        md += "- 토큰 사용: \(totalTokenUsage.description)\n\n"
        md += "---\n\n"
        
        for message in messages {
            let roleLabel = message.role == .user ? "**사용자**" : "**AI**"
            md += "\(roleLabel) (\(message.formattedTime)):\n\n"
            md += "\(message.content)\n\n"
            
            // 도구 호출 표시
            for toolCall in message.toolCalls {
                md += "> 🔧 **\(toolCall.toolName)**: \(toolCall.result ?? "결과 없음")\n\n"
            }
        }
        
        return md
    }
}

// MARK: - Comparable

extension Conversation: Comparable {
    static func < (lhs: Conversation, rhs: Conversation) -> Bool {
        // 고정된 대화가 우선, 그 다음 업데이트 시간 역순
        if lhs.isPinned != rhs.isPinned {
            return lhs.isPinned && !rhs.isPinned
        }
        return lhs.updatedAt > rhs.updatedAt
    }
}

// MARK: - 프리뷰 데이터

extension Conversation {
    
    /// 프리뷰용 샘플 대화
    static let preview: Conversation = {
        var conv = Conversation(
            title: "날씨 문의",
            systemPrompt: ConversationSettings.defaultSystemPrompt
        )
        conv.messages = [
            .user("안녕하세요! 오늘 서울 날씨가 어때요?"),
            .assistant(
                "안녕하세요! 오늘 서울 날씨를 확인해볼게요. 🌤️\n\n현재 서울은 맑고 기온은 18°C입니다. 오후에 약간의 구름이 끼겠지만 대체로 좋은 날씨가 예상됩니다.",
                toolCalls: [
                    ToolCallInfo(
                        toolName: "weather",
                        arguments: ["city": "서울"],
                        result: "맑음, 18°C, 습도 45%",
                        isSuccess: true
                    )
                ],
                tokenUsage: TokenUsage(promptTokens: 50, completionTokens: 80)
            ),
            .user("고마워요! 내일은 어떨까요?"),
            .assistant(
                "내일 서울 날씨도 확인해드릴게요! 📅\n\n내일은 구름이 약간 많겠지만, 비는 오지 않을 것으로 예상됩니다. 기온은 15°C~22°C 정도가 될 것 같아요.",
                tokenUsage: TokenUsage(promptTokens: 120, completionTokens: 65)
            )
        ]
        conv.totalTokenUsage = TokenUsage(promptTokens: 170, completionTokens: 145)
        return conv
    }()
    
    /// 프리뷰용 빈 대화
    static let empty = Conversation()
    
    /// 프리뷰용 대화 목록
    static let previewList: [Conversation] = [
        {
            var conv = Conversation(title: "날씨 문의", isPinned: true)
            conv.messages = [.user("오늘 날씨 어때?")]
            return conv
        }(),
        {
            var conv = Conversation(title: "Swift 코딩 질문")
            conv.messages = [.user("옵셔널이란?"), .assistant("Swift의 옵셔널은...")]
            return conv
        }(),
        {
            var conv = Conversation(title: "맛집 추천", tags: ["음식", "추천"])
            conv.messages = [.user("강남 맛집 추천해줘")]
            return conv
        }()
    ]
}
