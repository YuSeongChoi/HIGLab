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
        
        // delegate 연결 (queue: nil = 메인 큐)
        provider.setDelegate(self, queue: nil)
    }
}

extension ProviderManager: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        // 모든 통화 정리
    }
}
