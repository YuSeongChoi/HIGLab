import CallKit

class CallManager {
    private let provider: CXProvider
    
    init(provider: CXProvider) {
        self.provider = provider
    }
    
    func reportIncomingCall(
        handle: String,
        callerName: String?,
        hasVideo: Bool,
        completion: @escaping (Error?) -> Void
    ) {
        let uuid = UUID()
        
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .phoneNumber, value: handle)
        update.localizedCallerName = callerName
        update.hasVideo = hasVideo
        
        // 시스템에 수신 전화 보고
        provider.reportNewIncomingCall(
            with: uuid,
            update: update,
            completion: completion
        )
    }
}
