import SwiftUI
import PhotosUI

// MARK: - 메인 콘텐츠 뷰
/// PhotosPicker를 사용해 사진/비디오를 선택하고 갤러리로 표시
struct ContentView: View {
    
    // MARK: - 상태
    
    /// PhotosPicker 선택 항목
    @State private var selectedItems: [PhotosPickerItem] = []
    
    /// 로드된 미디어 아이템 목록
    @State private var mediaItems: [MediaItem] = []
    
    /// 로딩 중 상태
    @State private var isLoading = false
    
    /// 에러 메시지
    @State private var errorMessage: String?
    
    /// 에러 알림 표시 여부
    @State private var showError = false
    
    // MARK: - 뷰 바디
    
    var body: some View {
        NavigationStack {
            ZStack {
                if mediaItems.isEmpty {
                    // 빈 상태
                    emptyStateView
                } else {
                    // 갤러리 그리드
                    GalleryGridView(mediaItems: $mediaItems)
                }
                
                // 로딩 인디케이터
                if isLoading {
                    loadingOverlay
                }
            }
            .navigationTitle("포토 갤러리")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    photosPickerButton
                }
                
                if !mediaItems.isEmpty {
                    ToolbarItem(placement: .topBarLeading) {
                        clearButton
                    }
                }
            }
            .alert("오류", isPresented: $showError) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "알 수 없는 오류가 발생했습니다")
            }
        }
    }
    
    // MARK: - 서브뷰
    
    /// 빈 상태 뷰
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("사진이 없습니다", systemImage: "photo.on.rectangle.angled")
        } description: {
            Text("우측 상단의 + 버튼을 눌러\n사진과 비디오를 추가하세요")
        } actions: {
            PhotosPicker(
                selection: $selectedItems,
                maxSelectionCount: 20,
                matching: .any(of: [.images, .videos]),
                photoLibrary: .shared()
            ) {
                Text("사진 선택하기")
            }
            .buttonStyle(.borderedProminent)
        }
        .onChange(of: selectedItems) { _, newItems in
            Task {
                await loadMedia(from: newItems)
            }
        }
    }
    
    /// PhotosPicker 버튼
    private var photosPickerButton: some View {
        PhotosPicker(
            selection: $selectedItems,
            maxSelectionCount: 20,
            matching: .any(of: [.images, .videos]),
            photoLibrary: .shared()
        ) {
            Image(systemName: "plus")
        }
        .onChange(of: selectedItems) { _, newItems in
            Task {
                await loadMedia(from: newItems)
            }
        }
    }
    
    /// 전체 삭제 버튼
    private var clearButton: some View {
        Button(role: .destructive) {
            withAnimation {
                mediaItems.removeAll()
                selectedItems.removeAll()
            }
        } label: {
            Text("전체 삭제")
        }
    }
    
    /// 로딩 오버레이
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                Text("미디어 로딩 중...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(32)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }
    
    // MARK: - 미디어 로딩
    
    /// 선택된 아이템들에서 미디어 로드
    /// - Parameter items: PhotosPicker에서 선택된 아이템 배열
    private func loadMedia(from items: [PhotosPickerItem]) async {
        guard !items.isEmpty else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        var newMediaItems: [MediaItem] = []
        
        for item in items {
            var mediaItem = MediaItem(pickerItem: item)
            
            do {
                // 미디어 타입에 따라 로드
                switch mediaItem.mediaType {
                case .image, .livePhoto:
                    // 이미지 로드
                    let transferable = try await PhotoLoader.shared.loadImage(from: item)
                    mediaItem.image = transferable.image
                    mediaItem.loadingState = .loaded
                    
                    // 캐시에 저장
                    ImageCache.shared.cacheUIImage(transferable.uiImage, forKey: mediaItem.cacheKey)
                    
                case .video:
                    // 비디오 URL 로드
                    let url = try await PhotoLoader.shared.loadVideo(from: item)
                    mediaItem.videoURL = url
                    mediaItem.loadingState = .loaded
                    
                    // 비디오 썸네일 생성 (첫 프레임)
                    if let thumbnail = await generateVideoThumbnail(from: url) {
                        mediaItem.image = Image(uiImage: thumbnail)
                        ImageCache.shared.cacheUIImage(thumbnail, forKey: mediaItem.thumbnailCacheKey)
                    }
                    
                case .unknown:
                    mediaItem.loadingState = .failed(PhotoLoaderError.unsupportedType)
                }
                
                newMediaItems.append(mediaItem)
                
            } catch {
                mediaItem.loadingState = .failed(error)
                newMediaItems.append(mediaItem)
                
                // 에러 로깅
                print("미디어 로드 실패: \(error.localizedDescription)")
            }
        }
        
        // UI 업데이트
        await MainActor.run {
            withAnimation {
                mediaItems.append(contentsOf: newMediaItems)
            }
            // 선택 초기화
            selectedItems.removeAll()
        }
    }
    
    /// 비디오에서 썸네일 이미지 생성
    /// - Parameter url: 비디오 파일 URL
    /// - Returns: 썸네일 이미지
    private func generateVideoThumbnail(from url: URL) async -> UIImage? {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let asset = AVAsset(url: url)
                let generator = AVAssetImageGenerator(asset: asset)
                generator.appliesPreferredTrackTransform = true
                generator.maximumSize = CGSize(width: 400, height: 400)
                
                let time = CMTime(seconds: 0, preferredTimescale: 600)
                
                do {
                    let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
                    let thumbnail = UIImage(cgImage: cgImage)
                    continuation.resume(returning: thumbnail)
                } catch {
                    print("썸네일 생성 실패: \(error.localizedDescription)")
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}

// MARK: - AVFoundation Import
import AVFoundation

// MARK: - 프리뷰
#Preview {
    ContentView()
}
