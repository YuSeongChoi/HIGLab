import Foundation

enum CallState: Equatable {
    case idle                    // 대기
    case connecting              // 연결 중 (발신)
    case ringing                 // 벨 울림 (수신)
    case connected(Date)         // 연결됨 (시작 시간)
    case onHold                  // 보류 중
    case ended(CallEndReason)    // 종료됨
}

enum CallEndReason {
    case normal          // 정상 종료
    case missed          // 부재중
    case declined        // 거절
    case failed          // 연결 실패
    case remoteEnded     // 상대방 종료
    case busy            // 통화 중
}

extension CallState {
    var displayText: String {
        switch self {
        case .idle:
            return ""
        case .connecting:
            return "연결 중..."
        case .ringing:
            return "벨이 울리는 중..."
        case .connected:
            return "통화 중"
        case .onHold:
            return "보류 중"
        case .ended(let reason):
            switch reason {
            case .normal: return "통화 종료"
            case .missed: return "부재중 전화"
            case .declined: return "거절됨"
            case .failed: return "연결 실패"
            case .remoteEnded: return "상대방이 종료함"
            case .busy: return "통화 중"
            }
        }
    }
    
    var showsTimer: Bool {
        if case .connected = self { return true }
        return false
    }
}
