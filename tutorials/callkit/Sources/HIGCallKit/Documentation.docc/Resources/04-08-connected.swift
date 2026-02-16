import CallKit
import AVFoundation

class CallManager: NSObject {
    private let provider: CXProvider
    var activeCalls: [UUID: Call] = [:]
    
    init(provider: CXProvider) {
        self.provider = provider
    }
    
    // VoIP 엔진에서 상대방 응답 시 호출
    func callConnected(uuid: UUID) {
        // 시스템에 연결 완료 알림
        provider.reportOutgoingCall(
            with: uuid,
            connectedAt: Date()
        )
        
        // 통화 상태 업데이트
        activeCalls[uuid]?.isConnected = true
    }
}

extension CallManager: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        activeCalls.removeAll()
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        // 연결 시작
        provider.reportOutgoingCall(
            with: action.callUUID,
            startedConnectingAt: Date()
        )
        
        action.fulfill()
    }
}

struct Call {
    let uuid: UUID
    var handle: String
    var isConnected: Bool = false
}
