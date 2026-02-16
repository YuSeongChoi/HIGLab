import CallKit
import AVFoundation

extension CallManager: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        activeCalls.removeAll()
    }
    
    // 사용자가 전화를 받았을 때
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        guard let call = activeCalls[action.callUUID] else {
            action.fail()
            return
        }
        
        // 통화 응답 처리
        answerCall(call)
        
        // 성공 알림
        action.fulfill()
    }
    
    private func answerCall(_ call: Call) {
        // VoIP 엔진에서 통화 응답
        print("Answering call: \(call.handle)")
    }
}

class CallManager: NSObject {
    var activeCalls: [UUID: Call] = [:]
}

struct Call {
    let uuid: UUID
    let handle: String
}
