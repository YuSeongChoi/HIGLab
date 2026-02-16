import CallKit
import AVFoundation

extension CallManager: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        activeCalls.removeAll()
    }
    
    // 발신 전화 시작 요청 처리
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        // VoIP 연결 준비
        configureAudioSession()
        
        // 실제 VoIP 발신 시작
        let handle = action.handle.value
        startVoIPCall(to: handle, uuid: action.callUUID)
        
        // 통화 시작 알림 (아직 연결되지 않음)
        provider.reportOutgoingCall(with: action.callUUID, startedConnectingAt: Date())
        
        action.fulfill()
    }
    
    private func configureAudioSession() {
        // 오디오 세션 설정
    }
    
    private func startVoIPCall(to handle: String, uuid: UUID) {
        // WebRTC, SIP 등 실제 VoIP 연결
    }
}

class CallManager: NSObject {
    var activeCalls: [UUID: Call] = [:]
}

struct Call {
    let uuid: UUID
    var handle: String
}
