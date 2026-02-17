import Foundation
import GroupActivities
import CoreTransferable

// MARK: - WatchParty GroupActivity
// FaceTime SharePlay를 통해 함께 비디오를 시청하기 위한 GroupActivity 정의

/// WatchParty SharePlay 활동 정의
/// GroupActivity 프로토콜을 준수하여 FaceTime에서 공유 가능
struct WatchPartyActivity: GroupActivity {
    
    // MARK: - 활동 컨텍스트
    
    /// 함께 시청할 비디오
    let video: Video
    
    // MARK: - GroupActivity 메타데이터
    
    /// 활동 메타데이터 (시스템 UI에 표시됨)
    var metadata: GroupActivityMetadata {
        var meta = GroupActivityMetadata()
        
        // 활동 타입 설정
        meta.type = .watchTogether
        
        // 제목 (FaceTime 배너에 표시)
        meta.title = video.title
        
        // 부제목
        meta.subtitle = "WatchParty에서 함께 시청"
        
        // 미리보기 이미지 (썸네일)
        meta.previewImage = loadPreviewImage()
        
        // SharePlay 버튼이 표시될지 여부
        meta.supportsContinuationOnTV = true
        
        return meta
    }
    
    /// 미리보기 이미지 로드
    private func loadPreviewImage() -> CGImage? {
        // 실제 앱에서는 비디오 썸네일 이미지를 로드
        // 여기서는 nil 반환 (기본 아이콘 사용)
        return nil
    }
}

// MARK: - 활동 준비
extension WatchPartyActivity {
    /// 활동 시작 전 유효성 검사
    func prepareForActivation() async throws {
        // 비디오 URL 유효성 확인
        guard video.url.scheme == "https" || video.url.scheme == "http" else {
            throw WatchPartyError.invalidVideoURL
        }
        
        // 추가 준비 작업 (필요시)
        // - 콘텐츠 접근 권한 확인
        // - 네트워크 상태 확인 등
    }
}

// MARK: - 활동 에러
/// WatchParty 관련 에러 정의
enum WatchPartyError: Error, LocalizedError {
    case invalidVideoURL
    case sessionNotActive
    case permissionDenied
    case networkError
    case syncFailed
    case participantLimitReached
    
    var errorDescription: String? {
        switch self {
        case .invalidVideoURL:
            return "비디오 URL이 유효하지 않습니다."
        case .sessionNotActive:
            return "SharePlay 세션이 활성화되지 않았습니다."
        case .permissionDenied:
            return "권한이 거부되었습니다."
        case .networkError:
            return "네트워크 오류가 발생했습니다."
        case .syncFailed:
            return "동기화에 실패했습니다."
        case .participantLimitReached:
            return "최대 참여자 수에 도달했습니다."
        }
    }
}

// MARK: - 세션 상태
/// SharePlay 세션의 현재 상태
enum SharePlaySessionState: Equatable {
    /// 세션 없음 (대기 중)
    case idle
    
    /// 활동 활성화 대기 중
    case waitingForActivation
    
    /// 로컬에서만 재생 (SharePlay 없이)
    case localOnly
    
    /// SharePlay 세션 활성화됨
    case active(participantCount: Int)
    
    /// 세션 종료 중
    case ending
    
    /// 세션 활성화 여부
    var isActive: Bool {
        if case .active = self {
            return true
        }
        return false
    }
    
    /// 상태 설명
    var description: String {
        switch self {
        case .idle:
            return "대기 중"
        case .waitingForActivation:
            return "활성화 대기 중..."
        case .localOnly:
            return "로컬 재생"
        case .active(let count):
            return "\(count)명과 시청 중"
        case .ending:
            return "세션 종료 중..."
        }
    }
}

// MARK: - 그룹 세션 메시지
/// SharePlay 세션에서 전송되는 메시지 타입들

/// 재생 제어 메시지
struct PlaybackControlMessage: Codable, Sendable {
    let action: PlaybackAction
    let timestamp: Date
    let senderId: String
    
    init(action: PlaybackAction, senderId: String) {
        self.action = action
        self.timestamp = Date()
        self.senderId = senderId
    }
}

/// 재생 동작
enum PlaybackAction: Codable, Sendable {
    case play
    case pause
    case seek(time: TimeInterval)
    case setRate(rate: Float)
}

/// 반응 메시지 (이모지 등)
struct ReactionMessage: Codable, Sendable {
    let emoji: String
    let senderId: String
    let timestamp: Date
    
    init(emoji: String, senderId: String) {
        self.emoji = emoji
        self.senderId = senderId
        self.timestamp = Date()
    }
}

/// 채팅 메시지
struct ChatMessage: Codable, Sendable, Identifiable {
    let id: UUID
    let text: String
    let senderId: String
    let senderName: String
    let timestamp: Date
    
    init(text: String, senderId: String, senderName: String) {
        self.id = UUID()
        self.text = text
        self.senderId = senderId
        self.senderName = senderName
        self.timestamp = Date()
    }
}

// MARK: - 세션 설정
/// SharePlay 세션 설정
struct SessionConfiguration: Codable {
    /// 모든 참여자가 재생 제어 가능 여부
    var everyoneCanControl: Bool = true
    
    /// 자동 동기화 활성화
    var autoSync: Bool = true
    
    /// 동기화 허용 오차 (초)
    var syncTolerance: TimeInterval = 0.5
    
    /// 반응 표시 활성화
    var showReactions: Bool = true
    
    /// 채팅 활성화
    var chatEnabled: Bool = true
    
    /// 최대 참여자 수
    var maxParticipants: Int = 32
    
    /// 기본 설정
    static let `default` = SessionConfiguration()
}
