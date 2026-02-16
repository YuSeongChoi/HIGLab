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
    
    // 사용자가 전화를 받았을 때
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        // 통화 연결 로직 구현
        let callUUID = action.callUUID
        
        // 오디오 세션 설정
        configureAudioSession()
        
        // VoIP 연결 시작
        connectCall(uuid: callUUID)
        
        // 액션 완료 알림 (반드시 호출!)
        action.fulfill()
    }
    
    private func configureAudioSession() {
        // 오디오 세션 설정
    }
    
    private func connectCall(uuid: UUID) {
        // VoIP 연결
    }
}
