import CallKit
import AVFoundation
import UIKit

final class ProviderManager: NSObject {
    static let shared = ProviderManager()
    
    private let provider: CXProvider
    private var activeCalls: [UUID: Call] = [:]
    
    private override init() {
        let configuration = CXProviderConfiguration()
        configuration.localizedName = "My VoIP App"
        configuration.supportsVideo = true
        configuration.supportedHandleTypes = [.phoneNumber]
        configuration.maximumCallsPerCallGroup = 1
        configuration.includesCallsInRecents = true
        
        if let icon = UIImage(named: "CallIcon") {
            configuration.iconTemplateImageData = icon.pngData()
        }
        
        provider = CXProvider(configuration: configuration)
        super.init()
        provider.setDelegate(self, queue: nil)
    }
    
    func reportIncomingCall(uuid: UUID, handle: String, completion: @escaping (Error?) -> Void) {
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .phoneNumber, value: handle)
        update.hasVideo = false
        
        provider.reportNewIncomingCall(with: uuid, update: update, completion: completion)
    }
}

extension ProviderManager: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        activeCalls.removeAll()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
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
}
