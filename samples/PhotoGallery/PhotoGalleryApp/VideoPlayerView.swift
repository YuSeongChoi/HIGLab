import SwiftUI
import AVKit

// MARK: - 비디오 플레이어 뷰
/// AVPlayer를 사용한 비디오 재생 뷰
struct VideoPlayerView: View {
    
    // MARK: - 프로퍼티
    
    /// 비디오 파일 URL
    let url: URL
    
    // MARK: - 상태
    
    /// AVPlayer 인스턴스
    @State private var player: AVPlayer?
    
    /// 재생 중 여부
    @State private var isPlaying = false
    
    /// 현재 재생 시간
    @State private var currentTime: Double = 0
    
    /// 전체 재생 시간
    @State private var duration: Double = 0
    
    /// 컨트롤 표시 여부
    @State private var showControls = true
    
    /// 컨트롤 숨기기 타이머
    @State private var hideControlsTask: Task<Void, Never>?
    
    // MARK: - 뷰 바디
    
    var body: some View {
        ZStack {
            // 비디오 플레이어
            if let player = player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
            } else {
                // 로딩 중
                ProgressView()
            }
            
            // 커스텀 컨트롤 오버레이
            if showControls {
                controlsOverlay
            }
        }
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            // 재생 중지 및 정리
            player?.pause()
            player = nil
            hideControlsTask?.cancel()
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                showControls.toggle()
            }
            scheduleHideControls()
        }
    }
    
    // MARK: - 컨트롤 오버레이
    
    /// 재생 컨트롤 오버레이
    private var controlsOverlay: some View {
        VStack {
            Spacer()
            
            // 재생/일시정지 버튼
            playPauseButton
            
            Spacer()
            
            // 하단 컨트롤 바
            bottomControlBar
        }
    }
    
    /// 재생/일시정지 버튼
    private var playPauseButton: some View {
        Button {
            togglePlayback()
        } label: {
            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(.white)
                .shadow(radius: 10)
        }
    }
    
    /// 하단 컨트롤 바
    private var bottomControlBar: some View {
        VStack(spacing: 8) {
            // 시크 바
            Slider(value: $currentTime, in: 0...max(duration, 1)) { editing in
                if !editing {
                    seek(to: currentTime)
                }
            }
            .tint(.white)
            
            // 시간 표시
            HStack {
                Text(formatTime(currentTime))
                    .font(.caption)
                    .monospacedDigit()
                
                Spacer()
                
                Text(formatTime(duration))
                    .font(.caption)
                    .monospacedDigit()
            }
            .foregroundStyle(.white.opacity(0.8))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
        .background(
            LinearGradient(
                colors: [.clear, .black.opacity(0.5)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // MARK: - 플레이어 설정
    
    /// AVPlayer 초기화 및 설정
    private func setupPlayer() {
        let playerItem = AVPlayerItem(url: url)
        let newPlayer = AVPlayer(playerItem: playerItem)
        
        // 재생 상태 관찰
        newPlayer.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: .main
        ) { time in
            currentTime = time.seconds
        }
        
        // 전체 길이 가져오기
        Task {
            if let duration = try? await playerItem.asset.load(.duration) {
                await MainActor.run {
                    self.duration = duration.seconds
                }
            }
        }
        
        // 재생 완료 알림 등록
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { _ in
            isPlaying = false
            // 처음으로 되감기
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
    /// - Parameter time: 이동할 시간 (초)
    private func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    /// 컨트롤 자동 숨기기 예약
    private func scheduleHideControls() {
        hideControlsTask?.cancel()
        
        hideControlsTask = Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000) // 3초
            
            if !Task.isCancelled && isPlaying {
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showControls = false
                    }
                }
            }
        }
    }
    
    // MARK: - 헬퍼
    
    /// 시간 포맷팅
    /// - Parameter seconds: 초
    /// - Returns: "mm:ss" 형식의 문자열
    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite && seconds >= 0 else { return "0:00" }
        
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let remainingSeconds = totalSeconds % 60
        
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

// MARK: - 프리뷰
#Preview {
    VideoPlayerView(url: URL(string: "https://example.com/video.mp4")!)
}
