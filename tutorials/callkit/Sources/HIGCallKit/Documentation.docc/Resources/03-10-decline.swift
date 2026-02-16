import CallKit
import AVFoundation

extension CallManager: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        activeCalls.removeAll()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        guard activeCalls[action.callUUID] != nil else {
            action.fail()
            return
        }
        action.fulfill()
    }
    
    // 사용자가 전화를 거절하거나 종료할 때
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        guard let call = activeCalls[action.callUUID] else {
            action.fail()
            return
        }
        
        // VoIP 연결 종료
        endCall(call)
        
        // 활성 통화에서 제거
        activeCalls.removeValue(forKey: action.callUUID)
        
        action.fulfill()
    }
    
    private func endCall(_ call: Call) {
        // 서버에 통화 종료 알림
        print("Ending call: \(call.handle)")
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        VoIPEngine.shared.startAudio(session: audioSession)
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        VoIPEngine.shared.stopAudio()
    }
}

class CallManager: NSObject {
    var activeCalls: [UUID: Call] = [:]
}

struct Call {
    let uuid: UUID
    let handle: String
}

class VoIPEngine {
    static let shared = VoIPEngine()
    func startAudio(session: AVAudioSession) { }
    func stopAudio() { }
}
