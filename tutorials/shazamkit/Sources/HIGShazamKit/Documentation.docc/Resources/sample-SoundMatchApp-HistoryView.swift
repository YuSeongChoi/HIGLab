import SwiftUI

// MARK: - HistoryView
// 인식 기록을 표시하는 뷰

struct HistoryView: View {
    @Environment(MatchHistory.self) private var history
    
    var body: some View {
        Group {
            if history.songs.isEmpty {
                // MARK: - 빈 상태
                ContentUnavailableView(
                    "인식 기록이 없습니다",
                    systemImage: "clock.badge.questionmark",
                    description: Text("음악을 인식하면 여기에 기록됩니다")
                )
            } else {
                // MARK: - 기록 목록
                List {
                    ForEach(history.groupedByDate, id: \.date) { group in
                        Section(group.date) {
                            ForEach(group.songs) { song in
                                NavigationLink {
                                    SongDetailView(song: song)
                                } label: {
                                    SongRowView(song: song)
                                }
                            }
                            .onDelete { offsets in
                                // 그룹 내 인덱스를 전체 인덱스로 변환
                                let songsToDelete = offsets.map { group.songs[$0] }
                                for song in songsToDelete {
                                    history.remove(song)
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .toolbar {
            if !history.songs.isEmpty {
                ToolbarItem(placement: .destructiveAction) {
                    Button("전체 삭제", role: .destructive) {
                        history.clear()
                    }
                }
            }
        }
    }
}

// MARK: - SongRowView
// 곡 목록 행

struct SongRowView: View {
    let song: MatchedSong
    
    var body: some View {
        HStack(spacing: 12) {
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
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // MARK: - 곡 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(song.artist)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // MARK: - 시간
            Text(timeString)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
    
    // 인식 시간 문자열
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeStyle = .short
        return formatter.string(from: song.matchedAt)
    }
    
    // 앨범 아트 플레이스홀더
    private var artworkPlaceholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(.gray.opacity(0.2))
            .overlay {
                Image(systemName: "music.note")
                    .foregroundStyle(.gray)
            }
    }
}

// MARK: - Preview

#Preview("기록 있음") {
    NavigationStack {
        HistoryView()
            .navigationTitle("인식 기록")
    }
    .environment({
        let history = MatchHistory.shared
        // 미리보기용 데이터 추가
        return history
    }())
}

#Preview("빈 상태") {
    NavigationStack {
        HistoryView()
            .navigationTitle("인식 기록")
    }
    .environment(MatchHistory.shared)
}
