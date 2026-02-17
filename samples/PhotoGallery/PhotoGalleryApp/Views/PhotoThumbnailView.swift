import SwiftUI
import Photos

// MARK: - 사진 썸네일 뷰
/// 그리드에서 사용되는 개별 사진 썸네일
/// 비동기 이미지 로딩 및 미디어 타입 배지 표시
struct PhotoThumbnailView: View {
    
    // MARK: - 프로퍼티
    
    /// 미디어 에셋
    let asset: MediaAsset
    
    /// 선택 여부
    let isSelected: Bool
    
    /// 선택 모드 여부
    let isSelectionMode: Bool
    
    // MARK: - 상태
    
    /// 로드된 썸네일 이미지
    @State private var thumbnailImage: Image?
    
    /// 로딩 실패 여부
    @State private var loadFailed = false
    
    /// 로딩 태스크
    @State private var loadTask: Task<Void, Never>?
    
    // MARK: - 뷰 바디
    
    var body: some View {
        ZStack {
            // 썸네일 이미지
            thumbnailContent
            
            // 미디어 타입 배지 (우하단)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    mediaTypeBadge
                }
            }
            
            // 선택 모드 오버레이
            if isSelectionMode {
                selectionOverlay
            }
            
            // 즐겨찾기 아이콘 (좌하단)
            if asset.isFavorite {
                VStack {
                    Spacer()
                    HStack {
                        favoriteIcon
                        Spacer()
                    }
                }
            }
        }
        .onAppear {
            loadThumbnail()
        }
        .onDisappear {
            // 뷰가 사라지면 로딩 취소
            loadTask?.cancel()
        }
    }
    
    // MARK: - 썸네일 콘텐츠
    
    /// 썸네일 이미지 또는 플레이스홀더
    @ViewBuilder
    private var thumbnailContent: some View {
        if let image = thumbnailImage {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else if loadFailed {
            // 로드 실패
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .overlay {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundStyle(.secondary)
                }
        } else {
            // 로딩 중
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .overlay {
                    ProgressView()
                }
        }
    }
    
    // MARK: - 미디어 타입 배지
    
    /// 비디오, 라이브 포토 등 미디어 타입 표시 배지
    @ViewBuilder
    private var mediaTypeBadge: some View {
        switch asset.mediaType {
        case .video:
            // 비디오 배지 (재생 시간 포함)
            HStack(spacing: 4) {
                Image(systemName: "play.fill")
                    .font(.caption2)
                
                if let duration = asset.formattedDuration {
                    Text(duration)
                        .font(.caption2)
                        .monospacedDigit()
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .padding(4)
            
        case .livePhoto:
            // 라이브 포토 배지
            Image(systemName: "livephoto")
                .font(.caption)
                .padding(6)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .padding(4)
            
        default:
            EmptyView()
        }
    }
    
    // MARK: - 선택 오버레이
    
    /// 선택 모드 시 표시되는 오버레이
    private var selectionOverlay: some View {
        ZStack {
            // 선택 시 딤 효과
            if isSelected {
                Color.black.opacity(0.3)
            }
            
            // 체크마크 (우상단)
            VStack {
                HStack {
                    Spacer()
                    selectionCheckmark
                }
                Spacer()
            }
        }
    }
    
    /// 선택 체크마크
    private var selectionCheckmark: some View {
        Circle()
            .fill(isSelected ? Color.blue : Color.white.opacity(0.8))
            .frame(width: 24, height: 24)
            .overlay {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                } else {
                    Circle()
                        .stroke(Color.gray, lineWidth: 1)
                }
            }
            .shadow(radius: 2)
            .padding(6)
    }
    
    // MARK: - 즐겨찾기 아이콘
    
    /// 즐겨찾기 하트 아이콘
    private var favoriteIcon: some View {
        Image(systemName: "heart.fill")
            .font(.caption)
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.5), radius: 2)
            .padding(4)
    }
    
    // MARK: - 썸네일 로드
    
    /// 비동기 썸네일 이미지 로드
    private func loadThumbnail() {
        // 이미 로드되었으면 스킵
        guard thumbnailImage == nil else { return }
        
        loadTask = Task {
            let image = await AssetCachingManager.shared.loadThumbnailImage(for: asset.asset)
            
            // 취소 확인
            if Task.isCancelled { return }
            
            await MainActor.run {
                if let image = image {
                    thumbnailImage = image
                } else {
                    loadFailed = true
                }
            }
        }
    }
}

// MARK: - 프리뷰
#Preview {
    // 프리뷰용 더미 뷰
    VStack {
        Text("썸네일 뷰 프리뷰")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
    .frame(width: 100, height: 100)
    .background(Color.gray.opacity(0.2))
}
