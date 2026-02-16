import CallKit
import UIKit

func createProviderConfiguration() -> CXProviderConfiguration {
    let configuration = CXProviderConfiguration()
    
    // 앱 이름
    configuration.localizedName = "My VoIP App"
    
    // 아이콘
    if let iconImage = UIImage(named: "CallKitIcon") {
        configuration.iconTemplateImageData = iconImage.pngData()
    }
    
    // 벨소리
    configuration.ringtoneSound = "custom_ringtone.caf"
    
    // Handle 타입
    configuration.supportedHandleTypes = [.phoneNumber]
    
    // 영상 통화 지원
    configuration.supportsVideo = true
    
    // 컨퍼런스 콜 설정
    // 동시에 가능한 통화 그룹 수
    configuration.maximumCallGroups = 2
    
    // 그룹당 최대 통화 수 (컨퍼런스 참가자)
    configuration.maximumCallsPerCallGroup = 5
    
    // 최근 통화 기록에 포함
    configuration.includesCallsInRecents = true
    
    return configuration
}
