import SwiftUI
import FoundationModels

// 책임감 있는 AI UX 구현
struct ResponsibleAIChatView: View {
    @StateObject var viewModel = ChatViewModel()
    @State var input = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // AI 기능 고지
            AIDisclaimer()
            
            // 채팅 영역
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message)
                    }
                }
                .padding()
            }
            
            // 입력 영역
            InputArea(input: $input) {
                Task { await viewModel.send(input) }
                input = ""
            }
        }
    }
}

// AI 사용 고지 배너
struct AIDisclaimer: View {
    var body: some View {
        HStack {
            Image(systemName: "sparkles")
                .foregroundStyle(.blue)
            
            Text("AI가 생성한 응답입니다. 중요한 정보는 직접 확인하세요.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }
}

// 메시지 버블에 AI 표시
struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        VStack(alignment: message.role == .user ? .trailing : .leading) {
            HStack(spacing: 4) {
                if message.role == .assistant {
                    // AI 응답임을 표시
                    Image(systemName: "sparkles")
                        .font(.caption2)
                        .foregroundStyle(.blue)
                }
                
                Text(message.content)
                    .padding()
                    .background(
                        message.role == .user 
                            ? Color.blue 
                            : Color(.systemGray5)
                    )
                    .foregroundStyle(
                        message.role == .user ? .white : .primary
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            
            // AI 응답에 피드백 버튼
            if message.role == .assistant {
                HStack {
                    Button(action: { /* 유용함 */ }) {
                        Image(systemName: "hand.thumbsup")
                    }
                    Button(action: { /* 문제 신고 */ }) {
                        Image(systemName: "hand.thumbsdown")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }
}

struct InputArea: View {
    @Binding var input: String
    let onSend: () -> Void
    
    var body: some View {
        HStack {
            TextField("메시지 입력...", text: $input)
                .textFieldStyle(.roundedBorder)
            
            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
            }
            .disabled(input.isEmpty)
        }
        .padding()
    }
}
