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
        // Provider가 리셋됨 - 모든 통화 정리
        print("Provider did reset")
    }
    
    func providerDidBegin(_ provider: CXProvider) {
        // Provider가 시작됨
        print("Provider did begin")
    }
}
