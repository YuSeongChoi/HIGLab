# AVKit AI Reference

> Video playback UI implementation guide. Read this document to generate AVKit code.

## Overview

AVKit provides the standard video player UI for Apple platforms.
Built on top of AVFoundation, it automatically supports playback controls, Picture in Picture, AirPlay, and more.

## Required Imports

```swift
import AVKit
import AVFoundation  // When detailed control is needed
```

## Project Setup

```xml
<!-- Info.plist -->
<!-- Background audio playback -->
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

## Core Components

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

### 3. AVPlayer State Management

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
        // Playback state
        player.publisher(for: \.timeControlStatus)
            .sink { [weak self] status in
                self?.isPlaying = status == .playing
            }
            .store(in: &cancellables)
        
        // Time updates
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
        }
    }
}
```

## Complete Working Example

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
        // Clean up existing player
        cleanup()
        
        isLoading = true
        error = nil
        
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Status observation
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
        
        // Time observation
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
        }
        
        // Playback completion notification
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
            // Video
            if let player = viewModel.player {
                VideoPlayer(player: player)
                    .onTapGesture {
                        withAnimation { showControls.toggle() }
                    }
            }
            
            // Loading
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            }
            
            // Error
            if let error = viewModel.error {
                ContentUnavailableView(
                    "Playback Error",
                    systemImage: "exclamationmark.triangle",
                    description: Text(error)
                )
            }
            
            // Controls
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
            
            // Playback controls
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
            
            // Progress bar
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
            .navigationTitle("Videos")
        }
    }
}

#Preview {
    VideoListView()
}
```

## Advanced Patterns

### 1. Picture in Picture

```swift
import AVKit

class PiPVideoViewController: AVPlayerViewController, AVPlayerViewControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        allowsPictureInPicturePlayback = true
    }
    
    // PiP started
    func playerViewControllerWillStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
        print("PiP started")
    }
    
    // PiP stopped
    func playerViewControllerDidStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
        print("PiP stopped")
    }
    
    // Restore from PiP
    func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        // Restore UI
        completionHandler(true)
    }
}
```

### 2. Audio Session Setup

```swift
import AVFoundation

func configureAudioSession() {
    do {
        let session = AVAudioSession.sharedInstance()
        
        // Allow background playback
        try session.setCategory(.playback, mode: .moviePlayback)
        try session.setActive(true)
    } catch {
        print("Audio session setup failed: \(error)")
    }
}
```

### 3. Custom Overlay

```swift
import SwiftUI
import AVKit

struct VideoPlayerWithOverlay: View {
    let player: AVPlayer
    @State private var showOverlay = false
    
    var body: some View {
        VideoPlayer(player: player) {
            // Custom overlay
            VStack {
                HStack {
                    Spacer()
                    Button("Subtitles") {
                        // Toggle subtitles
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

### 4. AirPlay Support

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

// Usage
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

### 5. HLS Streaming

```swift
// Play HLS stream
let hlsURL = URL(string: "https://example.com/stream.m3u8")!
let player = AVPlayer(url: hlsURL)

// Select subtitle track
func selectSubtitleTrack(player: AVPlayer, languageCode: String) {
    guard let group = player.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else { return }
    
    let option = group.options.first { option in
        option.locale?.languageCode == languageCode
    }
    
    player.currentItem?.select(option, in: group)
}

// Quality selection (bitrate limit)
func limitBitrate(player: AVPlayer, maxBitrate: Double) {
    player.currentItem?.preferredPeakBitRate = maxBitrate
}
```

## Important Notes

1. **Memory Management**
   ```swift
   // Clean up in onDisappear
   .onDisappear {
       player.pause()
       player.replaceCurrentItem(with: nil)
   }
   ```

2. **Background Playback**
   - `audio` background mode required in Info.plist
   - Audio session `.playback` category setup required

3. **AirPlay**
   - Enabled by default
   - To disable: `allowsExternalPlayback = false`

4. **Local vs Streaming**
   ```swift
   // Local file
   let url = Bundle.main.url(forResource: "video", withExtension: "mp4")!
   
   // Streaming
   let url = URL(string: "https://...")!
   ```

5. **Simulator Limitations**
   - Picture in Picture not supported
   - AirPlay not supported
   - Real device testing recommended
