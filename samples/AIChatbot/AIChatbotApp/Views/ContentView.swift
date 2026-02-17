// ContentView.swift
// 메인 채팅 UI
// iOS 26+ | FoundationModels
//
// 채팅 인터페이스의 메인 화면
// 메시지 목록, 입력창, 네비게이션을 포함

import SwiftUI
import FoundationModels

// MARK: - 메인 채팅 화면

/// 메인 채팅 화면
struct ContentView: View {
    
    // MARK: - 환경
    
    @Environment(ConversationManager.self) private var manager
    @Environment(SettingsStore.self) private var settings
    
    // MARK: - 상태
    
    @State private var showSettings = false
    @State private var showConversationList = false
    @State private var showExportSheet = false
    @State private var showUnavailableAlert = false
    @State private var showClearConfirmation = false
    @State private var scrollProxy: ScrollViewProxy?
    
    // MARK: - 본문
    
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
            .navigationTitle(manager.activeConversation?.title ?? "AI 채팅")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showConversationList) {
                ConversationListView()
            }
            .sheet(isPresented: $showExportSheet) {
                if let conversation = manager.activeConversation {
                    ExportView(conversation: conversation)
                }
            }
            .alert("모델 사용 불가", isPresented: $showUnavailableAlert) {
                Button("확인", role: .cancel) { }
            } message: {
                Text("이 기기에서는 Apple Intelligence를 사용할 수 없습니다.\n\nApple Silicon Mac 또는 A17 Pro 이상의 칩이 필요합니다.")
            }
            .confirmationDialog(
                "대화 내역 삭제",
                isPresented: $showClearConfirmation,
                titleVisibility: .visible
            ) {
                Button("삭제", role: .destructive) {
                    manager.clearCurrentConversation()
                }
                Button("취소", role: .cancel) { }
            } message: {
                Text("현재 대화의 모든 메시지가 삭제됩니다. 이 작업은 되돌릴 수 없습니다.")
            }
            .task {
                await checkModelAvailability()
            }
        }
    }
    
    // MARK: - 툴바
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        // 대화 목록 버튼
        ToolbarItem(placement: .topBarLeading) {
            Button {
                showConversationList = true
            } label: {
                Image(systemName: "list.bullet")
            }
        }
        
        // 메뉴 버튼
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                // 새 대화
                Button {
                    manager.createNewConversation()
                } label: {
                    Label("새 대화", systemImage: "plus.bubble")
                }
                
                Divider()
                
                // 내보내기
                Button {
                    showExportSheet = true
                } label: {
                    Label("내보내기", systemImage: "square.and.arrow.up")
                }
                .disabled(manager.messages.isEmpty)
                
                // 대화 초기화
                Button(role: .destructive) {
                    showClearConfirmation = true
                } label: {
                    Label("대화 초기화", systemImage: "trash")
                }
                .disabled(manager.messages.isEmpty)
                
                Divider()
                
                // 설정
                Button {
                    showSettings = true
                } label: {
                    Label("설정", systemImage: "gear")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
    
    // MARK: - 메시지 목록
    
    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    // 환영 메시지 (대화가 비어있을 때)
                    if manager.messages.isEmpty {
                        welcomeMessage
                    }
                    
                    // 메시지들
                    ForEach(manager.messages) { message in
                        MessageBubbleView(message: message)
                            .id(message.id)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .bottom)),
                                removal: .opacity
                            ))
                    }
                    
                    // 스트리밍 중인 응답 표시
                    if manager.isGenerating && !manager.streamingText.isEmpty {
                        streamingBubble
                            .id("streaming")
                    }
                    
                    // 로딩 인디케이터
                    if manager.isGenerating && manager.streamingText.isEmpty {
                        loadingIndicator
                            .id("loading")
                    }
                    
                    // 하단 여백
                    Spacer()
                        .frame(height: 8)
                        .id("bottom")
                }
                .padding()
            }
            .onAppear {
                scrollProxy = proxy
            }
            .onChange(of: manager.messages.count) { _, _ in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: manager.streamingText) { _, _ in
                scrollToBottom(proxy: proxy, animated: false)
            }
        }
    }
    
    // MARK: - 환영 메시지
    
    private var welcomeMessage: some View {
        VStack(spacing: 20) {
            // 아이콘
            ZStack {
                Circle()
                    .fill(.tint.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "brain")
                    .font(.system(size: 44))
                    .foregroundStyle(.tint)
            }
            
            // 제목
            Text("AI 채팅봇")
                .font(.title)
                .fontWeight(.bold)
            
            // 설명
            Text("무엇이든 물어보세요!\nApple Intelligence가 답변해드립니다.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            // 기능 소개
            VStack(spacing: 12) {
                featureRow(icon: "bubble.left.and.bubble.right", title: "자연스러운 대화", description: "자연어로 질문하세요")
                featureRow(icon: "wand.and.stars", title: "도구 활용", description: "날씨, 계산기 등 자동 사용")
                featureRow(icon: "iphone", title: "온디바이스 AI", description: "개인 정보 보호")
            }
            .padding(.top, 10)
        }
        .padding(.vertical, 40)
    }
    
    /// 기능 소개 행
    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.tint)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 30)
    }
    
    // MARK: - 스트리밍 버블
    
    private var streamingBubble: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                // AI 아이콘
                HStack(spacing: 6) {
                    Image(systemName: "brain")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("AI")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    // 타이핑 인디케이터
                    TypingIndicator()
                }
                
                // 스트리밍 텍스트
                Text(manager.streamingText)
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
            HStack(spacing: 6) {
                Image(systemName: "brain")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                TypingIndicator()
            }
            .padding(12)
            .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
            
            Spacer()
        }
    }
    
    // MARK: - 헬퍼
    
    /// 하단으로 스크롤
    private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool = true) {
        let anchor: UnitPoint = .bottom
        let id = manager.isGenerating ? "streaming" : (manager.messages.last?.id ?? "bottom")
        
        if animated {
            withAnimation(.easeOut(duration: 0.2)) {
                proxy.scrollTo(id, anchor: anchor)
            }
        } else {
            proxy.scrollTo(id, anchor: anchor)
        }
    }
    
    /// 모델 가용성 확인
    private func checkModelAvailability() async {
        let availability = await ChatService.checkAvailability()
        
        if !availability.isAvailable {
            showUnavailableAlert = true
        }
    }
}

// MARK: - 타이핑 인디케이터

/// 타이핑 중 표시 애니메이션
struct TypingIndicator: View {
    
    @State private var animating = false
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(.secondary)
                    .frame(width: 6, height: 6)
                    .scaleEffect(animating ? 1.0 : 0.5)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(Double(index) * 0.2),
                        value: animating
                    )
            }
        }
        .onAppear {
            animating = true
        }
    }
}

// MARK: - 프리뷰

#Preview {
    ContentView()
        .environment(ConversationManager.preview)
        .environment(SettingsStore.shared)
}

#Preview("Empty") {
    ContentView()
        .environment(ConversationManager())
        .environment(SettingsStore.shared)
}
