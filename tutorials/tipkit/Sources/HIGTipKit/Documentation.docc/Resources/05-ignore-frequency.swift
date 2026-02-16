import SwiftUI
import TipKit

// MARK: - IgnoresDisplayFrequency
// 전역 displayFrequency 설정을 무시합니다.

struct UrgentTip: Tip {
    var title: Text {
        Text("긴급 안내")
    }
    
    var message: Text? {
        Text("이 기능은 바로 확인이 필요합니다")
    }
    
    var options: [TipOption] {
        // 전역 빈도 제한 무시
        // Tips.configure의 displayFrequency와 상관없이 즉시 표시
        IgnoresDisplayFrequency(true)
    }
}

// 사용 예시:
// Tips.configure를 displayFrequency: .daily로 설정해도
// UrgentTip은 조건 충족 즉시 표시됨

// 💡 사용 시나리오:
// - 보안 관련 긴급 알림
// - 결제/구독 관련 중요 안내
// - 앱 업데이트 필수 알림
