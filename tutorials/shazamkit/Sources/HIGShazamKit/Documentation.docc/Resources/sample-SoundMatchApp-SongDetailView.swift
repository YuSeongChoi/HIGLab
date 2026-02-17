import SwiftUI

// MARK: - SongDetailView
// 곡 상세 정보를 표시하는 뷰

struct SongDetailView: View {
    let song: MatchedSong
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - 앨범 아트
                AsyncImage(url: song.artworkURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure, .empty:
                        artworkPlaceholder
                    @unknown default:
                        artworkPlaceholder
                    }
                }
                .frame(width: 280, height: 280)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
                .padding(.top, 20)
                
                // MARK: - 곡 정보
                VStack(spacing: 8) {
                    Text(song.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(song.artist)
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                
                // MARK: - 장르 태그
                if !song.genres.isEmpty {
                    FlowLayout(spacing: 8) {
                        ForEach(song.genres, id: \.self) { genre in
                            GenreTag(genre: genre)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // MARK: - 상세 정보
                VStack(spacing: 16) {
                    // 인식 시간
                    DetailRow(
                        icon: "clock",
                        title: "인식 시간",
                        value: formattedDate
                    )
                    
                    // Shazam ID
                    if let shazamID = song.shazamID {
                        DetailRow(
                            icon: "shazam.logo",
                            title: "Shazam ID",
                            value: shazamID
                        )
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                
                // MARK: - 액션 버튼
                VStack(spacing: 12) {
                    // Apple Music 열기
                    if let url = song.appleMusicURL {
                        Link(destination: url) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                Text("Apple Music에서 열기")
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.pink)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                    
                    // 공유
                    ShareLink(item: shareText) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("공유하기")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.gray.opacity(0.2))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("곡 정보")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - 공유 텍스트
    private var shareText: String {
        var text = "🎵 \(song.title) - \(song.artist)"
        if let url = song.appleMusicURL {
            text += "\n\(url.absoluteString)"
        }
        return text
    }
    
    // MARK: - 포맷된 날짜
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: song.matchedAt)
    }
    
    // MARK: - 앨범 아트 플레이스홀더
    private var artworkPlaceholder: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(.gray.opacity(0.2))
            .overlay {
                Image(systemName: "music.note")
                    .font(.system(size: 80))
                    .foregroundStyle(.gray)
            }
    }
}

// MARK: - DetailRow
// 상세 정보 행

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundStyle(.secondary)
            
            Text(title)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
                .lineLimit(1)
        }
    }
}

// MARK: - GenreTag
// 장르 태그

struct GenreTag: View {
    let genre: String
    
    var body: some View {
        Text(genre)
            .font(.subheadline)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(.blue.opacity(0.1))
            .foregroundStyle(.blue)
            .clipShape(Capsule())
    }
}

// MARK: - FlowLayout
// 자동 줄바꿈 레이아웃

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        
        for (index, subview) in subviews.enumerated() {
            let point = CGPoint(
                x: bounds.minX + result.positions[index].x,
                y: bounds.minY + result.positions[index].y
            )
            subview.place(at: point, anchor: .topLeading, proposal: .unspecified)
        }
    }
    
    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxX = max(maxX, currentX - spacing)
        }
        
        return (CGSize(width: maxX, height: currentY + lineHeight), positions)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SongDetailView(song: .preview)
    }
}
