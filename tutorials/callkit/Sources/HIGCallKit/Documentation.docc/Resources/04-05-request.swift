import CallKit

class CallManager {
    private let callController = CXCallController()
    
    func startCall(to phoneNumber: String, hasVideo: Bool = false) async throws {
        let callUUID = UUID()
        let handle = CXHandle(type: .phoneNumber, value: phoneNumber)
        
        let startCallAction = CXStartCallAction(
            call: callUUID,
            handle: handle
        )
        startCallAction.isVideo = hasVideo
        
        let transaction = CXTransaction(action: startCallAction)
        
        // 시스템에 발신 전화 요청
        try await callController.request(transaction)
    }
}
