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
        
        // 오디오는 didActivate에서 시작
        action.fulfill()
    }
    
    // 오디오 세션이 활성화되면 호출됨
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        // 이제 오디오 통신을 시작해도 안전함
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
    
    func startAudio(session: AVAudioSession) {
        // WebRTC, 오디오 스트림 시작 등
    }
    
    func stopAudio() {
        // 오디오 정리
    }
}
