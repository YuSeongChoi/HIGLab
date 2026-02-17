// InputBarView.swift
// 채팅 입력창
// iOS 26+ | FoundationModels

import SwiftUI

/// 메시지 입력 바
struct InputBarView: View {
    
    @Environment(ConversationStore.self) private var store
    @State private var inputText: String = ""
    @FocusState private var isFocused: Bool
    
    /// 전송 가능 여부
    private var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !store.isGenerating
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            // 텍스트 입력 필드
            textField
            
            // 전송 버튼
            sendButton
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.bar)
    }
    
    // MARK: - 텍스트 필드
    
    private var textField: some View {
        TextField("메시지를 입력하세요...", text: $inputText, axis: .vertical)
            .textFieldStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 20))
            .lineLimit(1...5)
            .focused($isFocused)
            .submitLabel(.send)
            .onSubmit {
                sendMessage()
            }
    }
    
    // MARK: - 전송 버튼
    
    private var sendButton: some View {
        Button {
            sendMessage()
        } label: {
            Image(systemName: store.isGenerating ? "stop.fill" : "arrow.up.circle.fill")
                .font(.title)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(buttonColor)
        }
        .disabled(!canSend && !store.isGenerating)
        .animation(.easeInOut(duration: 0.2), value: store.isGenerating)
    }
    
    /// 버튼 색상
    private var buttonColor: Color {
        if store.isGenerating {
            return .red
        } else if canSend {
            return .accentColor
        } else {
            return .secondary
        }
    }
    
    // MARK: - 액션
    
    private func sendMessage() {
        // 생성 중이면 취소
        if store.isGenerating {
            store.chatManager.cancel()
            return
        }
        
        // 빈 메시지 무시
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        // 입력 초기화
        let message = trimmed
        inputText = ""
        
        // 메시지 전송
        Task {
            await store.send(message)
        }
    }
}

// MARK: - 프리뷰

#Preview {
    VStack {
        Spacer()
        InputBarView()
    }
    .environment(ConversationStore())
}

#Preview("With Text") {
    VStack {
        Spacer()
        InputBarView()
    }
    .environment(ConversationStore())
}
