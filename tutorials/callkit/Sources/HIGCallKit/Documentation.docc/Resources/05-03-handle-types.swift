import CallKit
import UIKit

func createProviderConfiguration() -> CXProviderConfiguration {
    let configuration = CXProviderConfiguration()
    
    if let iconImage = UIImage(named: "CallKitIcon") {
        configuration.iconTemplateImageData = iconImage.pngData()
    }
    
    configuration.ringtoneSound = "custom_ringtone.caf"
    
    // 지원하는 handle 타입 설정
    configuration.supportedHandleTypes = [
        .phoneNumber,  // 전화번호 (E.164 형식 권장)
        .emailAddress, // 이메일 주소
        .generic       // 사용자 ID, 사용자명 등
    ]
    
    return configuration
}
