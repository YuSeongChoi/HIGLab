import CallKit

class CallManager {
    private let callController = CXCallController()
    
    func startCall(to phoneNumber: String, hasVideo: Bool = false) async throws -> UUID {
        let callUUID = UUID()
        let handle = CXHandle(type: .phoneNumber, value: phoneNumber)
        
        let startCallAction = CXStartCallAction(
            call: callUUID,
            handle: handle
        )
        startCallAction.isVideo = hasVideo
        
        let transaction = CXTransaction(action: startCallAction)
        
        do {
            try await callController.request(transaction)
            return callUUID
        } catch {
            // 에러 처리
            handleCallError(error)
            throw error
        }
    }
    
    private func handleCallError(_ error: Error) {
        if let requestError = error as? CXErrorCodeRequestTransactionError {
            switch requestError.code {
            case .unknown:
                print("알 수 없는 에러")
            case .unentitled:
                print("권한 없음")
            case .unknownCallProvider:
                print("Provider를 찾을 수 없음")
            case .emptyTransaction:
                print("빈 트랜잭션")
            case .unknownCallUUID:
                print("알 수 없는 통화 UUID")
            case .callUUIDAlreadyExists:
                print("이미 존재하는 UUID")
            case .invalidAction:
                print("잘못된 액션")
            case .maximumCallGroupsReached:
                print("최대 통화 그룹 수 초과")
            @unknown default:
                print("새로운 에러")
            }
        }
    }
}
