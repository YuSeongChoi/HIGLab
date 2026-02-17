import SwiftUI
import MusicKit

// MARK: - Now Playing View
// 현재 재생 중인 곡의 전체 화면 UI

struct NowPlayingView: View {
    @EnvironmentObject var playerManager: PlayerManager
    
    @State private var isDragging = false
    @State private var dragProgress: Double = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let song = playerManager.currentSong {
                    // 재생 중인 곡 있음
                    playerContent(song: song)
                } else {
                    // 재생 중인 곡 없음
                    emptyState
                }
            }
            .navigationTitle("지금 재생 중")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Player Content
    
    @ViewBuilder
    private func playerContent(song: SongItem) -> some View {
        VStack(spacing: 32) {
            Spacer()
            
            // 앨범 아트워크
            artworkView(song: song)
            
            // 곡 정보
            songInfo(song: song)
            
            // 진행 바
            progressBar
            
            // 재생 컨트롤
            playbackControls
            
            // 추가 컨트롤 (셔플, 반복)
            additionalControls
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Artwork
    
    @ViewBuilder
    private func artworkView(song: SongItem) -> some View {
        Group {
            if let artwork = song.artwork {
                ArtworkImage(artwork, width: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [.purple.opacity(0.6), .blue.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 300, height: 300)
                    .overlay {
                        Image(systemName: "music.note")
                            .font(.system(size: 80))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
            }
        }
        .scaleEffect(playerManager.isPlaying ? 1.0 : 0.95)
        .animation(.spring(response: 0.4), value: playerManager.isPlaying)
    }
    
    // MARK: - Song Info
    
    @ViewBuilder
    private func songInfo(song: SongItem) -> some View {
        VStack(spacing: 8) {
            // 곡 제목 (MarqueeText 효과)
            Text(song.title)
                .font(.title2)
                .fontWeight(.bold)
                .lineLimit(1)
            
            // 아티스트
            Text(song.artistName)
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Progress Bar
    
    private var progressBar: some View {
        VStack(spacing: 8) {
            // 슬라이더
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 배경
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.tertiary)
                        .frame(height: 4)
                    
                    // 진행 바
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.primary)
                        .frame(
                            width: geometry.size.width * currentProgress,
                            height: 4
                        )
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            isDragging = true
                            dragProgress = min(max(value.location.x / geometry.size.width, 0), 1)
                        }
                        .onEnded { value in
                            let progress = min(max(value.location.x / geometry.size.width, 0), 1)
                            playerManager.setProgress(progress)
                            isDragging = false
                        }
                )
            }
            .frame(height: 4)
            
            // 시간 표시
            HStack {
                Text(playerManager.currentTimeFormatted)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                
                Spacer()
                
                Text(playerManager.durationFormatted)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
    }
    
    private var currentProgress: Double {
        isDragging ? dragProgress : playerManager.progress
    }
    
    // MARK: - Playback Controls
    
    private var playbackControls: some View {
        HStack(spacing: 40) {
            // 이전 곡
            Button {
                skipToPrevious()
            } label: {
                Image(systemName: "backward.fill")
                    .font(.title)
            }
            
            // 재생/일시정지
            Button {
                togglePlayPause()
            } label: {
                Image(systemName: playerManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 70))
            }
            
            // 다음 곡
            Button {
                skipToNext()
            } label: {
                Image(systemName: "forward.fill")
                    .font(.title)
            }
        }
        .foregroundStyle(.primary)
    }
    
    // MARK: - Additional Controls
    
    private var additionalControls: some View {
        HStack(spacing: 60) {
            // 셔플
            Button {
                playerManager.toggleShuffle()
            } label: {
                Image(systemName: "shuffle")
                    .font(.title3)
                    .foregroundStyle(
                        playerManager.shuffleMode == .off ? .secondary : .accentColor
                    )
            }
            
            // 반복
            Button {
                playerManager.cycleRepeatMode()
            } label: {
                Image(systemName: repeatModeIcon)
                    .font(.title3)
                    .foregroundStyle(
                        playerManager.repeatMode == .none ? .secondary : .accentColor
                    )
            }
        }
    }
    
    private var repeatModeIcon: String {
        switch playerManager.repeatMode {
        case .one:
            return "repeat.1"
        default:
            return "repeat"
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        ContentUnavailableView(
            "재생 중인 곡 없음",
            systemImage: "music.note",
            description: Text("검색이나 보관함에서\n음악을 선택해주세요.")
        )
    }
    
    // MARK: - Actions
    
    private func togglePlayPause() {
        Task {
            try? await playerManager.togglePlayPause()
        }
    }
    
    private func skipToNext() {
        Task {
            try? await playerManager.skipToNext()
        }
    }
    
    private func skipToPrevious() {
        Task {
            try? await playerManager.skipToPrevious()
        }
    }
}

#Preview {
    NowPlayingView()
        .environmentObject(PlayerManager.shared)
}
