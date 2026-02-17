import SwiftUI
import AVKit
import GroupActivities

// MARK: - 비디오 플레이어 뷰
// SharePlay 동기화를 지원하는 비디오 플레이어

struct VideoPlayerView: View {
    @EnvironmentObject var sharePlayManager: SharePlayManager
    @EnvironmentObject var groupStateObserver: GroupStateObserver
    
    /// 재생할 비디오
    let video: Video
    
    /// 화면 닫기
    @Environment(\.dismiss) private var dismiss
    
    /// 플레이어 객체
    @StateObject private var playerController = VideoPlayerController()
    
    /// 컨트롤 표시 여부
    @State private var showControls = true
    
    /// 반응 선택 패널 표시
    @State private var showReactions = false
    
    /// 채팅 패널 표시
    @State private var showChat = false
    
    /// 참여자 패널 표시
    @State private var showParticipants = false
    
    /// 컨트롤 숨김 타이머
    @State private var hideControlsTask: Task<Void, Never>?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 배경
                Color.black.ignoresSafeArea()
                
                // 비디오 플레이어
                videoPlayerContent
                
                // 컨트롤 오버레이
                if showControls {
                    controlsOverlay(geometry: geometry)
                }
                
                // 반응 애니메이션
                reactionsOverlay
                
                // 사이드 패널들
                if showChat {
                    chatPanel
                }
                
