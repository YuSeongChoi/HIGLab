// AIChatbotApp.swift
// AI 채팅봇 앱 진입점
// iOS 26+ | FoundationModels

import SwiftUI

/// AI 채팅봇 앱
/// FoundationModels 프레임워크를 활용한 온디바이스 AI 채팅
@main
struct AIChatbotApp: App {
    
    /// 대화 저장소 (앱 전역 상태)
    @State private var conversationStore = ConversationStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(conversationStore)
        }
    }
}
