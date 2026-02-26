import SwiftUI

struct PeerListView: View {
    @Environment(ChatManager.self) private var chatManager
    
    var body: some View {
        NavigationStack {
            List {
                // 연결된 피어
                if !chatManager.connectedPeers.isEmpty {
                    Section("연결됨") {
                        ForEach(chatManager.connectedPeers, id: \.displayName) { peer in
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.green)
                                
                                Text(peer.displayName)
                                
                                Spacer()
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                }
                
                // 발견된 피어
                Section("주변 기기") {
                    if chatManager.discoveredPeers.isEmpty {
                        ContentUnavailableView(
                            "검색 중...",
                            systemImage: "antenna.radiowaves.left.and.right",
                            description: Text("주변에서 기기를 찾고 있습니다")
                        )
                    } else {
                        ForEach(chatManager.discoveredPeers, id: \.displayName) { peer in
                            Button {
                                chatManager.invite(peer)
                            } label: {
                                HStack {
                                    Image(systemName: "person.circle")
                                        .font(.title2)
                                        .foregroundStyle(.secondary)
                                    
                                    Text(peer.displayName)
                                        .foregroundStyle(.primary)
                                    
                                    Spacer()
                                    
                                    Text("초대")
                                        .font(.caption)
                                        .foregroundStyle(.accent)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("주변 기기")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Toggle(isOn: Binding(
                        get: { chatManager.isAdvertising },
                        set: { $0 ? chatManager.startAdvertising() : chatManager.stopAdvertising() }
                    )) {
                        Image(systemName: chatManager.isAdvertising ? "antenna.radiowaves.left.and.right.circle.fill" : "antenna.radiowaves.left.and.right.circle")
                    }
                }
            }
            .onAppear {
                chatManager.startBrowsing()
                chatManager.startAdvertising()
            }
            .onDisappear {
                chatManager.stopBrowsing()
            }
        }
    }
}

struct ChatListView: View {
    @Environment(ChatManager.self) private var chatManager
    @State private var messageText = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if chatManager.connectedPeers.isEmpty {
                    ContentUnavailableView(
                        "연결된 기기가 없습니다",
                        systemImage: "bubble.left.and.bubble.right",
                        description: Text("'주변' 탭에서 기기를 연결하세요")
                    )
                } else {
                    // 메시지 목록
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(chatManager.messages) { message in
                                    MessageRow(message: message)
                                        .id(message.id)
                                }
                            }
                            .padding()
                        }
                        .onChange(of: chatManager.messages.count) {
                            if let last = chatManager.messages.last {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                    
                    // 입력 바
                    HStack(spacing: 12) {
                        TextField("메시지 입력...", text: $messageText)
                            .textFieldStyle(.plain)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .clipShape(Capsule())
                        
                        Button {
                            chatManager.send(messageText)
                            messageText = ""
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title)
                                .foregroundStyle(messageText.isEmpty ? .gray : .accent)
                        }
                        .disabled(messageText.isEmpty)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                }
            }
            .navigationTitle("채팅")
        }
    }
}

struct MessageRow: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromMe { Spacer() }
            
            VStack(alignment: message.isFromMe ? .trailing : .leading, spacing: 4) {
                if !message.isFromMe {
                    Text(message.sender)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Text(message.content)
                    .padding(12)
                    .background(message.isFromMe ? Color.accentColor : Color(.systemGray5))
                    .foregroundStyle(message.isFromMe ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            
            if !message.isFromMe { Spacer() }
        }
    }
}

struct SettingsView: View {
    @Environment(ChatManager.self) private var chatManager
    
    var body: some View {
        NavigationStack {
            Form {
                Section("내 정보") {
                    LabeledContent("기기 이름", value: chatManager.displayName)
                }
                
                Section("연결") {
                    LabeledContent("연결된 기기", value: "\(chatManager.connectedPeers.count)개")
                    
                    if !chatManager.connectedPeers.isEmpty {
                        Button("모든 연결 해제", role: .destructive) {
                            chatManager.disconnect()
                        }
                    }
                }
            }
            .navigationTitle("설정")
        }
    }
}

#Preview {
    PeerListView()
        .environment(ChatManager())
}
