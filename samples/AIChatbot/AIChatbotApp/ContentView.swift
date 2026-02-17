// ContentView.swift
// 메인 채팅 UI
// iOS 26+ | FoundationModels

import SwiftUI
import FoundationModels

/// 메인 채팅 화면
struct ContentView: View {
    
    @Environment(ConversationStore.self) private var store
    @State private var showSettings = false
    @State private var showUnavailableAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 메시지 목록
                messageList
                
                // 구분선
                Divider()
                
                // 입력창
                InputBarView()
            }
            .navigationTitle("AI 채팅")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 설정 버튼
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                
                // 대화 초기화 버튼
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        store.clearConversation()
                    } label: {
                        Image(systemName: "trash")
                    }
                    .disabled(store.messages.isEmpty)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .alert("모델 사용 불가", isPresented: $showUnavailableAlert) {
                Button("확인", role: .cancel) { }
            } message: {
                Text("이 기기에서는 Apple Intelligence를 사용할 수 없습니다.")
            }
            .task {
                // 앱 시작 시 모델 가용성 확인
                await checkModelAvailability()
            }
        }
    }
    
    // MARK: - 메시지 목록
    
    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    // 환영 메시지 (대화가 비어있을 때)
                    if store.messages.isEmpty {
                        welcomeMessage
                    }
                    
                    // 메시지들
                    ForEach(store.messages) { message in
                        MessageBubbleView(message: message)
                            .id(message.id)
                    }
                    
                    // 스트리밍 중인 응답 표시
                    if store.isGenerating && !store.streamingText.isEmpty {
                        streamingBubble
                    }
                    
                    // 로딩 인디케이터
                    if store.isGenerating && store.streamingText.isEmpty {
                        loadingIndicator
                    }
                }
                .padding()
            }
            .onChange(of: store.messages.count) { _, _ in
                // 새 메시지가 추가되면 스크롤
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: store.streamingText) { _, _ in
                // 스트리밍 중 스크롤
                scrollToBottom(proxy: proxy)
            }
        }
    }
    
    // MARK: - 환영 메시지
    
    private var welcomeMessage: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 60))
                .foregroundStyle(.tint)
            
            Text("AI 채팅봇")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("무엇이든 물어보세요!\nApple Intelligence가 답변해드립니다.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 60)
    }
    
    // MARK: - 스트리밍 버블
    
    private var streamingBubble: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(store.streamingText)
                    .textSelection(.enabled)
            }
            .padding(12)
            .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
            
            Spacer(minLength: 60)
        }
    }
    
    // MARK: - 로딩 인디케이터
    
    private var loadingIndicator: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(.secondary)
                        .frame(width: 8, height: 8)
                        .scaleEffect(1.0)
                        .animation(
                            .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                            value: store.isGenerating
                        )
                }
            }
            .padding(12)
            .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
            
            Spacer()
        }
    }
    
    // MARK: - 헬퍼
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastMessage = store.messages.last {
            withAnimation(.easeOut(duration: 0.2)) {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
    
    private func checkModelAvailability() async {
        let availability = await ChatManager.checkAvailability()
        
        switch availability {
        case .available:
            break // 사용 가능
        case .unavailable:
            showUnavailableAlert = true
        @unknown default:
            break
        }
    }
}

// MARK: - 프리뷰

#Preview {
    ContentView()
        .environment(ConversationStore.preview)
}

#Preview("Empty") {
    ContentView()
        .environment(ConversationStore())
}
