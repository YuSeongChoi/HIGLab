import MultipeerConnectivity
import UIKit

// discoveryInfo를 활용한 추가 정보 전달
let discoveryInfo: [String: String] = [
    "deviceType": UIDevice.current.model,           // "iPhone", "iPad" 등
    "appVersion": Bundle.main.appVersion ?? "1.0",  // 앱 버전
    "username": "사용자이름"                          // 사용자 설정 이름
]

let advertiser = MCNearbyServiceAdvertiser(
    peer: peerID,
    discoveryInfo: discoveryInfo,  // 브라우저가 foundPeer에서 받음
    serviceType: serviceType
)

// Bundle extension
extension Bundle {
    var appVersion: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
