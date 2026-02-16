import CallKit

class CallManager {
    private let provider: CXProvider
    private var activeCalls: [UUID: Call] = [:]
    
    init(provider: CXProvider) {
        self.provider = provider
    }
    
    func reportIncomingCall(
        handle: String,
        callerName: String?,
        hasVideo: Bool,
        completion: @escaping (Result<UUID, Error>) -> Void
    ) {
        // 각 통화마다 고유한 UUID 생성
        let callUUID = UUID()
        
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .phoneNumber, value: handle)
        update.localizedCallerName = callerName
        update.hasVideo = hasVideo
        
        provider.reportNewIncomingCall(with: callUUID, update: update) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                // UUID를 활성 통화 목록에 저장
                let call = Call(uuid: callUUID, handle: handle)
                self.activeCalls[callUUID] = call
                completion(.success(callUUID))
            }
        }
    }
}

struct Call {
    let uuid: UUID
    let handle: String
}
