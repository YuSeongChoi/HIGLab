import SwiftUI
import AVKit
import Photos

// MARK: - 비디오 플레이어 뷰
/// PHAsset에서 비디오를 로드하고 재생하는 뷰
/// 커스텀 컨트롤 및 풀스크린 지원
struct VideoPlayerView: View {
    
    // MARK: - 프로퍼티
    
    /// 비디오 에셋
    let asset: PHAsset
    
    // MARK: - 상태
    
    /// AVPlayer 인스턴스
    @State private var player: AVPlayer?
    
    /// 재생 중 여부
    @State private var isPlaying = false
    
    /// 현재 재생 시간 (초)
    @State private var currentTime: Double = 0
    
    /// 전체 재생 시간 (초)
    @State private var duration: Double = 0
    
    /// 컨트롤 표시 여부
    @State private var showControls = true
    
    /// 로딩 중 여부
    @State private var isLoading = true
    
    /// 로드 실패 여부
    @State private var loadFailed = false
    
    /// 컨트롤 숨기기 타이머
    @State private var hideControlsTask: Task<Void, Never>?
    
    /// 타임 옵저버 토큰
    @State private var timeObserverToken: Any?
    
    // MARK: - 뷰 바디
    
    var body: some View {
        ZStack {
            // 비디오 플레이어
            if let player = player {
                VideoPlayer(player: player)
                    .disabled(true) // 기본 제스처 비활성화 (커스텀 컨트롤 사용)
            } else if isLoading {
                loadingView
            } else if loadFailed {
                errorView
            }
            
            // 커스텀 컨트롤 오버레이
            if showControls && player != nil {
                controlsOverlay
            }
        }
        .background(Color.black)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                showControls.toggle()
            }
            scheduleHideControls()
        }
        .task {
            await loadVideo()
        }
        .onDisappear {
            cleanup()
        }
    }
    
    // MARK: - 로딩 뷰
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("비디오 로딩 중...")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
        }
    }
    
    // MARK: - 에러 뷰
    
    private var errorView: some View {
        ContentUnavailableView {
            Label("비디오 로드 실패", systemImage: "exclamationmark.triangle")
        } description: {
            Text("비디오를 불러올 수 없습니다")
        }
    }
    
    // MARK: - 컨트롤 오버레이
    
    private var controlsOverlay: some View {
        VStack {
            Spacer()
            
            // 중앙 재생/일시정지 버튼
            playPauseButton
            
            Spacer()
            
            // 하단 컨트롤 바
            bottomControlBar
        }
    }
    
    // MARK: - 재생/일시정지 버튼
    
    private var playPauseButton: some View {
        Button {
            togglePlayback()
        } label: {
            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.5), radius: 10)
        }
    }
    
    // MARK: - 하단 컨트롤 바
    
    private var bottomControlBar: some View {
        VStack(spacing: 8) {
            // 시크바
            Slider(value: $currentTime, in: 0...max(duration, 0.1)) { editing in
                if !editing {
                    seek(to: currentTime)
                }
            }
            .tint(.white)
            
            // 시간 표시
            HStack {
                // 현재 시간
                Text(formatTime(currentTime))
                    .font(.caption)
                    .monospacedDigit()
                
                Spacer()
                
                // 남은 시간
                Text("-\(formatTime(duration - currentTime))")
                    .font(.caption)
                    .monospacedDigit()
            }
            .foregroundStyle(.white.opacity(0.8))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 50)
        .background(
            LinearGradient(
                colors: [.clear, .black.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // MARK: - 비디오 로드
    
    private func loadVideo() async {
        isLoading = true
        defer { isLoading = false }
        
        // AVPlayerItem 로드
        guard let playerItem = await AssetCachingManager.shared.loadVideo(for: asset) else {
            loadFailed = true
            return
        }
        
        // AVPlayer 생성
        let newPlayer = AVPlayer(playerItem: playerItem)
        
        // 재생 시간 관찰
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserverToken = newPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak newPlayer] time in
            guard let player = newPlayer else { return }
            currentTime = time.seconds
            
            // 재생 상태 업데이트
            isPlaying = player.rate > 0
        }
        
        // 전체 길이 가져오기
        if let duration = try? await playerItem.asset.load(.duration) {
            self.duration = duration.seconds
        }
        
        // 재생 완료 알림
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { _ in
            isPlaying = false
            newPlayer.seek(to: .zero)
        }
        
        player = newPlayer
        scheduleHideControls()
    }
    
    // MARK: - 재생 제어
    
    /// 재생/일시정지 토글
    private func togglePlayback() {
        guard let player = player else { return }
        
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        
        isPlaying.toggle()
        scheduleHideControls()
    }
    
    /// 특정 시간으로 이동
    private func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    /// 컨트롤 자동 숨기기 예약
    private func scheduleHideControls() {
        hideControlsTask?.cancel()
        
        guard isPlaying else { return }
        
        hideControlsTask = Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            
            if !Task.isCancelled {
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showControls = false
                    }
                }
            }
        }
    }
    
    // MARK: - 정리
    
    private func cleanup() {
        // 타이머 정지
        hideControlsTask?.cancel()
        
        // 타임 옵저버 제거
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
        }
        
        // 플레이어 정리
        player?.pause()
        player = nil
    }
    
    // MARK: - 시간 포맷팅
    
    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite && seconds >= 0 else { return "0:00" }
        
        let totalSeconds = Int(seconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let secs = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
}

// MARK: - 비디오 썸네일 생성 유틸리티
extension VideoPlayerView {
    
    /// 비디오에서 썸네일 생성
    /// - Parameters:
    ///   - url: 비디오 URL
    ///   - time: 캡처할 시간 (초)
    /// - Returns: 썸네일 이미지
    static func generateThumbnail(from url: URL, at time: Double = 0) async -> UIImage? {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: 400, height: 400)
        
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        
        return await withCheckedContinuation { continuation in
            generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: cmTime)]) { _, cgImage, _, _, error in
                if let cgImage = cgImage {
                    continuation.resume(returning: UIImage(cgImage: cgImage))
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}

// MARK: - 프리뷰
#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack {
            Text("비디오 플레이어 프리뷰")
                .foregroundStyle(.white)
        }
    }
}
