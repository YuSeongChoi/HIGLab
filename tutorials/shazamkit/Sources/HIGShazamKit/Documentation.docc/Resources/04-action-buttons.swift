import SwiftUI

/// 곡 관련 액션 버튼
struct SongActionButtons: View {
    let song: Song
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        HStack(spacing: 16) {
            // Apple Music에서 듣기
            if let url = song.appleMusicURL {
                Button {
                    openURL(url)
                } label: {
                    Label("Apple Music", systemImage: "play.fill")
                }
                .buttonStyle(.borderedProminent)
            }
            
            // 공유하기
            ShareLink(item: shareText) {
                Label("공유", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.bordered)
        }
    }
    
    private var shareText: String {
        var text = "🎵 \(song.title) - \(song.artist)"
        if let url = song.appleMusicURL {
            text += "\n\(url.absoluteString)"
        }
        return text
    }
}

/// 더 많은 액션을 포함한 확장 버전
struct SongActionMenu: View {
    let song: Song
    let onAddToPlaylist: () -> Void
    let onAddToLibrary: () -> Void
    
    var body: some View {
        Menu {
            if song.appleMusicURL != nil {
                Button("Apple Music에서 열기", systemImage: "play.fill") {
                    // openURL
                }
            }
            
            Button("라이브러리에 추가", systemImage: "plus") {
                onAddToLibrary()
            }
            
            Button("플레이리스트에 추가", systemImage: "text.badge.plus") {
                onAddToPlaylist()
            }
            
            Divider()
            
            ShareLink(item: song.title) {
                Label("공유", systemImage: "square.and.arrow.up")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.title2)
        }
    }
}
