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
        
        provider = CXProvider(configuration: config)
        
        super.init()
        
        provider.setDelegate(self, queue: nil)
    }
}

extension CallManager: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        // 모든 통화 정리
        activeCalls.removeAll()
    }
}
