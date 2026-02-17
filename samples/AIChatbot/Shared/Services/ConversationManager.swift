// ConversationManager.swift
// 대화 세션 관리 서비스
// iOS 26+ | FoundationModels
//
// 여러 대화 세션의 생성, 저장, 로드, 삭제를 관리
// 현재 활성 대화와 ChatService를 연결

import Foundation
import SwiftUI

// MARK: - 대화 관리자

/// 대화 관리자 - 여러 대화 세션을 관리
@MainActor
@Observable
final class ConversationManager {
    
    // MARK: - 상태
    
    /// 모든 대화 목록
    private(set) var conversations: [Conversation] = []
    
    /// 현재 활성 대화 ID
    var activeConversationId: UUID? {
        didSet {
            if activeConversationId != oldValue {
                onActiveConversationChanged()
            }
        }
    }
    
    /// 채팅 서비스
    let chatService: ChatService
    
    /// 설정 저장소
    private let settingsStore: SettingsStore
    
    // MARK: - 계산 속성
    
    /// 현재 활성 대화
    var activeConversation: Conversation? {
        get {
            guard let id = activeConversationId else { return nil }
            return conversations.first { $0.id == id }
        }
        set {
            if let conv = newValue,
               let index = conversations.firstIndex(where: { $0.id == conv.id }) {
                conversations[index] = conv
                saveConversations()
            }
        }
    }
    
    /// 현재 대화의 메시지들
    var messages: [Message] {
        activeConversation?.messages ?? []
    }
    
    /// 고정된 대화 목록
    var pinnedConversations: [Conversation] {
        conversations.filter { $0.isPinned && !$0.isArchived }
    }
    
    /// 일반 대화 목록 (고정되지 않음)
    var unpinnedConversations: [Conversation] {
        conversations.filter { !$0.isPinned && !$0.isArchived }
    }
    
    /// 보관된 대화 목록
    var archivedConversations: [Conversation] {
        conversations.filter { $0.isArchived }
    }
    
    /// 날짜별 그룹화된 대화 목록
    var groupedConversations: [(date: String, conversations: [Conversation])] {
        let active = conversations.filter { !$0.isArchived }
        let grouped = Dictionary(grouping: active) { $0.dateGroupKey }
        
        return grouped
            .sorted { $0.key > $1.key }
            .map { (date: formatGroupDate($0.key), conversations: $0.value.sorted()) }
    }
    
    // MARK: - 저장 경로
    
