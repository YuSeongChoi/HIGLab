// ChatView.swift
// PeerChat - MultipeerConnectivity 기반 P2P 채팅
// 1:1 채팅 화면

import SwiftUI
import PhotosUI

/// 채팅 뷰
struct ChatView: View {
    let peer: DiscoveredPeer
    
    @EnvironmentObject var multipeerService: MultipeerService
    @State private var messageText = ""
    @State private var showingFilePicker = false
    @State private var showingPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showingError = false
    @State private var errorMessage = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // 메시지 목록
            messageList
            
            // 입력 영역
            inputArea
        }
        .navigationTitle(peer.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                connectionStatusBadge
            }
        }
        .alert("오류", isPresented: $showingError) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showingFilePicker) {
            DocumentPickerView { url in
                handleSelectedFile(url)
            }
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            handleSelectedPhoto(newItem)
        }
        .onAppear {
            multipeerService.markAsRead(for: peer.id)
        }
    }
    
    // MARK: - Message List
    
    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(multipeerService.getMessages(for: peer.id)) { message in
                        MessageBubbleView(
                            message: message,
                            isFromMe: message.senderID == multipeerService.localDisplayName
                        )
                        .id(message.id)
                    }
                }
                .padding()
            }
            .onChange(of: multipeerService.getMessages(for: peer.id).count) { _, _ in
                // 새 메시지 시 스크롤
                if let lastMessage = multipeerService.getMessages(for: peer.id).last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    // MARK: - Input Area
    
    private var inputArea: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 12) {
                // 첨부 버튼
                Menu {
                    Button {
                        showingPhotoPicker = true
                    } label: {
                        Label("사진 보내기", systemImage: "photo")
                    }
                    
                    Button {
                        showingFilePicker = true
                    } label: {
                        Label("파일 보내기", systemImage: "doc")
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.tint)
                }
                .photosPicker(
                    isPresented: $showingPhotoPicker,
                    selection: $selectedPhotoItem,
                    matching: .images
                )
                
                // 텍스트 입력
                TextField("메시지", text: $messageText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .focused($isInputFocused)
                    .lineLimit(1...5)
                
                // 전송 버튼
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundStyle(messageText.isEmpty ? .gray : .tint)
                }
                .disabled(messageText.isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - Connection Status Badge
    
    private var connectionStatusBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            Text(peer.state.displayText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private var statusColor: Color {
        switch peer.state {
        case .connected:
            return .green
        case .connecting:
            return .orange
        case .notConnected:
            return .gray
        }
    }
    
    // MARK: - Actions
    
    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        do {
            try multipeerService.sendMessage(text, to: peer)
            messageText = ""
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    private func handleSelectedFile(_ url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        
        do {
            let data = try Data(contentsOf: url)
            let fileName = url.lastPathComponent
            let fileType = SupportedFileType.from(extension: url.pathExtension)
            
            try multipeerService.sendFile(
                data,
                fileName: fileName,
                mimeType: fileType.mimeType,
                to: peer
            )
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    private func handleSelectedPhoto(_ item: PhotosPickerItem?) {
        guard let item = item else { return }
        
        Task {
            if let data = try? await item.loadTransferable(type: Data.self) {
                do {
                    try multipeerService.sendFile(
                        data,
                        fileName: "photo.jpg",
                        mimeType: "image/jpeg",
                        to: peer
                    )
                } catch {
                    await MainActor.run {
                        errorMessage = error.localizedDescription
                        showingError = true
                    }
                }
            }
        }
    }
}

/// 메시지 버블 뷰
struct MessageBubbleView: View {
    let message: ChatMessage
    let isFromMe: Bool
    
    var body: some View {
        HStack {
            if isFromMe { Spacer(minLength: 60) }
            
            VStack(alignment: isFromMe ? .trailing : .leading, spacing: 4) {
                // 발신자 이름 (상대방 메시지일 때만)
                if !isFromMe && message.type != .system {
                    Text(message.senderName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // 메시지 내용
                messageContent
                
                // 시간
                if message.type != .system {
                    Text(message.formattedTime)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            if !isFromMe { Spacer(minLength: 60) }
        }
    }
    
    @ViewBuilder
    private var messageContent: some View {
        switch message.type {
        case .text:
            textBubble
            
        case .file:
            fileBubble
            
        case .system:
            systemMessage
            
        case .typing:
            typingIndicator
        }
    }
    
    private var textBubble: some View {
        Text(message.content)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isFromMe ? Color.accentColor : Color(.systemGray5))
            .foregroundStyle(isFromMe ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 18))
    }
    
    private var fileBubble: some View {
        HStack(spacing: 10) {
            // 파일 아이콘
            Image(systemName: fileIcon)
                .font(.title2)
                .foregroundStyle(isFromMe ? .white : .accentColor)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(message.content)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                
                if let size = message.formattedFileSize {
                    Text(size)
                        .font(.caption)
                        .foregroundStyle(isFromMe ? .white.opacity(0.8) : .secondary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(isFromMe ? Color.accentColor : Color(.systemGray5))
        .foregroundStyle(isFromMe ? .white : .primary)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
    
    private var fileIcon: String {
        if let mimeType = message.fileMimeType {
            if mimeType.hasPrefix("image") {
                return "photo"
            } else if mimeType.contains("pdf") {
                return "doc.richtext"
            }
        }
        return "doc"
    }
    
    private var systemMessage: some View {
        Text(message.content)
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(.systemGray6))
            .clipShape(Capsule())
    }
    
    private var typingIndicator: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.secondary)
                    .frame(width: 6, height: 6)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

/// 문서 선택 뷰
struct DocumentPickerView: UIViewControllerRepresentable {
    let onSelect: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: [.item],
            asCopy: true
        )
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onSelect: (URL) -> Void
        
        init(onSelect: @escaping (URL) -> Void) {
            self.onSelect = onSelect
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                onSelect(url)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChatView(peer: DiscoveredPeer(peerID: MCPeerID(displayName: "Test Peer")))
            .environmentObject(MultipeerService())
    }
}
