import CallKit
import UIKit

func createProviderConfiguration() -> CXProviderConfiguration {
    let configuration = CXProviderConfiguration()
    
    if let iconImage = UIImage(named: "CallKitIcon") {
        configuration.iconTemplateImageData = iconImage.pngData()
    }
    
    // 커스텀 벨소리 설정
    // 파일은 앱 번들에 포함되어야 함
    configuration.ringtoneSound = "custom_ringtone.caf"
    
    return configuration
}

// 벨소리 요구사항:
// - 형식: CAF (Core Audio Format) 권장
// - 길이: 최대 30초
// - 앱 번들의 루트 또는 Resources 폴더에 위치
// - 파일명만 지정 (경로 불필요)
