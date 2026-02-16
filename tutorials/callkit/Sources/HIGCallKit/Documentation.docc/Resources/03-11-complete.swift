import CallKit
import AVFoundation

final class CallManager: NSObject {
    static let shared = CallManager()
    
    private let provider: CXProvider
    private let callController = CXCallController()
    private var activeCalls: [UUID: Call] = [:]
    
    private override init() {
        let config = CXProviderConfiguration()
        config.localizedName = "My VoIP App"
        config.supportsVideo = false
        config.supportedHandleTypes = [.phoneNumber]
        
        provider = CXProvider(configuration: config)
        super.init()
        provider.setDelegate(self, queue: nil)
    }
    
    // MARK: - 수신 전화 보고
    
    func reportIncomingCall(
        uuid: UUID,
        handle: String,
        callerName: String?,
        hasVideo: Bool = false,
        completion: @escaping (Error?) -> Void
    ) {
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .phoneNumber, value: handle)
        update.localizedCallerName = callerName
        update.hasVideo = hasVideo
        update.supportsHolding = true
        update.supportsDTMF = true
        
        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            if error == nil {
                let call = Call(uuid: uuid, handle: handle)
                self.activeCalls[uuid] = call
            }
            completion(error)
        }
    }
    
    // MARK: - 통화 상태 업데이트
    
    func reportCallConnected(uuid: UUID) {
        provider.reportOutgoingCall(with: uuid, connectedAt: Date())
    }
    
    func reportCallEnded(uuid: UUID, reason: CXCallEndedReason) {
        provider.reportCall(with: uuid, endedAt: Date(), reason: reason)
        activeCalls.removeValue(forKey: uuid)
    }
}

extension CallManager: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        activeCalls.removeAll()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        guard activeCalls[action.callUUID] != nil else {
            action.fail()
            return
        }
        // 통화 연결은 didActivate에서 처리
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        activeCalls.removeValue(forKey: action.callUUID)
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        // 오디오 시작
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        // 오디오 정리
    }
}

struct Call {
    let uuid: UUID
    let handle: String
    var isConnected: Bool = false
}
