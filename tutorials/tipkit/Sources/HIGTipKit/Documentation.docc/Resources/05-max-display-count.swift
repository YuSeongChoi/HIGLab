import SwiftUI
import TipKit

// MARK: - MaxDisplayCount 설정
// 팁이 표시될 최대 횟수를 지정합니다.

struct ImportantTip: Tip {
    var title: Text {
        Text("중요한 기능")
    }
    
    var message: Text? {
        Text("이 기능을 꼭 사용해보세요!")
    }
    
    var image: Image? {
        Image(systemName: "star.fill")
    }
    
    // options 배열에 MaxDisplayCount 추가
    var options: [TipOption] {
        // 3번까지 표시 (3번 닫으면 더 이상 표시 안 함)
        MaxDisplayCount(3)
    }
}

// 💡 사용 가이드:
// - 1: 한 번만 표시 (기본값과 동일)
// - 2-3: 중요한 팁에 적합
// - 5 이상: 사용자 경험 저하 가능, 신중하게 사용
