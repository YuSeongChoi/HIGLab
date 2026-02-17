import Foundation
import GroupActivities

// MARK: - 참여자 모델
// SharePlay 세션의 참여자 정보

/// SharePlay 세션 참여자를 나타내는 구조체
struct WatchPartyParticipant: Identifiable, Hashable {
    /// GroupActivities에서 제공하는 참여자 ID
    let id: UUID
    
    /// 표시 이름
    let displayName: String
    
    /// 프로필 이미지 이름 (또는 시스템 이미지)
    let avatarName: String
    
    /// 참여자 역할
    let role: ParticipantRole
    
    /// 현재 상태
    var status: ParticipantStatus
    
    /// 참여 시작 시간
    let joinedAt: Date
    
    /// 마지막 활동 시간
    var lastActiveAt: Date
    
    /// 기본 생성자
    init(
        id: UUID = UUID(),
        displayName: String,
        avatarName: String = "person.circle.fill",
        role: ParticipantRole = .viewer,
        status: ParticipantStatus = .active,
        joinedAt: Date = Date(),
        lastActiveAt: Date = Date()
    ) {
        self.id = id
        self.displayName = displayName
        self.avatarName = avatarName
        self.role = role
        self.status = status
        self.joinedAt = joinedAt
        self.lastActiveAt = lastActiveAt
    }
    
    /// GroupActivities.Participant에서 생성
    init(from groupParticipant: Participant) {
        self.id = groupParticipant.id
        self.displayName = "참여자 \(groupParticipant.id.uuidString.prefix(4))"
        self.avatarName = Self.randomAvatar()
        self.role = .viewer
        self.status = .active
        self.joinedAt = Date()
        self.lastActiveAt = Date()
    }
    
    /// 랜덤 아바타 선택
    private static func randomAvatar() -> String {
        let avatars = [
            "person.circle.fill",
            "person.crop.circle.fill",
            "face.smiling.fill",
            "star.circle.fill",
            "heart.circle.fill"
        ]
        return avatars.randomElement() ?? "person.circle.fill"
    }
}

// MARK: - 참여자 역할
/// 세션 내 참여자의 역할
enum ParticipantRole: String, Codable, Sendable {
    /// 세션 호스트 (모든 권한)
    case host
    
    /// 공동 호스트 (제한된 제어 권한)
    case coHost
    
    /// 일반 시청자
    case viewer
    
    /// 역할 표시 이름
    var displayName: String {
        switch self {
        case .host: return "호스트"
        case .coHost: return "공동 호스트"
        case .viewer: return "시청자"
        }
    }
    
    /// 역할 아이콘
    var iconName: String {
        switch self {
        case .host: return "crown.fill"
        case .coHost: return "person.badge.key.fill"
        case .viewer: return "person.fill"
        }
    }
    
    /// 재생 제어 권한 여부
    var canControlPlayback: Bool {
        switch self {
        case .host, .coHost: return true
        case .viewer: return false
        }
    }
    
    /// 참여자 관리 권한 여부
    var canManageParticipants: Bool {
        self == .host
    }
}

// MARK: - 참여자 상태
/// 참여자의 현재 상태
enum ParticipantStatus: String, Codable, Sendable {
    /// 활성 상태 (시청 중)
    case active
    
    /// 자리 비움
    case away
    
    /// 연결 끊김
    case disconnected
    
    /// 버퍼링 중
    case buffering
    
    /// 상태 표시 색상
    var colorName: String {
        switch self {
        case .active: return "green"
        case .away: return "yellow"
        case .disconnected: return "gray"
        case .buffering: return "blue"
        }
    }
    
    /// 상태 아이콘
    var iconName: String {
        switch self {
        case .active: return "checkmark.circle.fill"
        case .away: return "moon.fill"
        case .disconnected: return "wifi.slash"
        case .buffering: return "arrow.triangle.2.circlepath"
        }
    }
}

// MARK: - 참여자 활동
/// 참여자의 활동 기록
struct ParticipantActivity: Identifiable, Codable {
    let id: UUID
    let participantId: UUID
    let action: ActivityType
    let timestamp: Date
    let details: String?
    
    init(
        id: UUID = UUID(),
        participantId: UUID,
        action: ActivityType,
        details: String? = nil
    ) {
        self.id = id
        self.participantId = participantId
        self.action = action
        self.timestamp = Date()
        self.details = details
    }
}

/// 활동 타입
enum ActivityType: String, Codable {
    case joined = "참여"
    case left = "퇴장"
    case playedVideo = "재생"
    case pausedVideo = "일시정지"
    case seeked = "탐색"
    case changedVideo = "비디오 변경"
    case sentReaction = "반응"
}

// MARK: - 참여자 목록 관리
/// 참여자 목록을 관리하는 구조체
struct ParticipantList {
    private(set) var participants: [UUID: WatchPartyParticipant] = [:]
    
    /// 모든 참여자 배열
    var all: [WatchPartyParticipant] {
        Array(participants.values).sorted { $0.joinedAt < $1.joinedAt }
    }
    
    /// 활성 참여자 수
    var activeCount: Int {
        participants.values.filter { $0.status == .active }.count
    }
    
    /// 호스트
    var host: WatchPartyParticipant? {
        participants.values.first { $0.role == .host }
    }
    
    /// 참여자 추가
    mutating func add(_ participant: WatchPartyParticipant) {
        participants[participant.id] = participant
    }
    
    /// 참여자 제거
    mutating func remove(id: UUID) {
        participants.removeValue(forKey: id)
    }
    
    /// 참여자 상태 업데이트
    mutating func updateStatus(id: UUID, status: ParticipantStatus) {
        participants[id]?.status = status
        participants[id]?.lastActiveAt = Date()
    }
    
    /// 참여자 존재 여부
    func contains(id: UUID) -> Bool {
        participants[id] != nil
    }
    
    /// 특정 참여자 가져오기
    func get(id: UUID) -> WatchPartyParticipant? {
        participants[id]
    }
}
