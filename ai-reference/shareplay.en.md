# SharePlay AI Reference

> FaceTime shared experience implementation guide. You can generate SharePlay code by reading this document.

## Overview

SharePlay provides functionality to watch and interact with content together during FaceTime calls.
It synchronizes app state in real-time through the GroupActivities framework.

## Required Import

```swift
import GroupActivities
```

## Project Setup

1. **Capabilities**: Add Group Activities
2. **Info.plist**:
```xml
<key>NSSupportsLiveActivities</key>
<true/>
```

## Core Components

### 1. Define GroupActivity

```swift
struct WatchTogetherActivity: GroupActivity {
    // Content information
    let movie: Movie
    
    // Metadata
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = movie.title
        metadata.subtitle = "Watch Together"
        metadata.previewImage = movie.thumbnailImage
        metadata.type = .watchTogether
        return metadata
    }
}

struct Movie: Codable, Hashable {
    let id: String
    let title: String
    let url: URL
    var thumbnailImage: CGImage? { nil }
}
```

### 2. Start Activity

```swift
func startSharePlay(movie: Movie) async {
    let activity = WatchTogetherActivity(movie: movie)
    
    switch await activity.prepareForActivation() {
    case .activationPreferred:
        do {
            _ = try await activity.activate()
        } catch {
            print("Activation failed: \(error)")
        }
    case .activationDisabled:
        // SharePlay is disabled
        print("SharePlay is disabled")
    case .cancelled:
        // User cancelled
        break
    @unknown default:
        break
    }
}
```

### 3. Session Management

```swift
@Observable
class SharePlayManager {
    var session: GroupSession<WatchTogetherActivity>?
    var messenger: GroupSessionMessenger?
    var isSharePlayActive = false
    
    func configureSession() async {
        for await session in WatchTogetherActivity.sessions() {
            self.session = session
            self.isSharePlayActive = true
            
            // Setup messenger
            messenger = GroupSessionMessenger(session: session)
            
            // Observe session state
            Task {
                for await state in session.$state.values {
                    if case .invalidated = state {
                        self.isSharePlayActive = false
                        self.session = nil
                    }
                }
            }
            
            // Join session
            session.join()
        }
    }
}
```

## Complete Working Example

