import Foundation
import AVFoundation
import Combine

// MARK: - 비디오 플레이어 컨트롤러
// AVPlayer를 관리하고 SharePlay 상태와 동기화

@MainActor
final class VideoPlayerController: ObservableObject {
    
    // MARK: - Published 속성
    
    /// 현재 재생 시간 (초)
    @Published private(set) var currentTime: TimeInterval = 0
    
    /// 버퍼링 진행률 (0.0 - 1.0)
    @Published private(set) var bufferProgress: Double = 0
    
    /// 버퍼링 중 여부
    @Published private(set) var isBuffering: Bool = false
    
    /// 재생 준비 완료 여부
    @Published private(set) var isReadyToPlay: Bool = false
    
    /// 에러 발생 여부
    @Published private(set) var hasError: Bool = false
    
    /// 에러 메시지
    @Published private(set) var errorMessage: String?
    
    // MARK: - Public 속성
    
    /// AVPlayer 인스턴스
    let player: AVPlayer
    
    // MARK: - Private 속성
    
    /// 시간 관찰자
    private var timeObserver: Any?
    
    /// 상태 관찰자들
    private var cancellables = Set<AnyCancellable>()
    
    /// 현재 재생 중인 아이템
    private var currentItem: AVPlayerItem?
    
    /// 동기화 중 플래그 (무한 루프 방지)
    private var isSyncing: Bool = false
    
    /// 마지막 동기화 시간
    private var lastSyncTime: Date?
    
    /// 동기화 허용 오차 (초)
    private let syncTolerance: TimeInterval = 0.5
    
    // MARK: - 초기화
    
    init() {
        player = AVPlayer()
        setupTimeObserver()
        setupNotifications()
    }
    
    deinit {
        cleanup()
    }
    
    // MARK: - 비디오 로드
    
    /// URL에서 비디오 로드
    func load(url: URL) {
        // 기존 아이템 정리
        if let item = currentItem {
            removeItemObservers(from: item)
        }
        
        // 새 아이템 생성
        let item = AVPlayerItem(url: url)
        currentItem = item
        
        // 아이템 관찰자 설정
        setupItemObservers(for: item)
        
        // 플레이어에 아이템 설정
        player.replaceCurrentItem(with: item)
        
        isReadyToPlay = false
        hasError = false
        errorMessage = nil
        
        print("[VideoPlayerController] 비디오 로드: \(url)")
    }
    
    /// 에셋에서 비디오 로드
    func load(asset: AVAsset) {
        let item = AVPlayerItem(asset: asset)
        
        if let currentItem = currentItem {
            removeItemObservers(from: currentItem)
        }
        
        currentItem = item
        setupItemObservers(for: item)
        player.replaceCurrentItem(with: item)
    }
    
    // MARK: - 재생 제어
    
    /// 재생 시작
    func play() {
        guard isReadyToPlay else {
            print("[VideoPlayerController] 아직 재생 준비 안됨")
            return
        }
        player.play()
    }
    
    /// 일시정지
    func pause() {
        player.pause()
    }
    
    /// 재생/일시정지 토글
    func togglePlayback() {
        if player.timeControlStatus == .playing {
            pause()
        } else {
            play()
        }
    }
    
    /// 특정 위치로 이동
    func seek(to time: TimeInterval, toleranceBefore: CMTime = .zero, toleranceAfter: CMTime = .zero) async {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        
        await withCheckedContinuation { continuation in
            player.seek(to: cmTime, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter) { _ in
                continuation.resume()
            }
        }
        
        currentTime = time
    }
    
    /// 재생 속도 설정
    func setRate(_ rate: Float) {
        player.rate = rate
    }
    
    // MARK: - SharePlay 동기화
    
    /// SharePlay 상태와 동기화
    func syncWithState(_ state: PlaybackState) {
        // 무한 루프 방지
        guard !isSyncing else { return }
        isSyncing = true
        defer { isSyncing = false }
        
        // 마지막 동기화 이후 충분한 시간이 지났는지 확인
        if let lastSync = lastSyncTime,
           Date().timeIntervalSince(lastSync) < 0.1 {
            return
        }
        lastSyncTime = Date()
        
        // 재생/일시정지 동기화
        if state.isPlaying {
            if player.timeControlStatus != .playing {
                play()
            }
        } else {
            if player.timeControlStatus == .playing {
                pause()
            }
        }
        
        // 재생 위치 동기화 (오차 범위 초과 시)
        let timeDiff = abs(currentTime - state.currentTime)
        if timeDiff > syncTolerance {
            Task {
                await seek(to: state.currentTime)
            }
        }
        
        // 재생 속도 동기화
        if player.rate != state.playbackRate && state.isPlaying {
            setRate(state.playbackRate)
        }
        
        print("[VideoPlayerController] 동기화 완료 - 재생: \(state.isPlaying), 시간: \(state.currentTime)")
    }
    
