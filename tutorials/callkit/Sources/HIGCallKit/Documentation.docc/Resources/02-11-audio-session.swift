import CallKit
import AVFoundation

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
    func providerDidReset(_ provider: CXProvider) { }
    
    // 오디오 세션 활성화 시점
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        // 이 시점에 실제 오디오 시작
        print("Audio session activated")
        
        // VoIP 엔진에 오디오 시작 알림
        VoIPEngine.shared.startAudio()
    }
    
    // 오디오 세션 비활성화 시점
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        // 오디오 정리
        print("Audio session deactivated")
        
        VoIPEngine.shared.stopAudio()
    }
}

// VoIP 엔진 (예시)
class VoIPEngine {
    static let shared = VoIPEngine()
    func startAudio() { }
    func stopAudio() { }
}
