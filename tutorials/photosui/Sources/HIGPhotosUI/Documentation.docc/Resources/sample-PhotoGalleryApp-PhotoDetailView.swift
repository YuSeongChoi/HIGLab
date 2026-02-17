import SwiftUI

// MARK: - 사진 상세 뷰
/// 선택된 미디어를 전체 화면으로 표시
struct PhotoDetailView: View {
    
    // MARK: - 환경 변수
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - 프로퍼티
    
    /// 현재 표시 중인 미디어 아이템
    let mediaItem: MediaItem
    
    /// 전체 미디어 목록 (스와이프 네비게이션용)
    let mediaItems: [MediaItem]
    
    /// 삭제 콜백
    var onDelete: ((MediaItem) -> Void)?
    
    // MARK: - 상태
    
    /// 현재 표시 중인 아이템 인덱스
    @State private var currentIndex: Int = 0
    
    /// 확대/축소 배율
    @State private var scale: CGFloat = 1.0
    
    /// 드래그 오프셋
    @State private var offset: CGSize = .zero
    
    /// UI 표시 여부
    @State private var showUI = true
    
    /// 삭제 확인 알림 표시
    @State private var showDeleteConfirmation = false
    
    // MARK: - 뷰 바디
    
    var body: some View {
        ZStack {
            // 배경
            Color.black.ignoresSafeArea()
            
            // 미디어 페이저
            TabView(selection: $currentIndex) {
                ForEach(Array(mediaItems.enumerated()), id: \.element.id) { index, item in
                    mediaContentView(for: item)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
            
            // 오버레이 UI
            if showUI {
                overlayUI
            }
        }
        .statusBarHidden(!showUI)
        .onAppear {
            // 초기 인덱스 설정
            if let index = mediaItems.firstIndex(where: { $0.id == mediaItem.id }) {
                currentIndex = index
            }
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                showUI.toggle()
            }
        }
        .gesture(dismissGesture)
        .confirmationDialog("이 미디어를 삭제하시겠습니까?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("삭제", role: .destructive) {
                deleteCurrentItem()
            }
            Button("취소", role: .cancel) {}
        }
    }
    
    // MARK: - 미디어 콘텐츠 뷰
    
    /// 미디어 타입에 따른 콘텐츠 뷰
    /// - Parameter item: 미디어 아이템
    @ViewBuilder
    private func mediaContentView(for item: MediaItem) -> some View {
        switch item.mediaType {
        case .video:
            // 비디오 플레이어
            if let videoURL = item.videoURL {
                VideoPlayerView(url: videoURL)
            } else {
                errorPlaceholder
            }
            
        case .image, .livePhoto:
            // 이미지 뷰어 (확대/축소 지원)
            if let image = item.image {
                zoomableImage(image)
            } else {
                errorPlaceholder
            }
            
        case .unknown:
            errorPlaceholder
        }
    }
    
    /// 확대/축소 가능한 이미지 뷰
    /// - Parameter image: 표시할 이미지
    private func zoomableImage(_ image: Image) -> some View {
        image
            .resizable()
            .scaledToFit()
            .scaleEffect(scale)
            .offset(offset)
            .gesture(magnificationGesture)
            .gesture(dragGesture)
            .onTapGesture(count: 2) {
                // 더블 탭으로 확대/축소 토글
                withAnimation(.spring()) {
                    if scale > 1 {
                        scale = 1
                        offset = .zero
                    } else {
                        scale = 2
                    }
                }
            }
    }
    
    /// 에러 플레이스홀더
    private var errorPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
            Text("미디어를 표시할 수 없습니다")
                .font(.subheadline)
        }
        .foregroundStyle(.secondary)
    }
    
    // MARK: - 오버레이 UI
    
    /// 상단/하단 오버레이 UI
    private var overlayUI: some View {
        VStack {
            // 상단 바
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .padding()
                }
                
                Spacer()
                
                // 현재 위치 표시
                Text("\(currentIndex + 1) / \(mediaItems.count)")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                
                Spacer()
                
                // 삭제 버튼
                Button {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .padding()
                }
            }
            .background(
                LinearGradient(
                    colors: [.black.opacity(0.5), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            Spacer()
            
            // 하단 인포
            if let currentItem = currentMediaItem {
                HStack {
                    // 미디어 타입 아이콘
                    Image(systemName: mediaTypeIcon(for: currentItem))
                        .foregroundStyle(.white.opacity(0.8))
                    
                    Text(mediaTypeLabel(for: currentItem))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                    
                    Spacer()
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.5)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
    }
    
    // MARK: - 제스처
    
    /// 확대/축소 제스처
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = max(1, min(value, 4))
            }
            .onEnded { _ in
                withAnimation(.spring()) {
                    if scale < 1.2 {
                        scale = 1
                        offset = .zero
                    }
                }
            }
    }
    
    /// 드래그 제스처 (확대 시 패닝)
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if scale > 1 {
                    offset = value.translation
                }
            }
            .onEnded { _ in
                if scale <= 1 {
                    withAnimation(.spring()) {
                        offset = .zero
                    }
                }
            }
    }
    
    /// 닫기 제스처 (아래로 스와이프)
    private var dismissGesture: some Gesture {
        DragGesture()
            .onEnded { value in
                // 아래로 100pt 이상 스와이프하면 닫기
                if value.translation.height > 100 && scale <= 1 {
                    dismiss()
                }
            }
    }
    
    // MARK: - 헬퍼
    
    /// 현재 표시 중인 미디어 아이템
    private var currentMediaItem: MediaItem? {
        guard currentIndex >= 0 && currentIndex < mediaItems.count else { return nil }
        return mediaItems[currentIndex]
    }
    
    /// 미디어 타입 아이콘
    private func mediaTypeIcon(for item: MediaItem) -> String {
        switch item.mediaType {
        case .image: return "photo"
        case .video: return "video"
        case .livePhoto: return "livephoto"
        case .unknown: return "questionmark"
        }
    }
    
    /// 미디어 타입 라벨
    private func mediaTypeLabel(for item: MediaItem) -> String {
        switch item.mediaType {
        case .image: return "사진"
        case .video: return "비디오"
        case .livePhoto: return "라이브 포토"
        case .unknown: return "알 수 없음"
        }
    }
    
    /// 현재 아이템 삭제
    private func deleteCurrentItem() {
        guard let currentItem = currentMediaItem else { return }
        
        // 삭제 콜백 호출
        onDelete?(currentItem)
        
        // 마지막 아이템이면 닫기
        if mediaItems.count <= 1 {
            dismiss()
        }
    }
}

// MARK: - 프리뷰
#Preview {
    PhotoDetailView(
        mediaItem: MediaItem(pickerItem: PhotosPickerItem(itemIdentifier: "test")),
        mediaItems: []
    )
}
