import SwiftUI
import TipKit

// MARK: - 복수 액션 버튼이 있는 팁

struct NotificationTip: Tip {
    var title: Text {
        Text("알림 설정")
    }
    
    var message: Text? {
        Text("알림을 켜면 중요한 업데이트를 놓치지 않아요")
    }
    
    var image: Image? {
        Image(systemName: "bell.badge")
    }
    
    // 여러 액션 제공
    var actions: [Action] {
        Action(id: "enable-now", title: "지금 켜기")
        Action(id: "go-to-settings", title: "설정으로 이동")
    }
}

// 💡 액션 버튼 가이드:
// - 첫 번째 버튼: 주요 행동 (강조)
// - 두 번째 버튼: 보조 행동
// - 최대 2개 권장 (3개 이상은 복잡해 보임)
