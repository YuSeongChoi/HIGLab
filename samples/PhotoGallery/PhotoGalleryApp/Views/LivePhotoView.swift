import SwiftUI
import PhotosUI

// MARK: - 라이브 포토 뷰
/// PHLivePhoto를 재생하는 SwiftUI 뷰
/// PHLivePhotoView를 UIViewRepresentable로 래핑
struct LivePhotoView: UIViewRepresentable {
    
    // MARK: - 프로퍼티
    
    /// 표시할 라이브 포토
    let livePhoto: PHLivePhoto
    
    /// 재생 스타일
    var playbackStyle: PHLivePhotoViewPlaybackStyle = .full
    
    /// 음소거 여부
    var isMuted: Bool = false
    
    /// 자동 재생 여부
    var autoPlay: Bool = true
    
    // MARK: - 코디네이터
    
    class Coordinator: NSObject, PHLivePhotoViewDelegate {
        var parent: LivePhotoView
        
        init(_ parent: LivePhotoView) {
            self.parent = parent
        }
        
        /// 재생 종료 시 호출
        func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
            // 필요 시 재생 완료 이벤트 처리
        }
        
        /// 재생 시작 시 호출
        func livePhotoView(_ livePhotoView: PHLivePhotoView, willBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
            // 필요 시 재생 시작 이벤트 처리
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - UIViewRepresentable
    
    func makeUIView(context: Context) -> PHLivePhotoView {
        let view = PHLivePhotoView()
        view.delegate = context.coordinator
        view.contentMode = .scaleAspectFit
        view.isMuted = isMuted
        view.livePhoto = livePhoto
        
        // 자동 재생
        if autoPlay {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                view.startPlayback(with: playbackStyle)
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: PHLivePhotoView, context: Context) {
        uiView.livePhoto = livePhoto
        uiView.isMuted = isMuted
    }
}

// MARK: - 라이브 포토 컨트롤 뷰
/// 재생/정지 컨트롤이 포함된 라이브 포토 뷰
struct LivePhotoControlView: View {
    
    // MARK: - 프로퍼티
    
    /// 표시할 라이브 포토
    let livePhoto: PHLivePhoto
    
    // MARK: - 상태
    
    /// 재생 중 여부
    @State private var isPlaying = false
    
    /// 음소거 여부
    @State private var isMuted = false
    
    /// 라이브 포토 뷰 참조
    @State private var livePhotoView: PHLivePhotoView?
    
    // MARK: - 뷰 바디
    
    var body: some View {
        ZStack {
            // 라이브 포토 뷰
            LivePhotoViewRepresentable(
                livePhoto: livePhoto,
                isMuted: isMuted,
                viewRef: $livePhotoView
            )
            
            // 컨트롤 오버레이
            VStack {
                Spacer()
                
                HStack(spacing: 20) {
                    // 재생/정지 버튼
                    Button {
                        togglePlayback()
                    } label: {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(.white)
                            .shadow(radius: 5)
                    }
                    
                    // 음소거 버튼
                    Button {
                        isMuted.toggle()
                    } label: {
                        Image(systemName: isMuted ? "speaker.slash.circle.fill" : "speaker.wave.2.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(.white)
                            .shadow(radius: 5)
                    }
                }
                .padding(.bottom, 50)
            }
            
            // 라이브 포토 배지
            VStack {
                HStack {
                    LivePhotoBadge()
                    Spacer()
                }
                Spacer()
            }
            .padding()
        }
    }
    
    /// 재생 토글
    private func togglePlayback() {
        if isPlaying {
            livePhotoView?.stopPlayback()
        } else {
            livePhotoView?.startPlayback(with: .full)
        }
        isPlaying.toggle()
    }
}

// MARK: - 라이브 포토 배지
/// 라이브 포토 표시 배지
struct LivePhotoBadge: View {
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "livephoto")
            Text("LIVE")
                .font(.caption.bold())
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }
}

// MARK: - 라이브 포토 뷰 (뷰 참조 포함)
/// 외부에서 PHLivePhotoView를 제어할 수 있도록 참조를 제공
struct LivePhotoViewRepresentable: UIViewRepresentable {
    
    let livePhoto: PHLivePhoto
    let isMuted: Bool
    @Binding var viewRef: PHLivePhotoView?
    
    func makeUIView(context: Context) -> PHLivePhotoView {
        let view = PHLivePhotoView()
        view.contentMode = .scaleAspectFit
        view.livePhoto = livePhoto
        view.isMuted = isMuted
        
        DispatchQueue.main.async {
            viewRef = view
        }
        
        return view
    }
    
    func updateUIView(_ uiView: PHLivePhotoView, context: Context) {
        uiView.isMuted = isMuted
    }
}

// MARK: - 라이브 포토 로더 뷰
/// 에셋에서 라이브 포토를 로드하고 표시하는 뷰
struct LivePhotoLoaderView: View {
    
    // MARK: - 프로퍼티
    
    /// 대상 에셋
    let asset: MediaAsset
    
    // MARK: - 상태
    
    /// 로드된 라이브 포토
    @State private var livePhoto: PHLivePhoto?
    
    /// 로딩 중 여부
    @State private var isLoading = true
    
    /// 로드 실패 여부
    @State private var loadFailed = false
    
    // MARK: - 뷰 바디
    
    var body: some View {
        ZStack {
            if let livePhoto = livePhoto {
                LivePhotoControlView(livePhoto: livePhoto)
            } else if isLoading {
                ProgressView("라이브 포토 로딩 중...")
            } else if loadFailed {
                ContentUnavailableView(
                    "로드 실패",
                    systemImage: "exclamationmark.triangle",
                    description: Text("라이브 포토를 불러올 수 없습니다")
                )
            }
        }
        .task {
            await loadLivePhoto()
        }
    }
    
    /// 라이브 포토 로드
    private func loadLivePhoto() async {
        isLoading = true
        defer { isLoading = false }
        
        let loaded = await AssetCachingManager.shared.loadLivePhoto(for: asset.asset)
        
        if let loaded = loaded {
            livePhoto = loaded
        } else {
            loadFailed = true
        }
    }
}

// MARK: - 프리뷰
#Preview {
    VStack {
        LivePhotoBadge()
        
        Text("라이브 포토 뷰 프리뷰")
            .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.black)
}
