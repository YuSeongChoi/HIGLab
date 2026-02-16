import SwiftUI
import MusicKit

// Artwork 표시하기

struct SongArtworkView: View {
    let song: Song
    let size: CGFloat
    
    var body: some View {
        if let artwork = song.artwork {
            // AsyncImage로 아트워크 로드
            AsyncImage(url: artwork.url(width: Int(size), height: Int(size))) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        
                case .failure:
                    // 로드 실패 시 플레이스홀더
                    placeholderView
                    
                case .empty:
                    // 로딩 중
                    ProgressView()
                    
                @unknown default:
                    placeholderView
                }
            }
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            // 아트워크가 없을 때
            placeholderView
        }
    }
    
    private var placeholderView: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(.secondary.opacity(0.2))
            .frame(width: size, height: size)
            .overlay {
                Image(systemName: "music.note")
                    .foregroundStyle(.secondary)
            }
    }
}

// 아트워크 배경색 활용
struct ArtworkWithBackground: View {
    let artwork: Artwork
    
    var body: some View {
        ZStack {
            // 아트워크의 배경색 활용
            artwork.backgroundColor.map { Color($0) }
            
            AsyncImage(url: artwork.url(width: 300, height: 300)) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
        }
    }
}
