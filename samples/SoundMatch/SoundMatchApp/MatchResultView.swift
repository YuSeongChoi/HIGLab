import SwiftUI

// MARK: - MatchResultView
// 인식 결과를 표시하는 뷰

struct MatchResultView: View {
    let song: MatchedSong
    
    @State private var showDetail = false
    @State private var appeared = false
    
    var body: some View {
        VStack(spacing: 24) {
            // MARK: - 성공 아이콘
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.green)
                .scaleEffect(appeared ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: appeared)
            
            // MARK: - 앨범 아트
            AsyncImage(url: song.artworkURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    artworkPlaceholder
                case .empty:
                    artworkPlaceholder
                        .overlay {
                            ProgressView()
                        }
                @unknown default:
                    artworkPlaceholder
                }
            }
            .frame(width: 200, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 10)
            .scaleEffect(appeared ? 1 : 0.5)
            .opacity(appeared ? 1 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: appeared)
            
            // MARK: - 곡 정보
            VStack(spacing: 8) {
                Text(song.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(song.artist)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                
                // 장르 태그
                if !song.genres.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(song.genres.prefix(3), id: \.self) { genre in
                            Text(genre)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(.blue.opacity(0.1))
                                .foregroundStyle(.blue)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .offset(y: appeared ? 0 : 20)
            .opacity(appeared ? 1 : 0)
            .animation(.easeOut(duration: 0.5).delay(0.2), value: appeared)
            
            // MARK: - 액션 버튼
            HStack(spacing: 20) {
                // Apple Music 열기
                if let url = song.appleMusicURL {
                    Link(destination: url) {
                        Label("Apple Music", systemImage: "play.circle.fill")
                            .font(.headline)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(.pink)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }
                
                // 상세 보기
                Button {
                    showDetail = true
                } label: {
                    Label("상세", systemImage: "info.circle")
                        .font(.headline)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(.gray.opacity(0.2))
                        .foregroundStyle(.primary)
                        .clipShape(Capsule())
                }
            }
            .offset(y: appeared ? 0 : 30)
            .opacity(appeared ? 1 : 0)
            .animation(.easeOut(duration: 0.5).delay(0.3), value: appeared)
        }
        .padding()
        .onAppear {
            appeared = true
        }
        .sheet(isPresented: $showDetail) {
            SongDetailView(song: song)
        }
    }
    
    // MARK: - 앨범 아트 플레이스홀더
    private var artworkPlaceholder: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.gray.opacity(0.2))
            .overlay {
                Image(systemName: "music.note")
                    .font(.system(size: 60))
                    .foregroundStyle(.gray)
            }
    }
}

// MARK: - Preview

#Preview {
    MatchResultView(song: .preview)
}
