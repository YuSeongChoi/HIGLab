import SwiftUI

struct ChatView: View {
    @State private var aiManager = AIManager()
    @State private var messages: [ChatMessage] = []
    @State private var inputText = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !aiManager.isAvailable {
                    unavailableView
                } else if messages.isEmpty {
                    emptyStateView
                } else {
                    messageList
                }
                
                inputBar
            }
            .navigationTitle("AI 어시스턴트")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        messages.removeAll()
                        aiManager.resetSession()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .disabled(messages.isEmpty)
                }
            }
        }
    }
    
    // MARK: - Unavailable View
    private var unavailableView: some View {
        ContentUnavailableView(
            "AI 모델 사용 불가",
            systemImage: "brain",
            description: Text("Foundation Models를 사용하려면 iOS 26 이상과 Apple Silicon이 필요합니다.")
        )
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundStyle(.accent)
            
            Text("무엇이든 물어보세요")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("온디바이스 AI가 답변해드립니다")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            // 추천 질문
            VStack(spacing: 12) {
                SuggestionButton(text: "오늘 날씨 어때?") {
                    sendMessage("오늘 날씨 어때?")
                }
                SuggestionButton(text: "Swift의 장점을 알려줘") {
                    sendMessage("Swift의 장점을 알려줘")
                }
                SuggestionButton(text: "간단한 운동 추천해줘") {
                    sendMessage("간단한 운동 추천해줘")
                }
            }
            .padding(.top)
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Message List
    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(messages) { message in
                        MessageBubble(message: message)
                    }
                    
                    // 생성 중 표시
                    if aiManager.isGenerating {
                        HStack {
                            TypingIndicator()
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
            }
            .onChange(of: messages.count) {
                withAnimation {
                    proxy.scrollTo(messages.last?.id, anchor: .bottom)
                }
            }
        }
    }
    
    // MARK: - Input Bar
    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("메시지 입력...", text: $inputText, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .focused($isInputFocused)
                .lineLimit(5)
            
            Button {
                sendMessage(inputText)
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(inputText.isEmpty ? .gray : .accent)
            }
            .disabled(inputText.isEmpty || aiManager.isGenerating)
        }
        .padding()
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Send Message
    private func sendMessage(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        // 사용자 메시지 추가
        let userMessage = ChatMessage(role: .user, content: trimmed)
        messages.append(userMessage)
        inputText = ""
        isInputFocused = false
        
        // AI 응답 요청
        Task {
            do {
                let response = try await aiManager.sendMessage(trimmed)
                let aiMessage = ChatMessage(role: .assistant, content: response)
                messages.append(aiMessage)
            } catch {
                let errorMessage = ChatMessage(role: .assistant, content: "오류가 발생했습니다: \(error.localizedDescription)")
                messages.append(errorMessage)
            }
        }
    }
}

// MARK: - Chat Message Model
struct ChatMessage: Identifiable {
    let id = UUID()
    let role: Role
    let content: String
    let timestamp = Date()
    
    enum Role {
        case user
        case assistant
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.role == .user { Spacer() }
            
            Text(message.content)
                .padding(12)
                .background(message.role == .user ? Color.accentColor : Color(.systemGray5))
                .foregroundStyle(message.role == .user ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            if message.role == .assistant { Spacer() }
        }
    }
}

// MARK: - Suggestion Button
struct SuggestionButton: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Typing Indicator
struct TypingIndicator: View {
    @State private var dotCount = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.gray)
                    .frame(width: 8, height: 8)
                    .opacity(dotCount == index ? 1 : 0.3)
            }
        }
        .padding(12)
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
                dotCount = (dotCount + 1) % 3
            }
        }
    }
}

#Preview {
    ChatView()
}