    // MARK: - 정리
    
    /// 리소스 정리
    func cleanup() {
        // 시간 관찰자 제거
        if let observer = timeObserver {
            player.removeTimeObserver(observer)
            timeObserver = nil
        }
        
        // 아이템 관찰자 제거
        if let item = currentItem {
            removeItemObservers(from: item)
        }
        
        // 구독 취소
        cancellables.removeAll()
        
        // 플레이어 정지
        player.pause()
        player.replaceCurrentItem(with: nil)
        
        currentItem = nil
        
        print("[VideoPlayerController] 정리 완료")
    }
    
    // MARK: - Private 메서드
    
    /// 시간 관찰자 설정
    private func setupTimeObserver() {
        // 0.5초마다 현재 시간 업데이트
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { [weak self] time in
            Task { @MainActor in
                self?.currentTime = time.seconds
            }
        }
    }
    
    /// 알림 설정
    private func setupNotifications() {
        // 재생 완료 알림
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.handlePlaybackEnded()
            }
            .store(in: &cancellables)
        
        // 재생 실패 알림
        NotificationCenter.default.publisher(for: .AVPlayerItemFailedToPlayToEndTime)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                self?.handlePlaybackError(notification)
            }
            .store(in: &cancellables)
    }
    
    /// 아이템 관찰자 설정
    private func setupItemObservers(for item: AVPlayerItem) {
        // 상태 관찰
        item.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.handleStatusChange(status)
            }
            .store(in: &cancellables)
        
        // 버퍼 상태 관찰
        item.publisher(for: \.isPlaybackBufferEmpty)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEmpty in
                self?.isBuffering = isEmpty
            }
            .store(in: &cancellables)
        
        // 버퍼 진행률 관찰
        item.publisher(for: \.loadedTimeRanges)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] ranges in
                self?.updateBufferProgress(ranges)
            }
            .store(in: &cancellables)
    }
    
    /// 아이템 관찰자 제거
    private func removeItemObservers(from item: AVPlayerItem) {
        // Combine 구독은 cancellables에서 자동 정리됨
    }
    
    /// 상태 변경 처리
    private func handleStatusChange(_ status: AVPlayerItem.Status) {
        switch status {
        case .unknown:
            isReadyToPlay = false
            print("[VideoPlayerController] 상태: 알 수 없음")
            
        case .readyToPlay:
            isReadyToPlay = true
            hasError = false
            print("[VideoPlayerController] 상태: 재생 준비 완료")
            
        case .failed:
            isReadyToPlay = false
            hasError = true
            errorMessage = currentItem?.error?.localizedDescription ?? "재생 실패"
            print("[VideoPlayerController] 상태: 실패 - \(errorMessage ?? "")")
            
        @unknown default:
            break
        }
    }
    
    /// 버퍼 진행률 업데이트
    private func updateBufferProgress(_ ranges: [NSValue]) {
        guard let range = ranges.first?.timeRangeValue,
              let duration = currentItem?.duration.seconds,
              duration > 0 else {
            bufferProgress = 0
            return
        }
        
        let bufferedTime = range.start.seconds + range.duration.seconds
        bufferProgress = min(1.0, bufferedTime / duration)
    }
    
    /// 재생 완료 처리
    private func handlePlaybackEnded() {
        print("[VideoPlayerController] 재생 완료")
        
        // 처음으로 되돌리기
        Task {
            await seek(to: 0)
        }
    }
    
    /// 재생 에러 처리
    private func handlePlaybackError(_ notification: Notification) {
        hasError = true
        
        if let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error {
            errorMessage = error.localizedDescription
        } else {
            errorMessage = "재생 중 오류가 발생했습니다."
        }
        
        print("[VideoPlayerController] 재생 에러: \(errorMessage ?? "")")
    }
}

// MARK: - AVPlayer 확장
extension AVPlayer {
    /// 현재 재생 중인지 확인
    var isPlaying: Bool {
        timeControlStatus == .playing
    }
}