```swift
import SwiftUI
import GroupActivities
import AVKit

// MARK: - Activity Definition
struct MovieWatchActivity: GroupActivity {
    let movieID: String
    let movieTitle: String
    
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = movieTitle
        metadata.subtitle = "Watch Movie Together"
        metadata.type = .watchTogether
        return metadata
    }
}

// Message to sync
struct PlaybackState: Codable {
    let isPlaying: Bool
    let currentTime: TimeInterval
}

// MARK: - SharePlay Manager
@Observable
class MovieSharePlayManager {
    var session: GroupSession<MovieWatchActivity>?
    var messenger: GroupSessionMessenger?
    var isSharePlayActive = false
    var participants: Set<Participant> = []
    
    private var tasks = Set<Task<Void, Never>>()
    
    init() {
        Task {
            await observeSessions()
        }
    }
    
    private func observeSessions() async {
        for await session in MovieWatchActivity.sessions() {
            cleanUp()
            
            self.session = session
            
            // Setup messenger
            let messenger = GroupSessionMessenger(session: session)
            self.messenger = messenger
            
            // Observe participants
            let participantTask = Task {
                for await participants in session.$activeParticipants.values {
                    await MainActor.run {
                        self.participants = participants
                    }
                }
            }
            tasks.insert(participantTask)
            
            // Observe session state
            let stateTask = Task {
                for await state in session.$state.values {
                    await MainActor.run {
                        switch state {
                        case .joined:
                            self.isSharePlayActive = true
                        case .invalidated:
                            self.isSharePlayActive = false
                            self.cleanUp()
                        default:
                            break
                        }
                    }
                }
            }
            tasks.insert(stateTask)
            
            // Receive messages
            let messageTask = Task {
                for await (message, _) in messenger.messages(of: PlaybackState.self) {
                    await handlePlaybackState(message)
                }
            }
            tasks.insert(messageTask)
            
            // Join session
            session.join()
        }
    }
    
    func startSharePlay(movieID: String, title: String) async {
        let activity = MovieWatchActivity(movieID: movieID, movieTitle: title)
        
        switch await activity.prepareForActivation() {
        case .activationPreferred:
            do {
                _ = try await activity.activate()
            } catch {
                print("SharePlay activation failed: \(error)")
            }
        case .activationDisabled:
            print("SharePlay is disabled")
        case .cancelled:
            break
        @unknown default:
            break
        }
    }
    
    func sendPlaybackState(isPlaying: Bool, currentTime: TimeInterval) {
        guard let messenger else { return }
        
        let state = PlaybackState(isPlaying: isPlaying, currentTime: currentTime)
        
        Task {
            do {
                try await messenger.send(state)
            } catch {
                print("Failed to send message: \(error)")
            }
        }
    }
    
    @MainActor
    private func handlePlaybackState(_ state: PlaybackState) async {
        // Sync playback state in ViewModel
        NotificationCenter.default.post(
            name: .sharePlayStateReceived,
            object: state
        )
    }
    
    func endSession() {
        session?.end()
        cleanUp()
    }
    
    private func cleanUp() {
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
        session = nil
        messenger = nil
        participants = []
    }
}

extension Notification.Name {
    static let sharePlayStateReceived = Notification.Name("sharePlayStateReceived")
}

// MARK: - Video Player ViewModel
@Observable
class VideoPlayerViewModel {
    let movie: Movie
    var isPlaying = false
    var currentTime: TimeInterval = 0
    var sharePlayManager: MovieSharePlayManager
    
    init(movie: Movie, sharePlayManager: MovieSharePlayManager) {
        self.movie = movie
        self.sharePlayManager = sharePlayManager
        
        observeSharePlay()
    }
    
    private func observeSharePlay() {
        NotificationCenter.default.addObserver(
            forName: .sharePlayStateReceived,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let state = notification.object as? PlaybackState else { return }
            self?.syncPlayback(state)
        }
    }
    
    private func syncPlayback(_ state: PlaybackState) {
        isPlaying = state.isPlaying
        currentTime = state.currentTime
    }
    
    func togglePlayPause() {
        isPlaying.toggle()
        
        if sharePlayManager.isSharePlayActive {
            sharePlayManager.sendPlaybackState(isPlaying: isPlaying, currentTime: currentTime)
        }
    }
    
    func seek(to time: TimeInterval) {
        currentTime = time
        
        if sharePlayManager.isSharePlayActive {
            sharePlayManager.sendPlaybackState(isPlaying: isPlaying, currentTime: currentTime)
        }
    }
}

struct Movie: Identifiable {
    let id: String
    let title: String
    let url: URL
}

// MARK: - Views
struct MoviePlayerView: View {
    let movie: Movie
    @State private var sharePlayManager = MovieSharePlayManager()
    @State private var viewModel: VideoPlayerViewModel?
    
    var body: some View {
        VStack {
            // Video player (in reality would use AVPlayer)
            Rectangle()
                .fill(.black)
                .aspectRatio(16/9, contentMode: .fit)
                .overlay {
                    Image(systemName: viewModel?.isPlaying == true ? "pause.fill" : "play.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .onTapGesture {
                    viewModel?.togglePlayPause()
                }
            
            // Controls
            HStack(spacing: 20) {
                // Play/Pause
                Button {
                    viewModel?.togglePlayPause()
                } label: {
                    Image(systemName: viewModel?.isPlaying == true ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                }
                
                Spacer()
                
                // SharePlay status
                if sharePlayManager.isSharePlayActive {
                    HStack {
                        Image(systemName: "shareplay")
                        Text("\(sharePlayManager.participants.count) watching")
                    }
                    .font(.caption)
                    .foregroundStyle(.green)
                }
                
                // SharePlay button
                ShareLink(
                    item: movie.url,
                    preview: SharePreview(movie.title)
                ) {
                    Image(systemName: "shareplay")
                        .font(.title2)
                }
            }
            .padding()
            
            // Start SharePlay button
            if !sharePlayManager.isSharePlayActive {
                Button {
                    Task {
                        await sharePlayManager.startSharePlay(
                            movieID: movie.id,
                            title: movie.title
                        )
                    }
                } label: {
                    Label("Start SharePlay", systemImage: "shareplay")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .onAppear {
            viewModel = VideoPlayerViewModel(movie: movie, sharePlayManager: sharePlayManager)
        }
        .onDisappear {
            sharePlayManager.endSession()
        }
    }
}
```

## Advanced Patterns

### 1. AVPlayer Sync

```swift
// Use CoordinationManager (iOS 15+)
func configureAVPlayerSync() {
    guard let session else { return }
    
    let coordinator = AVPlaybackCoordinator()
    session.coordinator = coordinator
    
    // Connect to AVPlayer
    player.playbackCoordinator.coordinateWithSession(session)
}
```

### 2. Custom Data Sync

```swift
// Game state sync
struct GameState: Codable {
    let playerPositions: [String: CGPoint]
    let score: [String: Int]
    let currentTurn: String
}

// Reliable transport (order guaranteed)
try await messenger.send(gameState, to: .all, deliveryMode: .reliable)

// Fast transport (real-time, order not guaranteed)
try await messenger.send(position, to: .all, deliveryMode: .unreliable)
```

### 3. Per-Participant Messages

```swift
// Send to specific participant only
if let host = participants.first(where: { $0.isLocal == false }) {
    try await messenger.send(message, to: .only(host))
}
```

## Notes

1. **FaceTime Required**
   - SharePlay only works during FaceTime calls
   - Limited testing available on simulator

2. **Network Latency**
   - State sync may have delays
   - Show buffering indicator in UI

3. **Session Cleanup**
   - Call `session.leave()` or `session.end()` when leaving screen
   - Prevent memory leaks

4. **Participant Limit**
   - FaceTime group call max 32 participants
   - Set appropriate limit per app
