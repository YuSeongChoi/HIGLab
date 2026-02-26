# AVKit AI Reference

> 비디오 재생 UI 구현 가이드. 이 문서를 읽고 AVKit 코드를 생성할 수 있습니다.

## 개요

AVKit은 Apple 플랫폼의 표준 비디오 플레이어 UI를 제공합니다.
AVFoundation 위에 구축되어 재생 컨트롤, Picture in Picture, AirPlay 등을 자동 지원합니다.

## 필수 Import

```swift
import AVKit
import AVFoundation  // 세부 제어 필요 시
```

## 프로젝트 설정

```xml
<!-- Info.plist -->
<!-- 백그라운드 오디오 재생 -->
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>

<!-- Picture in Picture (iPad) -->
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
    <string>picture-in-picture</string>
</array>
```

## 핵심 구성요소

### 1. VideoPlayer (SwiftUI)

```swift
import SwiftUI
import AVKit

struct SimpleVideoPlayer: View {
    let player = AVPlayer(url: URL(string: "https://example.com/video.mp4")!)
    
    var body: some View {
        VideoPlayer(player: player)
            .frame(height: 300)
            .onAppear { player.play() }
            .onDisappear { player.pause() }
    }
}
```

### 2. AVPlayerViewController (UIKit)

```swift
import AVKit

class VideoViewController: UIViewController {
    func playVideo() {
        let url = URL(string: "https://example.com/video.mp4")!
        let player = AVPlayer(url: url)
        
        let playerVC = AVPlayerViewController()
        playerVC.player = player
        
        present(playerVC, animated: true) {
            player.play()
        }
    }
}
```

### 3. AVPlayer 상태 관리

```swift
@Observable
class VideoPlayerManager {
    let player: AVPlayer
    var isPlaying = false
    var currentTime: Double = 0
    var duration: Double = 0
    
    private var timeObserver: Any?
    
    init(url: URL) {
        player = AVPlayer(url: url)
        setupObservers()
    }
    
    private func setupObservers() {
        // 재생 상태
        player.publisher(for: \.timeControlStatus)
            .sink { [weak self] status in
                self?.isPlaying = status == .playing
            }
            .store(in: &cancellables)
        
        // 시간 업데이트
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
        }
    }
}
```

## 전체 작동 예제

```swift
import SwiftUI
import AVKit

// MARK: - Video Model
struct Video: Identifiable {
    let id = UUID()
    let title: String
    let url: URL
    let thumbnail: String
}

// MARK: - Video Player Manager
@Observable
class VideoPlayerViewModel {
    var player: AVPlayer?
    var isPlaying = false
    var currentTime: Double = 0
    var duration: Double = 0
    var isLoading = true
    var error: String?
    
    private var timeObserver: Any?
    private var statusObserver: NSKeyValueObservation?
    
    func loadVideo(url: URL) {
        // 기존 플레이어 정리
        cleanup()
        
        isLoading = true
        error = nil
        
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // 상태 관찰
        statusObserver = playerItem.observe(\.status) { [weak self] item, _ in
            DispatchQueue.main.async {
                switch item.status {
                case .readyToPlay:
                    self?.isLoading = false
                    self?.duration = item.duration.seconds
                case .failed:
                    self?.isLoading = false
                    self?.error = item.error?.localizedDescription
                default:
                    break
                }
            }
        }
        
        // 시간 관찰
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
        }
        
        // 재생 완료 알림
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinish),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
    }
    
    func play() {
        player?.play()
        isPlaying = true
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: cmTime)
    }
    
    func skipForward(_ seconds: Double = 10) {
        let newTime = min(currentTime + seconds, duration)
        seek(to: newTime)
    }
    
    func skipBackward(_ seconds: Double = 10) {
        let newTime = max(currentTime - seconds, 0)
        seek(to: newTime)
    }
    
    @objc private func playerDidFinish() {
        isPlaying = false
        seek(to: 0)
    }
    
    func cleanup() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        statusObserver?.invalidate()
        NotificationCenter.default.removeObserver(self)
        player = nil
    }
    
    deinit {
        cleanup()
    }
}

// MARK: - Custom Video Player View
struct CustomVideoPlayer: View {
    @State private var viewModel = VideoPlayerViewModel()
    @State private var showControls = true
    let video: Video
    
    var body: some View {
        ZStack {
            // 비디오
            if let player = viewModel.player {
                VideoPlayer(player: player)
                    .onTapGesture {
                        withAnimation { showControls.toggle() }
                    }
            }
            
            // 로딩
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            }
            
            // 에러
            if let error = viewModel.error {
                ContentUnavailableView(
                    "재생 오류",
                    systemImage: "exclamationmark.triangle",
                    description: Text(error)
                )
            }
            
            // 컨트롤
            if showControls && !viewModel.isLoading && viewModel.error == nil {
                VideoControlsOverlay(viewModel: viewModel)
            }
        }
        .background(.black)
        .onAppear {
            viewModel.loadVideo(url: video.url)
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }
}

// MARK: - Controls Overlay
struct VideoControlsOverlay: View {
    @Bindable var viewModel: VideoPlayerViewModel
    
    var body: some View {
        VStack {
            Spacer()
            
            // 재생 컨트롤
            HStack(spacing: 48) {
                Button {
                    viewModel.skipBackward()
                } label: {
                    Image(systemName: "gobackward.10")
                        .font(.title)
                }
                
                Button {
                    viewModel.isPlaying ? viewModel.pause() : viewModel.play()
                } label: {
                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                        .font(.largeTitle)
                }
                
                Button {
                    viewModel.skipForward()
                } label: {
                    Image(systemName: "goforward.10")
                        .font(.title)
                }
            }
            .foregroundStyle(.white)
            
            Spacer()
            
            // 프로그레스 바
            VStack(spacing: 8) {
                Slider(
                    value: $viewModel.currentTime,
                    in: 0...max(viewModel.duration, 1)
                ) { editing in
                    if !editing {
                        viewModel.seek(to: viewModel.currentTime)
                    }
                }
                .tint(.white)
                
                HStack {
                    Text(formatTime(viewModel.currentTime))
                    Spacer()
                    Text(formatTime(viewModel.duration))
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))
            }
            .padding()
        }
        .background(
            LinearGradient(
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite else { return "--:--" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: - Video List View
struct VideoListView: View {
    let videos = [
        Video(title: "Big Buck Bunny", url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, thumbnail: "hare"),
        Video(title: "Elephant Dream", url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, thumbnail: "elephant"),
        Video(title: "Sintel", url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4")!, thumbnail: "figure.wave")
    ]
    
    var body: some View {
        NavigationStack {
            List(videos) { video in
                NavigationLink {
                    CustomVideoPlayer(video: video)
                        .navigationBarTitleDisplayMode(.inline)
                } label: {
                    HStack {
                        Image(systemName: video.thumbnail)
                            .font(.largeTitle)
                            .frame(width: 60, height: 60)
                            .background(.quaternary)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        Text(video.title)
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("비디오")
        }
    }
}

#Preview {
    VideoListView()
}
```

