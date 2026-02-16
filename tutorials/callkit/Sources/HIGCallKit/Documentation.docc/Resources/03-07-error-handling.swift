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
        let callUUID = UUID()
        
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .phoneNumber, value: handle)
        update.localizedCallerName = callerName
        update.hasVideo = hasVideo
        
        provider.reportNewIncomingCall(with: callUUID, update: update) { error in
            if let error = error {
                // 에러 처리
                self.handleIncomingCallError(error)
                completion(.failure(error))
                return
            }
            
            let call = Call(uuid: callUUID, handle: handle)
            self.activeCalls[callUUID] = call
            completion(.success(callUUID))
        }
    }
    
    private func handleIncomingCallError(_ error: Error) {
        let callError = error as? CXErrorCodeIncomingCallError
        
        switch callError {
        case .callUUIDAlreadyExists:
            print("이미 같은 UUID의 통화가 존재함")
        case .filteredByDoNotDisturb:
            print("방해 금지 모드로 차단됨")
        case .filteredByBlockList:
            print("차단 목록으로 차단됨")
        default:
            print("수신 전화 보고 실패: \(error.localizedDescription)")
        }
    }
}

struct Call {
    let uuid: UUID
    let handle: String
}
