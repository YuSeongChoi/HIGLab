import CallKit
import UIKit

let configuration = CXProviderConfiguration()
configuration.localizedName = "My VoIP App"

if let iconImage = UIImage(named: "CallIcon") {
    configuration.iconTemplateImageData = iconImage.pngData()
}
configuration.ringtoneSound = "ringtone.caf"

// 지원하는 handle 타입
configuration.supportedHandleTypes = [.phoneNumber, .generic]

// 영상 통화 지원 여부
configuration.supportsVideo = true

// 통화 그룹당 최대 통화 수 (컨퍼런스 콜)
configuration.maximumCallsPerCallGroup = 1

// 통화 그룹 수
configuration.maximumCallGroups = 1

// 통화 UI 포함 여부
configuration.includesCallsInRecents = true
