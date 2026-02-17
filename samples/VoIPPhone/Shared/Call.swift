import Foundation

// MARK: - 통화 모델
// VoIP 통화의 상태와 정보를 관리하는 핵심 모델

/// 통화 상태 열거형
enum CallState: String, Codable {
    case idle           // 대기 상태
    case incoming       // 수신 중
    case connecting     // 연결 중
    case active         // 통화 중
    case holding        // 보류 중
    case ended          // 종료됨
    
    /// 상태에 따른 표시 텍스트
    var displayText: String {
        switch self {
        case .idle: return "대기 중"
        case .incoming: return "수신 중..."
        case .connecting: return "연결 중..."
        case .active: return "통화 중"
        case .holding: return "보류 중"
        case .ended: return "통화 종료"
        }
    }
    
    /// 상태에 따른 아이콘
    var iconName: String {
        switch self {
        case .idle: return "phone"
        case .incoming: return "phone.arrow.down.left"
        case .connecting: return "phone.connection"
        case .active: return "phone.fill"
        case .holding: return "pause.circle"
        case .ended: return "phone.down"
        }
    }
}

/// 통화 방향 열거형
enum CallDirection: String, Codable {
    case incoming   // 수신
    case outgoing   // 발신
    
    var displayText: String {
        switch self {
        case .incoming: return "수신"
        case .outgoing: return "발신"
        }
    }
    
    var iconName: String {
        switch self {
        case .incoming: return "phone.arrow.down.left"
        case .outgoing: return "phone.arrow.up.right"
        }
    }
}

/// 통화 정보 모델
struct Call: Identifiable, Codable {
    let id: UUID                    // 고유 식별자
    let remotePhoneNumber: String   // 상대방 전화번호
    let remoteName: String?         // 상대방 이름 (연락처에 있는 경우)
    let direction: CallDirection    // 통화 방향
    var state: CallState            // 현재 상태
    let startTime: Date             // 통화 시작 시간
    var connectedTime: Date?        // 연결된 시간
    var endTime: Date?              // 종료 시간
    var isMuted: Bool               // 음소거 상태
    var isSpeakerOn: Bool           // 스피커 상태
    var isOnHold: Bool              // 보류 상태
    
    /// 표시할 이름 (이름이 없으면 전화번호)
    var displayName: String {
        remoteName ?? remotePhoneNumber
    }
    
    /// 통화 시간 계산
    var duration: TimeInterval? {
        guard let connected = connectedTime else { return nil }
        let end = endTime ?? Date()
        return end.timeIntervalSince(connected)
    }
    
    /// 포맷된 통화 시간 문자열
    var formattedDuration: String {
        guard let duration = duration else { return "00:00" }
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    /// 새 통화 생성
    init(
        id: UUID = UUID(),
        remotePhoneNumber: String,
        remoteName: String? = nil,
        direction: CallDirection,
        state: CallState = .idle
    ) {
        self.id = id
        self.remotePhoneNumber = remotePhoneNumber
        self.remoteName = remoteName
        self.direction = direction
        self.state = state
        self.startTime = Date()
        self.connectedTime = nil
        self.endTime = nil
        self.isMuted = false
        self.isSpeakerOn = false
        self.isOnHold = false
    }
}

// MARK: - 통화 액션
// CallKit과 상호작용할 때 사용하는 액션 정의

/// 통화 관련 액션 열거형
enum CallAction {
    case startCall(phoneNumber: String)     // 발신 시작
    case answerCall                          // 수신 응답
    case endCall                             // 통화 종료
    case toggleMute                          // 음소거 토글
    case toggleSpeaker                       // 스피커 토글
    case toggleHold                          // 보류 토글
    case sendDTMF(digit: String)            // DTMF 톤 전송
}

// MARK: - 통화 이벤트
// 통화 상태 변경 시 발생하는 이벤트

/// 통화 이벤트 열거형
enum CallEvent {
    case incomingCall(Call)         // 수신 전화 도착
    case callConnected(UUID)        // 통화 연결됨
    case callEnded(UUID)            // 통화 종료됨
    case callFailed(UUID, Error)    // 통화 실패
    case muteChanged(UUID, Bool)    // 음소거 상태 변경
    case holdChanged(UUID, Bool)    // 보류 상태 변경
}
