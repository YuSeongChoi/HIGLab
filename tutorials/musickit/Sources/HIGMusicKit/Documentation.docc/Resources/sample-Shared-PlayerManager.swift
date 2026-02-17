import Foundation
import MusicKit
import Combine

// MARK: - Player Manager
// ApplicationMusicPlayer 제어 매니저

@MainActor
class PlayerManager: ObservableObject {
    static let shared = PlayerManager()
    
    // MARK: - Published Properties
    
    @Published var currentSong: SongItem?
    @Published var isPlaying: Bool = false
    @Published var playbackTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var volume: Float = 0.5
    
    // 재생 상태
    @Published var playbackState: MusicPlayer.PlaybackStatus = .stopped
    @Published var shuffleMode: MusicPlayer.ShuffleMode = .off
    @Published var repeatMode: MusicPlayer.RepeatMode = .none
    
    // MARK: - Private Properties
    
    private let player = ApplicationMusicPlayer.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    
    private init() {
        setupObservers()
    }
    
    // MARK: - Setup
    
    private func setupObservers() {
        // 재생 상태 관찰
        player.state.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updatePlaybackState()
            }
            .store(in: &cancellables)
        
        // 현재 곡 관찰
        player.queue.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateCurrentEntry()
            }
            .store(in: &cancellables)
    }
    
    private func updatePlaybackState() {
        playbackState = player.state.playbackStatus
        isPlaying = playbackState == .playing
    }
    
    private func updateCurrentEntry() {
        if let currentEntry = player.queue.currentEntry {
            // MusicPlayer.Queue.Entry에서 곡 정보 추출
            Task {
                await fetchCurrentSongInfo()
            }
        } else {
            currentSong = nil
            duration = 0
        }
    }
    
    private func fetchCurrentSongInfo() async {
        // 현재 재생 중인 항목의 상세 정보 가져오기
        guard let entry = player.queue.currentEntry,
              case .song(let song) = entry.item else {
            return
        }
        
        currentSong = SongItem(from: song)
        duration = song.duration ?? 0
    }
    
    // MARK: - Playback Controls
    // 재생 제어
    
    /// 곡 재생
    func play(song: Song) async throws {
        player.queue = [song]
        try await player.play()
    }
    
    /// SongItem으로 재생 (ID로 곡 조회 후 재생)
    func play(songItem: SongItem) async throws {
        // MusicKit에서 실제 Song 객체 조회
        var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: songItem.id)
        let response = try await request.response()
        
        guard let song = response.items.first else {
            throw PlayerError.songNotFound
        }
        
        try await play(song: song)
    }
    
    /// 여러 곡 재생 (첫 번째 곡부터 시작)
    func play(songs: [Song], startingAt index: Int = 0) async throws {
        player.queue = ApplicationMusicPlayer.Queue(for: songs, startingAt: songs[index])
        try await player.play()
    }
    
    /// 재생/일시정지 토글
    func togglePlayPause() async throws {
        if isPlaying {
            player.pause()
        } else {
            try await player.play()
        }
    }
    
    /// 일시정지
    func pause() {
        player.pause()
    }
    
    /// 정지
    func stop() {
        player.stop()
    }
    
    /// 다음 곡
    func skipToNext() async throws {
        try await player.skipToNextEntry()
    }
    
    /// 이전 곡
    func skipToPrevious() async throws {
        try await player.skipToPreviousEntry()
    }
    
    /// 특정 위치로 이동
    func seek(to time: TimeInterval) {
        player.playbackTime = time
    }
    
    // MARK: - Queue Management
    // 재생 대기열 관리
    
    /// 대기열에 곡 추가
    func addToQueue(song: Song) async throws {
        try await player.queue.insert(song, position: .tail)
    }
    
    /// 다음에 재생
    func playNext(song: Song) async throws {
        try await player.queue.insert(song, position: .afterCurrentEntry)
    }
    
    // MARK: - Playback Options
    // 재생 옵션
    
    /// 셔플 모드 토글
    func toggleShuffle() {
        shuffleMode = shuffleMode == .off ? .songs : .off
        player.state.shuffleMode = shuffleMode
    }
    
    /// 반복 모드 변경
    func cycleRepeatMode() {
        switch repeatMode {
        case .none:
            repeatMode = .all
        case .all:
            repeatMode = .one
        case .one:
            repeatMode = .none
        @unknown default:
            repeatMode = .none
        }
        player.state.repeatMode = repeatMode
    }
    
    // MARK: - Time Formatting
    
    var currentTimeFormatted: String {
        formatTime(playbackTime)
    }
    
    var durationFormatted: String {
        formatTime(duration)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // MARK: - Progress
    
    var progress: Double {
        guard duration > 0 else { return 0 }
        return playbackTime / duration
    }
    
    func setProgress(_ progress: Double) {
        let newTime = progress * duration
        seek(to: newTime)
    }
}

// MARK: - Player Errors

enum PlayerError: LocalizedError {
    case songNotFound
    case playbackFailed
    
    var errorDescription: String? {
        switch self {
        case .songNotFound:
            return "곡을 찾을 수 없습니다."
        case .playbackFailed:
            return "재생에 실패했습니다."
        }
    }
}
