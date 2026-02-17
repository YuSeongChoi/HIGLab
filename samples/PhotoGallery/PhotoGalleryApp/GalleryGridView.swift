import SwiftUI

// MARK: - 갤러리 그리드 뷰
/// 미디어 아이템을 그리드 형태로 표시
struct GalleryGridView: View {
    
    // MARK: - 프로퍼티
    
    /// 미디어 아이템 배열 (바인딩)
    @Binding var mediaItems: [MediaItem]
    
    /// 선택된 아이템 (상세 보기용)
    @State private var selectedItem: MediaItem?
    
    /// 그리드 컬럼 정의
    private let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 150), spacing: 2)
    ]
    
    // MARK: - 뷰 바디
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(mediaItems) { item in
                    gridCell(for: item)
                        .onTapGesture {
                            selectedItem = item
                        }
                }
            }
            .padding(2)
        }
        .fullScreenCover(item: $selectedItem) { item in
            PhotoDetailView(
                mediaItem: item,
                mediaItems: mediaItems,
                onDelete: { deletedItem in
                    deleteItem(deletedItem)
                }
            )
        }
    }
    
    // MARK: - 그리드 셀
    
    /// 개별 그리드 셀 뷰
    /// - Parameter item: 미디어 아이템
    @ViewBuilder
    private func gridCell(for item: MediaItem) -> some View {
        ZStack(alignment: .bottomTrailing) {
            // 썸네일 이미지
            thumbnailView(for: item)
                .frame(minHeight: 100)
                .clipped()
            
            // 미디어 타입 배지
            mediaTypeBadge(for: item)
        }
        .aspectRatio(1, contentMode: .fill)
        .contentShape(Rectangle())
    }
    
    /// 썸네일 뷰
    /// - Parameter item: 미디어 아이템
    @ViewBuilder
    private func thumbnailView(for item: MediaItem) -> some View {
        switch item.loadingState {
        case .idle, .loading:
            // 로딩 중
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .overlay {
                    ProgressView()
                }
            
        case .loaded:
            // 로드 완료
            if let image = item.image {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                // 이미지가 없는 경우 (비디오 썸네일 생성 실패 등)
                placeholderView(for: item)
            }
            
        case .failed:
            // 로드 실패
            Rectangle()
                .fill(Color.red.opacity(0.2))
                .overlay {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                }
        }
    }
    
    /// 플레이스홀더 뷰
    /// - Parameter item: 미디어 아이템
    private func placeholderView(for item: MediaItem) -> some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .overlay {
                Image(systemName: item.mediaType == .video ? "video" : "photo")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
    }
    
    /// 미디어 타입 배지
    /// - Parameter item: 미디어 아이템
    @ViewBuilder
    private func mediaTypeBadge(for item: MediaItem) -> some View {
        switch item.mediaType {
        case .video:
            // 비디오 배지
            HStack(spacing: 4) {
                Image(systemName: "play.fill")
                    .font(.caption2)
                
                if let duration = videoDuration(for: item) {
                    Text(duration)
                        .font(.caption2)
                        .monospacedDigit()
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(.black.opacity(0.6))
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .padding(4)
            
        case .livePhoto:
            // 라이브 포토 배지
            Image(systemName: "livephoto")
                .font(.caption)
                .padding(6)
                .background(.black.opacity(0.6))
                .foregroundStyle(.white)
                .clipShape(Circle())
                .padding(4)
            
        default:
            EmptyView()
        }
    }
    
    // MARK: - 헬퍼 메서드
    
    /// 비디오 길이 포맷팅
    /// - Parameter item: 미디어 아이템
    /// - Returns: 포맷된 시간 문자열
    private func videoDuration(for item: MediaItem) -> String? {
        // TODO: 실제 비디오 길이 가져오기
        // 현재는 플레이스홀더 반환
        nil
    }
    
    /// 아이템 삭제
    /// - Parameter item: 삭제할 아이템
    private func deleteItem(_ item: MediaItem) {
        withAnimation {
            mediaItems.removeAll { $0.id == item.id }
        }
        
        // 캐시에서도 제거
        ImageCache.shared.removeImage(forKey: item.cacheKey)
        ImageCache.shared.removeImage(forKey: item.thumbnailCacheKey)
    }
}

// MARK: - 프리뷰
#Preview {
    GalleryGridView(mediaItems: .constant([]))
}
