import Foundation

// MARK: - 재생 상태 모델
// SharePlay 세션에서 동기화되는 재생 상태 정보

/// 비디오 재생 상태를 나타내는 구조체
/// 모든 참여자 간에 동기화됨
struct PlaybackState: Codable, Hashable, Sendable {
    /// 현재 재생 중인 비디오
    let video: Video?
    
    /// 재생/일시정지 상태
    let isPlaying: Bool
    
    /// 현재 재생 위치 (초 단위)
    let currentTime: TimeInterval
    
    /// 재생 속도 (1.0 = 기본)
    let playbackRate: Float
    
    /// 상태가 마지막으로 업데이트된 시간
    let timestamp: Date
    
    /// 상태를 변경한 참여자 ID
    let changedBy: String?
    
    /// 기본 생성자
    init(
        video: Video? = nil,
        isPlaying: Bool = false,
        currentTime: TimeInterval = 0,
        playbackRate: Float = 1.0,
        timestamp: Date = Date(),
        changedBy: String? = nil
    ) {
        self.video = video
        self.isPlaying = isPlaying
        self.currentTime = currentTime
        self.playbackRate = playbackRate
        self.timestamp = timestamp
        self.changedBy = changedBy
    }
    
    /// 초기 상태
    static let initial = PlaybackState()
}

// MARK: - 재생 상태 업데이트
extension PlaybackState {
    /// 비디오 변경
    func withVideo(_ video: Video, changedBy participantId: String? = nil) -> PlaybackState {
        PlaybackState(
            video: video,
            isPlaying: false,
            currentTime: 0,
            playbackRate: playbackRate,
            timestamp: Date(),
            changedBy: participantId
        )
    }
    
    /// 재생/일시정지 토글
    func togglePlayback(changedBy participantId: String? = nil) -> PlaybackState {
        PlaybackState(
            video: video,
            isPlaying: !isPlaying,
            currentTime: currentTime,
            playbackRate: playbackRate,
            timestamp: Date(),
            changedBy: participantId
        )
    }
    
    /// 재생 위치 변경 (시킹)
    func seek(to time: TimeInterval, changedBy participantId: String? = nil) -> PlaybackState {
        PlaybackState(
            video: video,
            isPlaying: isPlaying,
            currentTime: time,
            playbackRate: playbackRate,
            timestamp: Date(),
            changedBy: participantId
        )
    }
    
    /// 재생 속도 변경
    func withRate(_ rate: Float, changedBy participantId: String? = nil) -> PlaybackState {
        PlaybackState(
            video: video,
            isPlaying: isPlaying,
            currentTime: currentTime,
            playbackRate: rate,
            timestamp: Date(),
            changedBy: participantId
        )
    }
    
    /// 현재 시간 업데이트 (내부 동기화용)
    func withCurrentTime(_ time: TimeInterval) -> PlaybackState {
        PlaybackState(
            video: video,
            isPlaying: isPlaying,
            currentTime: time,
            playbackRate: playbackRate,
            timestamp: timestamp,
            changedBy: changedBy
        )
    }
}

// MARK: - 재생 명령
/// SharePlay 세션에서 전송되는 재생 제어 명령
enum PlaybackCommand: Codable, Sendable {
    /// 재생 시작
    case play
    
    /// 일시정지
    case pause
    
    /// 특정 위치로 이동
    case seek(time: TimeInterval)
    
    /// 재생 속도 변경
    case setRate(rate: Float)
    
    /// 비디오 변경
    case changeVideo(video: Video)
    
    /// 세션 종료
    case endSession
}

// MARK: - 동기화 메시지
/// 참여자 간 동기화를 위한 메시지 타입
struct SyncMessage: Codable, Sendable {
    /// 메시지 종류
    let type: SyncMessageType
    
    /// 현재 재생 상태
    let playbackState: PlaybackState
    
    /// 메시지 발송 시간
    let sentAt: Date
    
    init(type: SyncMessageType, playbackState: PlaybackState) {
        self.type = type
        self.playbackState = playbackState
        self.sentAt = Date()
    }
}

/// 동기화 메시지 타입
enum SyncMessageType: String, Codable, Sendable {
    /// 상태 요청 (새 참여자가 합류할 때)
    case requestState
    
    /// 상태 응답
    case stateResponse
    
    /// 상태 업데이트 (재생/일시정지/시킹 등)
    case stateUpdate
    
    /// 하트비트 (연결 유지)
    case heartbeat
}
