import CallKit
import AVFoundation

// CallKit 아키텍처
//
// 수신 전화 흐름:
// 서버 → PushKit → 앱 → CXProvider.reportNewIncomingCall → 시스템 UI
//
// 발신 전화 흐름:
// 사용자 → 앱 → CXCallController.request → CXProvider delegate → 시스템

class CallManager {
    // CXProvider: 앱 → 시스템 (이벤트 보고)
    private var provider: CXProvider?
    
    // CXCallController: 앱 → 시스템 (액션 요청)
    private let callController = CXCallController()
}
