import SwiftUI
import TipKit

// MARK: - 무한 표시 설정
// ⚠️ 권장하지 않음 - 사용자 경험을 해칠 수 있음

struct PersistentTip: Tip {
    var title: Text {
        Text("항상 표시되는 팁")
    }
    
    var message: Text? {
        Text("이 팁은 닫아도 계속 표시됩니다")
    }
    
    var options: [TipOption] {
        // 무제한 표시 - 닫아도 다시 나타남
        // ⚠️ 거의 사용하지 않는 것이 좋음
        MaxDisplayCount(.max)
    }
}

// ❌ 피해야 할 패턴:
// - 광고성 팁에 무한 표시
// - 사용자가 이미 알고 있는 기능에 무한 표시
// - 닫기 버튼 없이 팁 표시

// ✅ 올바른 대안:
// - 사용자가 기능을 사용하면 invalidate() 호출
// - MaxDisplayCount(2-3) 사용
// - rules로 조건부 표시