    private var saveURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("conversations.json")
    }
    
    // MARK: - 초기화
    
    init(
        chatService: ChatService = ChatService(),
        settingsStore: SettingsStore = .shared
    ) {
        self.chatService = chatService
        self.settingsStore = settingsStore
        
        loadConversations()
        
        // 대화가 없으면 새 대화 생성
        if conversations.isEmpty {
            createNewConversation()
        } else {
            // 마지막 대화를 활성화
            activeConversationId = conversations.first?.id
        }
    }
    
    // MARK: - 대화 생성
    
    /// 새 대화 생성
    /// - Parameters:
    ///   - title: 대화 제목 (nil이면 "새 대화")
    ///   - systemPrompt: 시스템 프롬프트 (nil이면 기본값)
    /// - Returns: 생성된 대화
    @discardableResult
    func createNewConversation(
        title: String? = nil,
        systemPrompt: String? = nil
    ) -> Conversation {
        let defaults = settingsStore.chat
        
        let conversation = Conversation(
            title: title ?? "새 대화",
            systemPrompt: systemPrompt ?? defaults.defaultSystemPrompt,
            settings: ConversationSettings(
                temperature: defaults.defaultTemperature,
                maxTokens: defaults.defaultMaxTokens,
                enableTools: defaults.enableToolsByDefault,
                enabledTools: defaults.defaultEnabledTools,
                streamResponse: defaults.useStreaming,
                autoGenerateTitle: defaults.autoTitle
            )
        )
        
        conversations.insert(conversation, at: 0)
        activeConversationId = conversation.id
        
        saveConversations()
        
        return conversation
    }
    
    /// 대화 복제
    /// - Parameter conversationId: 복제할 대화 ID
    /// - Returns: 복제된 대화
    @discardableResult
    func duplicateConversation(_ conversationId: UUID) -> Conversation? {
        guard let original = conversations.first(where: { $0.id == conversationId }) else {
            return nil
        }
        
        var duplicate = original
        duplicate = Conversation(
            title: "\(original.title) (복사본)",
            messages: original.messages,
            systemPrompt: original.systemPrompt,
            settings: original.settings
        )
        
        conversations.insert(duplicate, at: 0)
        saveConversations()
        
        return duplicate
    }
    
    // MARK: - 대화 삭제
    
    /// 대화 삭제
    /// - Parameter conversationId: 삭제할 대화 ID
    func deleteConversation(_ conversationId: UUID) {
        conversations.removeAll { $0.id == conversationId }
        
        // 현재 대화가 삭제되었으면 다른 대화로 전환
        if activeConversationId == conversationId {
            activeConversationId = conversations.first?.id
        }
        
        // 모든 대화가 삭제되었으면 새 대화 생성
        if conversations.isEmpty {
            createNewConversation()
        }
        
        saveConversations()
    }
    
    /// 여러 대화 삭제
    /// - Parameter ids: 삭제할 대화 ID 목록
    func deleteConversations(_ ids: Set<UUID>) {
        conversations.removeAll { ids.contains($0.id) }
        
        if let activeId = activeConversationId, ids.contains(activeId) {
            activeConversationId = conversations.first?.id
        }
        
        if conversations.isEmpty {
            createNewConversation()
        }
        
        saveConversations()
    }
    
    /// 모든 대화 삭제
    func deleteAllConversations() {
        conversations.removeAll()
        createNewConversation()
    }
    
    // MARK: - 대화 업데이트
    
    /// 대화 제목 변경
    /// - Parameters:
    ///   - conversationId: 대화 ID
    ///   - title: 새 제목
    func renameConversation(_ conversationId: UUID, title: String) {
        guard let index = conversations.firstIndex(where: { $0.id == conversationId }) else {
            return
        }
        
        conversations[index].title = title
        saveConversations()
    }
    
    /// 대화 고정/해제
    /// - Parameter conversationId: 대화 ID
    func togglePin(_ conversationId: UUID) {
        guard let index = conversations.firstIndex(where: { $0.id == conversationId }) else {
            return
        }
        
        conversations[index].isPinned.toggle()
        conversations.sort()
        saveConversations()
    }
    
    /// 대화 보관/해제
    /// - Parameter conversationId: 대화 ID
    func toggleArchive(_ conversationId: UUID) {
        guard let index = conversations.firstIndex(where: { $0.id == conversationId }) else {
            return
        }
        
        conversations[index].isArchived.toggle()
        
        // 현재 대화가 보관되었으면 다른 대화로 전환
        if conversations[index].isArchived && activeConversationId == conversationId {
            activeConversationId = unpinnedConversations.first?.id ?? pinnedConversations.first?.id
        }
        
        saveConversations()
    }
    
    /// 대화 설정 업데이트
    /// - Parameters:
    ///   - conversationId: 대화 ID
    ///   - settings: 새 설정
    func updateConversationSettings(
        _ conversationId: UUID,
        settings: ConversationSettings
    ) {
        guard let index = conversations.firstIndex(where: { $0.id == conversationId }) else {
            return
        }
        
        conversations[index].settings = settings
        
        // 현재 대화면 ChatService도 업데이트
        if conversationId == activeConversationId {
            chatService.updateGenerationOptions(
                GenerationOptions(
                    temperature: settings.temperature,
                    topP: settings.topP,
                    maxTokens: settings.maxTokens,
                    presencePenalty: settings.presencePenalty,
                    frequencyPenalty: settings.frequencyPenalty
                )
            )
        }
        
        saveConversations()
    }
    
    /// 대화 시스템 프롬프트 업데이트
    /// - Parameters:
    ///   - conversationId: 대화 ID
    ///   - systemPrompt: 새 시스템 프롬프트
    func updateSystemPrompt(
        _ conversationId: UUID,
        systemPrompt: String
    ) {
        guard let index = conversations.firstIndex(where: { $0.id == conversationId }) else {
            return
        }
        
        conversations[index].systemPrompt = systemPrompt
        
        // 현재 대화면 ChatService도 업데이트
        if conversationId == activeConversationId {
            chatService.updateSystemPrompt(systemPrompt)
        }
        
        saveConversations()
    }
    
    // MARK: - 메시지 전송
    
    /// 현재 대화에 메시지 전송
    /// - Parameter content: 메시지 내용
    func sendMessage(_ content: String) async {
        guard let activeId = activeConversationId,
              var conversation = activeConversation else {
            return
        }
        
        // 사용자 메시지 추가
        let userMessage = Message.user(content)
        conversation.addMessage(userMessage)
        activeConversation = conversation
        
        // 플레이스홀더 추가
        var placeholder = Message.streamingPlaceholder()
        conversation.addMessage(placeholder)
        activeConversation = conversation
        
        do {
            // AI 응답 받기
            let response = try await chatService.send(content) { [weak self] partial in
                // 스트리밍 업데이트
                Task { @MainActor in
                    self?.updateStreamingMessage(partial)
                }
            }
            
            // 완료 처리
            conversation = activeConversation ?? conversation
            conversation.completeLastMessage(
                content: response,
                tokenUsage: chatService.lastTokenUsage
            )
            
            // 첫 메시지면 제목 자동 생성
            if conversation.settings.autoGenerateTitle &&
               conversation.userMessageCount == 1 {
                conversation.generateTitle()
            }
            
            activeConversation = conversation
            
        } catch {
            // 에러 처리 - 플레이스홀더 제거하고 에러 메시지 추가
            conversation = activeConversation ?? conversation
            conversation.removeMessage(placeholder.id)
            
            let errorMessage = Message.error(error)
            conversation.addMessage(errorMessage)
            activeConversation = conversation
        }
    }
    
    /// 스트리밍 메시지 업데이트
    private func updateStreamingMessage(_ content: String) {
        guard var conversation = activeConversation else { return }
        conversation.updateLastMessage(content: content)
        activeConversation = conversation
    }
    
    /// 메시지 재생성
    /// - Parameter messageId: 재생성할 메시지 ID
    func regenerateMessage(_ messageId: UUID) async {
        guard var conversation = activeConversation else { return }
        
        // 해당 메시지 이후 모두 삭제
        conversation.removeMessagesFrom(messageId)
        activeConversation = conversation
        
        // 마지막 사용자 메시지로 재전송
        if let lastUserMessage = conversation.lastUserMessage {
            await sendMessage(lastUserMessage.content)
        }
    }
    
    /// 메시지 삭제
    /// - Parameter messageId: 삭제할 메시지 ID
    func deleteMessage(_ messageId: UUID) {
        guard var conversation = activeConversation else { return }
        conversation.removeMessage(messageId)
        activeConversation = conversation
    }
    
    /// 현재 대화 초기화
    func clearCurrentConversation() {
        guard let activeId = activeConversationId,
              let index = conversations.firstIndex(where: { $0.id == activeId }) else {
            return
        }
        
        conversations[index].messages.removeAll()
        conversations[index].totalTokenUsage = TokenUsage()
        chatService.resetSession()
        
        saveConversations()
    }
    
    // MARK: - 활성 대화 변경
    
    private func onActiveConversationChanged() {
        guard let conversation = activeConversation else { return }
        
        // ChatService 설정 동기화
        chatService.updateSystemPrompt(conversation.systemPrompt)
        chatService.updateGenerationOptions(
            GenerationOptions(
                temperature: conversation.settings.temperature,
                topP: conversation.settings.topP,
                maxTokens: conversation.settings.maxTokens,
                presencePenalty: conversation.settings.presencePenalty,
                frequencyPenalty: conversation.settings.frequencyPenalty
            )
        )
        
        // 세션 초기화
        chatService.resetSession()
    }
    
    // MARK: - 저장/로드
    
    /// 대화 저장
    private func saveConversations() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(conversations)
            try data.write(to: saveURL)
        } catch {
            print("❌ 대화 저장 실패: \(error.localizedDescription)")
        }
    }
    
    /// 대화 로드
    private func loadConversations() {
        do {
            let data = try Data(contentsOf: saveURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            conversations = try decoder.decode([Conversation].self, from: data)
            conversations.sort()
        } catch {
            // 파일이 없거나 파싱 실패 시 빈 배열
            conversations = []
        }
    }
    
    // MARK: - 유틸리티
    
    /// 날짜 그룹 키를 사람이 읽기 쉬운 형태로 변환
    private func formatGroupDate(_ key: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: key) else {
            return key
        }
        
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "오늘"
        } else if calendar.isDateInYesterday(date) {
            return "어제"
        } else if calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
            formatter.dateFormat = "EEEE"
            formatter.locale = Locale(identifier: "ko_KR")
            return formatter.string(from: date)
        } else if calendar.isDate(date, equalTo: Date(), toGranularity: .year) {
            formatter.dateFormat = "M월 d일"
            formatter.locale = Locale(identifier: "ko_KR")
            return formatter.string(from: date)
        } else {
            formatter.dateFormat = "yyyy년 M월"
            formatter.locale = Locale(identifier: "ko_KR")
            return formatter.string(from: date)
        }
    }
    
    // MARK: - 통계
    
    /// 전체 대화 수
    var totalConversationCount: Int {
        conversations.count
    }
    
    /// 전체 메시지 수
    var totalMessageCount: Int {
        conversations.reduce(0) { $0 + $1.messageCount }
    }
    
    /// 전체 토큰 사용량
    var totalTokenUsage: TokenUsage {
        conversations.reduce(TokenUsage()) { $0 + $1.totalTokenUsage }
    }
    
    /// 가장 많이 사용한 도구
    var mostUsedTools: [(tool: String, count: Int)] {
        var toolCounts: [String: Int] = [:]
        
        for conv in conversations {
            for msg in conv.messages {
                for toolCall in msg.toolCalls {
                    toolCounts[toolCall.toolName, default: 0] += 1
                }
            }
        }
        
        return toolCounts
            .map { (tool: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
}

// MARK: - 스트리밍 상태 접근

extension ConversationManager {
    
    /// 현재 스트리밍 중인 텍스트
    var streamingText: String {
        chatService.streamingText
    }
    
    /// 응답 생성 중 여부
    var isGenerating: Bool {
        chatService.isGenerating
    }
    
    /// 에러 메시지
    var errorMessage: String? {
        chatService.errorMessage
    }
    
    /// 마지막 응답 시간
    var lastResponseTime: TimeInterval? {
        chatService.lastResponseTime
    }
}

// MARK: - 프리뷰 지원

extension ConversationManager {
    
    /// 프리뷰용 매니저
    static var preview: ConversationManager {
        let manager = ConversationManager()
        manager.conversations = Conversation.previewList
        manager.activeConversationId = manager.conversations.first?.id
        return manager
    }
}
