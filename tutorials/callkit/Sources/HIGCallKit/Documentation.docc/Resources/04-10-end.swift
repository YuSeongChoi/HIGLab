import CallKit

class CallManager: NSObject {
    private let provider: CXProvider
    private let callController = CXCallController()
    var activeCalls: [UUID: Call] = [:]
    
    init(provider: CXProvider) {
        self.provider = provider
    }
    
    // 사용자가 통화 종료 버튼 클릭
    func endCall(uuid: UUID) async throws {
        let endCallAction = CXEndCallAction(call: uuid)
        let transaction = CXTransaction(action: endCallAction)
        
        try await callController.request(transaction)
    }
}

extension CallManager: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        activeCalls.removeAll()
    }
    
    // 통화 종료 delegate
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        let uuid = action.callUUID
        
        // VoIP 연결 종료
        disconnectVoIP(uuid: uuid)
        
        // 통화 목록에서 제거
        activeCalls.removeValue(forKey: uuid)
        
        action.fulfill()
    }
    
    private func disconnectVoIP(uuid: UUID) {
        // WebRTC, SIP 연결 종료
    }
}

struct Call {
    let uuid: UUID
    var handle: String
    var isConnected: Bool = false
}
