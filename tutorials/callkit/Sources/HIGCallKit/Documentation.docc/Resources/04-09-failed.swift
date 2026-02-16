import CallKit

class CallManager: NSObject {
    private let provider: CXProvider
    var activeCalls: [UUID: Call] = [:]
    
    init(provider: CXProvider) {
        self.provider = provider
    }
    
    // VoIP 연결 실패 시 호출
    func callFailed(uuid: UUID, reason: CXCallEndedReason) {
        // 시스템에 통화 종료 알림
        provider.reportCall(
            with: uuid,
            endedAt: Date(),
            reason: reason
        )
        
        // 활성 통화에서 제거
        activeCalls.removeValue(forKey: uuid)
    }
}

// CXCallEndedReason 종류
// .failed: 연결 실패
// .remoteEnded: 상대방 종료
// .unanswered: 응답 없음
// .answeredElsewhere: 다른 기기에서 응답
// .declinedElsewhere: 다른 기기에서 거절

struct Call {
    let uuid: UUID
    var handle: String
    var isConnected: Bool = false
}
