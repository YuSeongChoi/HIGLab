import CallKit
import UIKit

let configuration = CXProviderConfiguration()
configuration.localizedName = "My VoIP App"

// 통화 화면에 표시될 아이콘 (40x40 포인트)
if let iconImage = UIImage(named: "CallIcon") {
    configuration.iconTemplateImageData = iconImage.pngData()
}

// 커스텀 벨소리 (앱 번들 내 파일)
configuration.ringtoneSound = "ringtone.caf"
