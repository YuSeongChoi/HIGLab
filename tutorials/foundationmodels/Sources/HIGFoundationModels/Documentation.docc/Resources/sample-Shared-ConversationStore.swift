// ConversationStore.swift
// 대화 내역 저장 및 관리
// iOS 26+ | FoundationModels

import Foundation
import SwiftUI

/// 대화 저장소 - 메시지 관리 및 영속성
@MainActor
@Observable
final class ConversationStore {
    
    // MARK: - 상태
    
    /// 전체 메시지 목록
    private(set) var messages: [Message] = []
    
    /// ChatManager 참조
    let chatManager: ChatManager
    
    // MARK: - 파일 저장 경로
    
    private var saveURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("conversation.json")
    }
    
    // MARK: - 초기화
    
    init(chatManager: ChatManager = ChatManager()) {
        self.chatManager = chatManager
        loadMessages()
    }
    
    // MARK: - 메시지 관리
    
    /// 사용자 메시지를 보내고 AI 응답 받기
    /// - Parameter content: 사용자 메시지 내용
    func send(_ content: String) async {
        // 사용자 메시지 추가
        let userMessage = Message.user(content)
        messages.append(userMessage)
        
        // 플레이스홀더 AI 메시지 추가 (스트리밍 표시용)
        let placeholderID = UUID()
        let placeholder = Message(id: placeholderID, role: .assistant, content: "")
        messages.append(placeholder)
        
        do {
            // AI 응답 받기
            let response = try await chatManager.send(content)
            
            // 플레이스홀더를 실제 응답으로 교체
            if let index = messages.firstIndex(where: { $0.id == placeholderID }) {
                messages[index] = Message(
                    id: placeholderID,
                    role: .assistant,
                    content: response
                )
            }
            
            // 저장
            saveMessages()
            
        } catch {
            // 에러 발생 시 플레이스홀더 제거
            messages.removeAll { $0.id == placeholderID }
            print("❌ 메시지 전송 실패: \(error.localizedDescription)")
        }
    }
    
    /// 대화 초기화
    func clearConversation() {
        messages.removeAll()
        chatManager.resetSession()
        saveMessages()
    }
    
    /// 특정 메시지 삭제
    func deleteMessage(_ message: Message) {
        messages.removeAll { $0.id == message.id }
        saveMessages()
    }
    
    // MARK: - 영속성
    
    /// 메시지 저장
    private func saveMessages() {
        do {
            let data = try JSONEncoder().encode(messages)
            try data.write(to: saveURL)
        } catch {
            print("❌ 메시지 저장 실패: \(error.localizedDescription)")
        }
    }
    
    /// 메시지 로드
    private func loadMessages() {
        do {
            let data = try Data(contentsOf: saveURL)
            messages = try JSONDecoder().decode([Message].self, from: data)
        } catch {
            // 파일이 없거나 파싱 실패 시 빈 배열로 시작
            messages = []
        }
    }
}

// MARK: - 스트리밍 텍스트 접근

extension ConversationStore {
    /// 현재 스트리밍 중인 텍스트 (UI 업데이트용)
    var streamingText: String {
        chatManager.streamingText
    }
    
    /// 응답 생성 중 여부
    var isGenerating: Bool {
        chatManager.isGenerating
    }
    
    /// 에러 메시지
    var errorMessage: String? {
        chatManager.errorMessage
    }
}

// MARK: - 프리뷰 지원

extension ConversationStore {
    /// 프리뷰용 샘플 데이터
    static var preview: ConversationStore {
        let store = ConversationStore()
        store.messages = [
            .user("안녕하세요!"),
            .assistant("안녕하세요! 무엇을 도와드릴까요?"),
            .user("오늘 날씨가 어때요?"),
            .assistant("저는 실시간 날씨 정보에 접근할 수 없지만, 날씨 앱을 확인해보시는 걸 추천드려요! 😊")
        ]
        return store
    }
}
