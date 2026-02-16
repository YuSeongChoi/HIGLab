import CallKit
import UIKit

final class ProviderManager: NSObject {
    private let provider: CXProvider
    
    override init() {
        let configuration = CXProviderConfiguration()
        configuration.localizedName = "My VoIP App"
        
        provider = CXProvider(configuration: configuration)
        super.init()
        provider.setDelegate(self, queue: nil)
    }
}

extension ProviderManager: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        print("Provider did reset")
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        configureAudioSession()
        connectCall(uuid: action.callUUID)
        action.fulfill()
    }
    
    // 통화 종료 시
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        let callUUID = action.callUUID
        
        // VoIP 연결 종료
        disconnectCall(uuid: callUUID)
        
        // 오디오 세션 정리
        deactivateAudioSession()
        
        // 액션 완료
        action.fulfill()
    }
    
    private func configureAudioSession() { }
    private func connectCall(uuid: UUID) { }
    private func disconnectCall(uuid: UUID) { }
    private func deactivateAudioSession() { }
}
