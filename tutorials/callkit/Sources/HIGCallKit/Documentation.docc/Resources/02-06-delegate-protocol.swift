import CallKit
import UIKit

final class ProviderManager: NSObject {
    private let provider: CXProvider
    
    override init() {
        let configuration = CXProviderConfiguration()
        configuration.localizedName = "My VoIP App"
        configuration.supportsVideo = true
        configuration.supportedHandleTypes = [.phoneNumber]
        
        provider = CXProvider(configuration: configuration)
        
        super.init()
    }
}

// CXProviderDelegate 프로토콜 구현
extension ProviderManager: CXProviderDelegate {
    // 필수: Provider가 리셋될 때 호출
    func providerDidReset(_ provider: CXProvider) {
        // 모든 통화 정리
    }
}
