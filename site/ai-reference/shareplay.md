# SharePlay AI Reference

> FaceTime 함께 보기 경험 구현 가이드. 이 문서를 읽고 SharePlay 코드를 생성할 수 있습니다.

## 개요

SharePlay는 FaceTime 통화 중 콘텐츠를 함께 보고 상호작용하는 기능을 제공합니다.
GroupActivities 프레임워크를 통해 앱 상태를 실시간 동기화합니다.

## 필수 Import

```swift
import GroupActivities
```

## 프로젝트 설정

1. **Capabilities**: Group Activities 추가
2. **Info.plist**:
```xml
<key>NSSupportsLiveActivities</key>
<true/>
```

## 핵심 구성요소

### 1. GroupActivity 정의

```swift
struct WatchTogetherActivity: GroupActivity {
    // 콘텐츠 정보
    let movie: Movie
    
    // 메타데이터
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = movie.title
        metadata.subtitle = "함께 보기"
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

### 2. 활동 시작

```swift
func startSharePlay(movie: Movie) async {
    let activity = WatchTogetherActivity(movie: movie)
    
    switch await activity.prepareForActivation() {
    case .activationPreferred:
        do {
            _ = try await activity.activate()
        } catch {
            print("활성화 실패: \(error)")
        }
    case .activationDisabled:
        // SharePlay 비활성화됨
        print("SharePlay가 비활성화되어 있습니다")
    case .cancelled:
        // 사용자 취소
        break
    @unknown default:
        break
    }
}
```

### 3. 세션 관리

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
            
            // 메신저 설정
            messenger = GroupSessionMessenger(session: session)
            
            // 세션 상태 관찰
            Task {
                for await state in session.$state.values {
                    if case .invalidated = state {
                        self.isSharePlayActive = false
                        self.session = nil
                    }
                }
            }
            
            // 세션 참가
            session.join()
        }
    }
}
```

## 전체 작동 예제

```swift
import SwiftUI
import GroupActivities
import AVKit

// MARK: - Activity 정의
struct MovieWatchActivity: GroupActivity {
    let movieID: String
    let movieTitle: String
    
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = movieTitle
        metadata.subtitle = "함께 영화 보기"
        metadata.type = .watchTogether
        return metadata
    }
}

// 동기화할 메시지
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
            
            // 메신저 설정
            let messenger = GroupSessionMessenger(session: session)
            self.messenger = messenger
            
            // 참가자 관찰
            let participantTask = Task {
                for await participants in session.$activeParticipants.values {
                    await MainActor.run {
                        self.participants = participants
                    }
                }
            }
            tasks.insert(participantTask)
            
            // 세션 상태 관찰
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
            
            // 메시지 수신
            let messageTask = Task {
                for await (message, _) in messenger.messages(of: PlaybackState.self) {
                    await handlePlaybackState(message)
                }
            }
            tasks.insert(messageTask)
            
            // 세션 참가
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
                print("SharePlay 활성화 실패: \(error)")
            }
        case .activationDisabled:
            print("SharePlay가 비활성화됨")
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
                print("메시지 전송 실패: \(error)")
            }
        }
    }
    
    @MainActor
    private func handlePlaybackState(_ state: PlaybackState) async {
        // ViewModel에서 재생 상태 동기화
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
            // 비디오 플레이어 (실제로는 AVPlayer 사용)
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
            
            // 컨트롤
            HStack(spacing: 20) {
                // 재생/일시정지
                Button {
                    viewModel?.togglePlayPause()
                } label: {
                    Image(systemName: viewModel?.isPlaying == true ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                }
                
                Spacer()
                
                // SharePlay 상태
                if sharePlayManager.isSharePlayActive {
                    HStack {
                        Image(systemName: "shareplay")
                        Text("\(sharePlayManager.participants.count)명 시청 중")
                    }
                    .font(.caption)
                    .foregroundStyle(.green)
                }
                
                // SharePlay 버튼
                ShareLink(
                    item: movie.url,
                    preview: SharePreview(movie.title)
                ) {
                    Image(systemName: "shareplay")
                        .font(.title2)
                }
            }
            .padding()
            
            // SharePlay 시작 버튼
            if !sharePlayManager.isSharePlayActive {
                Button {
                    Task {
                        await sharePlayManager.startSharePlay(
                            movieID: movie.id,
                            title: movie.title
                        )
                    }
                } label: {
                    Label("SharePlay 시작", systemImage: "shareplay")
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

## 고급 패턴

### 1. AVPlayer 동기화

```swift
// CoordinationManager 사용 (iOS 15+)
func configureAVPlayerSync() {
    guard let session else { return }
    
    let coordinator = AVPlaybackCoordinator()
    session.coordinator = coordinator
    
    // AVPlayer와 연결
    player.playbackCoordinator.coordinateWithSession(session)
}
```

### 2. 커스텀 데이터 동기화

```swift
// 게임 상태 동기화
struct GameState: Codable {
    let playerPositions: [String: CGPoint]
    let score: [String: Int]
    let currentTurn: String
}

// 신뢰할 수 있는 전송 (순서 보장)
try await messenger.send(gameState, to: .all, deliveryMode: .reliable)

// 빠른 전송 (실시간, 순서 미보장)
try await messenger.send(position, to: .all, deliveryMode: .unreliable)
```

### 3. 참가자별 메시지

```swift
// 특정 참가자에게만 전송
if let host = participants.first(where: { $0.isLocal == false }) {
    try await messenger.send(message, to: .only(host))
}
```

## 주의사항

1. **FaceTime 필요**
   - SharePlay는 FaceTime 통화 중에만 동작
   - 시뮬레이터에서 제한적 테스트 가능

2. **네트워크 지연**
   - 상태 동기화에 지연 발생 가능
   - UI에 버퍼링 표시 권장

3. **세션 정리**
   - 화면 이탈 시 `session.leave()` 또는 `session.end()` 호출
   - 메모리 누수 방지

4. **참가자 제한**
   - FaceTime 그룹 통화 최대 32명
   - 앱별로 적절한 제한 설정 권장
