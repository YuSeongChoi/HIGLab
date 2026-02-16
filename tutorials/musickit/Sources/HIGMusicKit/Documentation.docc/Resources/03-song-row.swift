import SwiftUI
import MusicKit

struct SongRow: View {
    let song: Song
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // 앨범 아트워크
                SongArtworkView(song: song, size: 50)
                
                // 곡 정보
                VStack(alignment: .leading, spacing: 4) {
                    Text(song.title)
                        .font(.body)
                        .lineLimit(1)
                    
                    Text(song.artistName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // 재생 시간
                if let duration = song.duration {
                    Text(duration.formattedDuration)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                
                // 메뉴 버튼
                Menu {
                    Button {
                        // 다음에 재생
                    } label: {
                        Label("다음에 재생", systemImage: "text.line.first.and.arrowtriangle.forward")
                    }
                    
                    Button {
                        // 라이브러리에 추가
                    } label: {
                        Label("라이브러리에 추가", systemImage: "plus")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .frame(width: 30, height: 30)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// 간단한 SongArtworkView (이전에 정의)
struct SongArtworkView: View {
    let song: Song
    let size: CGFloat
    
    var body: some View {
        if let artwork = song.artwork {
            AsyncImage(url: artwork.url(width: Int(size), height: Int(size))) { image in
                image.resizable()
            } placeholder: {
                Color.secondary.opacity(0.2)
            }
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: 6))
        } else {
            RoundedRectangle(cornerRadius: 6)
                .fill(.secondary.opacity(0.2))
                .frame(width: size, height: size)
        }
    }
}

extension TimeInterval {
    var formattedDuration: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
}
