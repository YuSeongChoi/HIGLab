import SwiftUI

/// 인식된 곡 상세 정보 뷰
struct SongDetailView: View {
    let song: Song
    
    var body: some View {
        VStack(spacing: 20) {
            // 앨범 아트
            ArtworkView(song: song, size: .large)
            
            // 곡 정보
            VStack(spacing: 8) {
                Text(song.title)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                
                Text(song.artist)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                
                if let album = song.albumTitle {
                    Text(album)
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
                
                // 장르 태그
                if !song.genres.isEmpty {
                    HStack {
                        ForEach(song.genres.prefix(3), id: \.self) { genre in
                            Text(genre)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
                
                // 19금 표시
                if song.isExplicit {
                    Label("Explicit", systemImage: "e.square.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }
}