## 고급 패턴

### 1. Picture in Picture

```swift
import AVKit

class PiPVideoViewController: AVPlayerViewController, AVPlayerViewControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        allowsPictureInPicturePlayback = true
    }
    
    // PiP 시작
    func playerViewControllerWillStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
        print("PiP 시작")
    }
    
    // PiP 종료
    func playerViewControllerDidStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
        print("PiP 종료")
    }
    
    // PiP에서 복원
    func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        // UI 복원
        completionHandler(true)
    }
}
```

### 2. 오디오 세션 설정

```swift
import AVFoundation

func configureAudioSession() {
    do {
        let session = AVAudioSession.sharedInstance()
        
        // 백그라운드 재생 허용
        try session.setCategory(.playback, mode: .moviePlayback)
        try session.setActive(true)
    } catch {
        print("오디오 세션 설정 실패: \(error)")
    }
}
```

### 3. 커스텀 오버레이

```swift
import SwiftUI
import AVKit

struct VideoPlayerWithOverlay: View {
    let player: AVPlayer
    @State private var showOverlay = false
    
    var body: some View {
        VideoPlayer(player: player) {
            // 커스텀 오버레이
            VStack {
                HStack {
                    Spacer()
                    Button("자막") {
                        // 자막 토글
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                }
                Spacer()
            }
            .padding()
        }
    }
}
```

### 4. AirPlay 지원

```swift
import AVKit
import MediaPlayer

struct AirPlayButton: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let picker = AVRoutePickerView()
        picker.activeTintColor = .systemBlue
        picker.tintColor = .gray
        return picker
    }
    
    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {}
}

// 사용
struct VideoPlayerWithAirPlay: View {
    var body: some View {
        VStack {
            VideoPlayer(player: player)
            
            HStack {
                AirPlayButton()
                    .frame(width: 44, height: 44)
            }
        }
    }
}
```

### 5. HLS 스트리밍

```swift
// HLS 스트림 재생
let hlsURL = URL(string: "https://example.com/stream.m3u8")!
let player = AVPlayer(url: hlsURL)

// 자막 트랙 선택
func selectSubtitleTrack(player: AVPlayer, languageCode: String) {
    guard let group = player.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else { return }
    
    let option = group.options.first { option in
        option.locale?.languageCode == languageCode
    }
    
    player.currentItem?.select(option, in: group)
}

// 화질 선택 (비트레이트 제한)
func limitBitrate(player: AVPlayer, maxBitrate: Double) {
    player.currentItem?.preferredPeakBitRate = maxBitrate
}
```

## 주의사항

1. **메모리 관리**
   ```swift
   // onDisappear에서 정리
   .onDisappear {
       player.pause()
       player.replaceCurrentItem(with: nil)
   }
   ```

2. **백그라운드 재생**
   - Info.plist에 `audio` background mode 필수
   - 오디오 세션 `.playback` 카테고리 설정

3. **AirPlay**
   - 기본적으로 활성화됨
   - 비활성화: `allowsExternalPlayback = false`

4. **로컬 vs 스트리밍**
   ```swift
   // 로컬 파일
   let url = Bundle.main.url(forResource: "video", withExtension: "mp4")!
   
   // 스트리밍
   let url = URL(string: "https://...")!
   ```

5. **시뮬레이터 제한**
   - Picture in Picture 미지원
   - AirPlay 미지원
   - 실기기 테스트 권장
