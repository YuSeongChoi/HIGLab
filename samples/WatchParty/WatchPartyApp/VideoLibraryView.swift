import SwiftUI

// MARK: - 비디오 라이브러리 뷰
// 시청 가능한 비디오 목록을 표시하고 SharePlay 시작 기능 제공

struct VideoLibraryView: View {
    @EnvironmentObject var sharePlayManager: SharePlayManager
    @EnvironmentObject var groupStateObserver: GroupStateObserver
    
    /// 선택된 비디오
    @Binding var selectedVideo: Video?
    
    /// 플레이어 표시 여부
    @Binding var showingPlayer: Bool
    
    /// 선택된 카테고리 필터
    @State private var selectedCategory: VideoCategory?
    
    /// 검색 텍스트
    @State private var searchText = ""
    
    /// 비디오 목록
    private var videos: [Video] {
        Video.samples.filter { video in
            // 카테고리 필터
            if let category = selectedCategory, video.category != category {
                return false
            }
            // 검색 필터
            if !searchText.isEmpty {
                return video.title.localizedCaseInsensitiveContains(searchText) ||
                       video.description.localizedCaseInsensitiveContains(searchText)
            }
            return true
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                // SharePlay 상태 카드
                sharePlayStatusCard
                
                // 카테고리 필터
                categoryFilter
                
                // 비디오 그리드
                videoGrid
            }
            .padding()
        }
        .navigationTitle("WatchParty")
        .searchable(text: $searchText, prompt: "비디오 검색")
    }
    
    // MARK: - SharePlay 상태 카드
    private var sharePlayStatusCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: groupStateObserver.statusIcon)
                    .font(.largeTitle)
                    .foregroundStyle(groupStateObserver.isSharePlayAvailable ? AppTheme.gradient : LinearGradient(colors: [.gray], startPoint: .top, endPoint: .bottom))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(groupStateObserver.isSharePlayAvailable ? "SharePlay 준비됨" : "SharePlay 사용 불가")
                        .font(.headline)
                    
                    Text(groupStateObserver.statusDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            if !groupStateObserver.isSharePlayAvailable {
                Text("FaceTime 통화 중에 비디오를 선택하면 함께 시청할 수 있습니다.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(AppTheme.cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }
    
    // MARK: - 카테고리 필터
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // 전체 버튼
                CategoryButton(
                    title: "전체",
                    iconName: "square.grid.2x2",
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }
                
                // 각 카테고리 버튼
                ForEach(VideoCategory.allCases, id: \.self) { category in
                    CategoryButton(
                        title: category.rawValue,
                        iconName: category.iconName,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
        }
    }
    
    // MARK: - 비디오 그리드
    private var videoGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 16) {
            ForEach(videos) { video in
                VideoCard(video: video) {
                    selectVideo(video)
                } onSharePlay: {
                    startSharePlay(with: video)
                }
            }
        }
    }
    
    // MARK: - 액션
    
    /// 비디오 선택 (로컬 재생)
    private func selectVideo(_ video: Video) {
        selectedVideo = video
        showingPlayer = true
    }
    
    /// SharePlay 시작
    private func startSharePlay(with video: Video) {
        Task {
            await sharePlayManager.startSharePlay(with: video)
            
            // SharePlay가 시작되면 플레이어 표시
            if sharePlayManager.sessionState != .idle {
                selectedVideo = video
                showingPlayer = true
            }
        }
    }
}

// MARK: - 카테고리 버튼
struct CategoryButton: View {
    let title: String
    let iconName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: iconName)
                    .font(.caption)
                Text(title)
                    .font(.subheadline)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? AppTheme.primaryColor : AppTheme.cardBackgroundColor)
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 비디오 카드
struct VideoCard: View {
    let video: Video
    let onTap: () -> Void
    let onSharePlay: () -> Void
    
    @EnvironmentObject var groupStateObserver: GroupStateObserver
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 썸네일
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(16/9, contentMode: .fit)
                
                Image(systemName: video.category.iconName)
                    .font(.largeTitle)
                    .foregroundStyle(.white.opacity(0.8))
                
                // 재생 시간 배지
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(formatDuration(video.duration))
                            .font(.caption2)
                            .fontWeight(.medium)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.black.opacity(0.7))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
                .padding(8)
            }
            .onTapGesture(perform: onTap)
            
            // 제목
            Text(video.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(1)
            
            // 설명
            Text(video.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            
            // 액션 버튼들
            HStack(spacing: 8) {
                // 재생 버튼
                Button(action: onTap) {
                    Label("재생", systemImage: "play.fill")
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.primary)
                
                // SharePlay 버튼
                Button(action: onSharePlay) {
                    Image(systemName: "shareplay")
                        .font(.caption)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.primaryColor)
                .disabled(!groupStateObserver.isSharePlayAvailable)
            }
        }
        .padding()
        .background(AppTheme.cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }
    
    /// 시간 포맷
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = Int(seconds) % 3600 / 60
        let secs = Int(seconds) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        VideoLibraryView(
            selectedVideo: .constant(nil),
            showingPlayer: .constant(false)
        )
        .environmentObject(SharePlayManager())
        .environmentObject(GroupStateObserver())
    }
}
