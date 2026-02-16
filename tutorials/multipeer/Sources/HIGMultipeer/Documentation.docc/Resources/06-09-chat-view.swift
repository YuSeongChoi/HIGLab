import SwiftUI

struct ChatView: View {
    @ObservedObject var chatManager: ChatManager
    @State private var inputText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // 메시지 목록
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(chatManager.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: chatManager.messages.count) {
                    if let lastMessage = chatManager.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            Divider()
            
            // 입력 영역
            MessageInputView(text: $inputText) {
                chatManager.sendText(inputText)
                inputText = ""
            }
        }
        .navigationTitle("채팅")
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromMe { Spacer() }
            
            VStack(alignment: message.isFromMe ? .trailing : .leading) {
                if !message.isFromMe {
                    Text(message.senderName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Text(message.content)
                    .padding(12)
                    .background(message.isFromMe ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundStyle(message.isFromMe ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            
            if !message.isFromMe { Spacer() }
        }
    }
}
