import SwiftUI
import MusicKit

// MARK: - Mini Player View
// 하단에 표시되는 미니 플레이어

struct MiniPlayerView: View {
    @EnvironmentObject var playerManager: PlayerManager
    
    var onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 진행 바 (얇은 라인)
            GeometryReader { geometry in
                Rectangle()
                    .fill(.primary.opacity(0.3))
                    .frame(width: geometry.size.width * playerManager.progress, height: 2)
            }
            .frame(height: 2)
            
            // 미니 플레이어 콘텐츠
            HStack(spacing: 12) {
                // 앨범 아트워크
                artworkView
                    .frame(width: 44, height: 44)
                
                // 곡 정보
                songInfoView
                
                Spacer()
                
                // 재생 컨트롤
                playbackControls
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
    
    // MARK: - Artwork View
    
    @ViewBuilder
    private var artworkView: some View {
        if let song = playerManager.currentSong, let artwork = song.artwork {
            ArtworkImage(artwork, width: 44)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        } else {
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    LinearGradient(
                        colors: [.purple.opacity(0.5), .blue.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    Image(systemName: "music.note")
                        .font(.caption)
                        .foregroundStyle(.white)
                }
        }
    }
    
    // MARK: - Song Info View
    
    @ViewBuilder
    private var songInfoView: some View {
        if let song = playerManager.currentSong {
            VStack(alignment: .leading, spacing: 2) {
                Text(song.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(song.artistName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        } else {
            Text("재생 중인 곡 없음")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Playback Controls
    
    private var playbackControls: some View {
        HStack(spacing: 16) {
            // 재생/일시정지
            Button {
                togglePlayPause()
            } label: {
                Image(systemName: playerManager.isPlaying ? "pause.fill" : "play.fill")
                    .font(.title3)
                    .frame(width: 32, height: 32)
            }
            
            // 다음 곡
            Button {
                skipToNext()
            } label: {
                Image(systemName: "forward.fill")
                    .font(.body)
                    .frame(width: 32, height: 32)
            }
        }
        .foregroundStyle(.primary)
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
}

#Preview {
    VStack {
        Spacer()
        MiniPlayerView {
            print("Mini player tapped")
        }
        .environmentObject(PlayerManager.shared)
    }
}
