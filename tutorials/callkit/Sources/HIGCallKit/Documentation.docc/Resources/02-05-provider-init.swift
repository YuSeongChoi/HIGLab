import CallKit
import UIKit

final class ProviderManager {
    private let provider: CXProvider
    
    init() {
        let configuration = CXProviderConfiguration()
        configuration.localizedName = "My VoIP App"
        configuration.supportsVideo = true
        configuration.supportedHandleTypes = [.phoneNumber]
        configuration.maximumCallsPerCallGroup = 1
        
        if let iconImage = UIImage(named: "CallIcon") {
            configuration.iconTemplateImageData = iconImage.pngData()
        }
        
        // CXProvider 인스턴스 생성
        provider = CXProvider(configuration: configuration)
    }
}