                if showParticipants {
                    participantsPanel
                }
            }
        }
        .statusBarHidden()
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            playerController.cleanup()
        }
        .onTapGesture {
            toggleControls()
        }
        // SharePlay 상태 변경 감시
        .onChange(of: sharePlayManager.playbackState) { _, newState in
            playerController.syncWithState(newState)
        }
    }
    
    // MARK: - 비디오 플레이어 콘텐츠
    private var videoPlayerContent: some View {
        VideoPlayer(player: playerController.player)
            .ignoresSafeArea()
    }
    
    // MARK: - 컨트롤 오버레이
    private func controlsOverlay(geometry: GeometryProxy) -> some View {
        VStack {
            // 상단 바
            topBar
            
            Spacer()
            
            // 중앙 컨트롤
            centerControls
            
            Spacer()
            
            // 하단 바
            bottomBar(width: geometry.size.width)
        }
        .background(
            LinearGradient(
                colors: [.black.opacity(0.7), .clear, .clear, .black.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
    
    // MARK: - 상단 바
    private var topBar: some View {
        HStack {
            // 닫기 버튼
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .padding()
            }
            
            Spacer()
            
            // 비디오 정보
            VStack(spacing: 2) {
                Text(video.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                
                if sharePlayManager.sessionState.isActive {
                    HStack(spacing: 4) {
                        Image(systemName: "shareplay")
                        Text(sharePlayManager.sessionState.description)
                    }
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                }
            }
            
            Spacer()
            
            // 메뉴 버튼들
            HStack(spacing: 16) {
                // 참여자 버튼
                if sharePlayManager.sessionState.isActive {
                    Button {
                        showParticipants.toggle()
                    } label: {
                        Image(systemName: "person.2.fill")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                }
                
                // 채팅 버튼
                if sharePlayManager.configuration.chatEnabled && sharePlayManager.sessionState.isActive {
                    Button {
                        showChat.toggle()
                    } label: {
                        Image(systemName: "bubble.left.fill")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(.trailing)
        }
        .padding(.top, 8)
    }
    
    // MARK: - 중앙 컨트롤
    private var centerControls: some View {
        HStack(spacing: 48) {
            // 10초 뒤로
            Button {
                seekBackward()
            } label: {
                Image(systemName: "gobackward.10")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
            }
            
            // 재생/일시정지
            Button {
                togglePlayback()
            } label: {
                Image(systemName: sharePlayManager.playbackState.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.white)
            }
            
            // 10초 앞으로
            Button {
                seekForward()
            } label: {
                Image(systemName: "goforward.10")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
            }
        }
    }
    
    // MARK: - 하단 바
    private func bottomBar(width: CGFloat) -> some View {
        VStack(spacing: 8) {
            // 진행 바
            ProgressSlider(
                currentTime: playerController.currentTime,
                duration: video.duration
            ) { time in
                seek(to: time)
            }
            
            HStack {
                // 현재 시간 / 전체 시간
                Text("\(formatTime(playerController.currentTime)) / \(formatTime(video.duration))")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                    .monospacedDigit()
                
                Spacer()
                
                // 반응 버튼 (SharePlay 활성화 시)
                if sharePlayManager.sessionState.isActive && sharePlayManager.configuration.showReactions {
                    Button {
                        showReactions.toggle()
                    } label: {
                        Image(systemName: "face.smiling")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                }
                
                // 재생 속도
                Menu {
                    ForEach([0.5, 0.75, 1.0, 1.25, 1.5, 2.0], id: \.self) { rate in
                        Button {
                            setPlaybackRate(Float(rate))
                        } label: {
                            HStack {
                                Text("\(rate, specifier: "%.2g")x")
                                if sharePlayManager.playbackState.playbackRate == Float(rate) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Text("\(sharePlayManager.playbackState.playbackRate, specifier: "%.2g")x")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.white.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 24)
        
        // 반응 선택 패널
        if showReactions {
            reactionPicker
        }
    }
    
    // MARK: - 반응 선택 패널
    private var reactionPicker: some View {
        HStack(spacing: 20) {
            ForEach(["👍", "❤️", "😂", "😮", "😢", "🔥"], id: \.self) { emoji in
                Button {
                    sendReaction(emoji)
                } label: {
                    Text(emoji)
                        .font(.largeTitle)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .padding(.bottom, 8)
    }
    
    // MARK: - 반응 오버레이
    private var reactionsOverlay: some View {
        ForEach(sharePlayManager.reactions, id: \.timestamp) { reaction in
            ReactionBubble(reaction: reaction)
        }
    }
    
    // MARK: - 채팅 패널
    private var chatPanel: some View {
        HStack {
            Spacer()
            
            ChatPanelView()
                .frame(width: 300)
                .background(.ultraThinMaterial)
        }
    }
    
    // MARK: - 참여자 패널
    private var participantsPanel: some View {
        HStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("참여자")
                    .font(.headline)
                    .foregroundStyle(.white)
                
                ForEach(sharePlayManager.participants) { participant in
                    ParticipantRow(participant: participant)
                }
            }
            .padding()
            .frame(width: 250)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding()
        }
    }
    
    // MARK: - 액션
    
    private func setupPlayer() {
        playerController.load(url: video.url)
        
        // 기존 SharePlay 세션이 있으면 동기화
        if sharePlayManager.sessionState.isActive {
            playerController.syncWithState(sharePlayManager.playbackState)
        }
    }
    
    private func toggleControls() {
        showControls.toggle()
        
        if showControls {
            scheduleHideControls()
        }
    }
    
    private func scheduleHideControls() {
        hideControlsTask?.cancel()
        hideControlsTask = Task {
            try? await Task.sleep(for: .seconds(5))
            if !Task.isCancelled {
                showControls = false
            }
        }
    }
    
    private func togglePlayback() {
        Task {
            await sharePlayManager.togglePlayback()
        }
    }
    
    private func seek(to time: TimeInterval) {
        Task {
            await sharePlayManager.seek(to: time)
        }
    }
    
    private func seekBackward() {
        let newTime = max(0, playerController.currentTime - 10)
        seek(to: newTime)
    }
    
    private func seekForward() {
        let newTime = min(video.duration, playerController.currentTime + 10)
        seek(to: newTime)
    }
    
    private func setPlaybackRate(_ rate: Float) {
        Task {
            await sharePlayManager.setPlaybackRate(rate)
        }
    }
    
    private func sendReaction(_ emoji: String) {
        Task {
            await sharePlayManager.sendReaction(emoji)
        }
        showReactions = false
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: - 프로그레스 슬라이더
struct ProgressSlider: View {
    let currentTime: TimeInterval
    let duration: TimeInterval
    let onSeek: (TimeInterval) -> Void
    
    @State private var isDragging = false
    @State private var dragProgress: CGFloat = 0
    
    private var progress: CGFloat {
        guard duration > 0 else { return 0 }
        return isDragging ? dragProgress : currentTime / duration
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 배경 트랙
                RoundedRectangle(cornerRadius: 2)
                    .fill(.white.opacity(0.3))
                    .frame(height: 4)
                
                // 진행 트랙
                RoundedRectangle(cornerRadius: 2)
                    .fill(.white)
                    .frame(width: geometry.size.width * progress, height: 4)
                
                // 드래그 핸들
                Circle()
                    .fill(.white)
                    .frame(width: isDragging ? 16 : 12, height: isDragging ? 16 : 12)
                    .offset(x: geometry.size.width * progress - (isDragging ? 8 : 6))
            }
            .frame(height: 24)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDragging = true
                        dragProgress = max(0, min(1, value.location.x / geometry.size.width))
                    }
                    .onEnded { _ in
                        isDragging = false
                        onSeek(duration * dragProgress)
                    }
            )
        }
        .frame(height: 24)
        .animation(.easeOut(duration: 0.1), value: isDragging)
    }
}

// MARK: - 반응 버블
struct ReactionBubble: View {
    let reaction: ReactionMessage
    
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1
    
    var body: some View {
        Text(reaction.emoji)
            .font(.system(size: 48))
            .offset(y: offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 2)) {
                    offset = -200
                    opacity = 0
                }
            }
            .position(
                x: CGFloat.random(in: 100...300),
                y: UIScreen.main.bounds.height - 150
            )
    }
}

// MARK: - 참여자 행
struct ParticipantRow: View {
    let participant: WatchPartyParticipant
    
    var body: some View {
        HStack {
            Image(systemName: participant.avatarName)
                .font(.title2)
                .foregroundStyle(.white)
            
            VStack(alignment: .leading) {
                Text(participant.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color(participant.status.colorName))
                        .frame(width: 6, height: 6)
                    Text(participant.role.displayName)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            
            Spacer()
            
            if participant.role == .host {
                Image(systemName: participant.role.iconName)
                    .foregroundStyle(.yellow)
            }
        }
    }
}

// MARK: - 채팅 패널 뷰
struct ChatPanelView: View {
    @EnvironmentObject var sharePlayManager: SharePlayManager
    @State private var messageText = ""
    
    var body: some View {
        VStack {
            // 메시지 목록
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(sharePlayManager.chatMessages) { message in
                        ChatMessageBubble(message: message)
                    }
                }
                .padding()
            }
            
            // 입력창
            HStack {
                TextField("메시지 입력...", text: $messageText)
                    .textFieldStyle(.roundedBorder)
                
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
        }
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        Task {
            await sharePlayManager.sendChatMessage(messageText, senderName: "나")
            messageText = ""
        }
    }
}

// MARK: - 채팅 메시지 버블
struct ChatMessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(message.senderName)
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            Text(message.text)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Preview
#Preview {
    VideoPlayerView(video: Video.samples[0])
        .environmentObject(SharePlayManager())
        .environmentObject(GroupStateObserver())
}
