import SwiftUI
import TipKit

struct SearchFilterTip: Tip {
    static let searchPerformed = Event(id: "searchPerformed")
    
    var title: Text {
        Text("검색 필터 사용하기")
    }
    
    var message: Text? {
        Text("필터를 사용하면 더 정확한 결과를 찾을 수 있어요")
    }
    
    var image: Image? {
        Image(systemName: "line.3.horizontal.decrease.circle")
    }
    
    // 규칙 정의: 검색을 5회 이상 수행해야 팁 표시
    var rules: [Rule] {
        #Rule(Self.searchPerformed.donations.count >= 5) {
            // donations.count: 이벤트가 기록된 횟수
            $0  // 조건이 true면 팁 표시
        }
    }
}

// 💡 이벤트 기반 팁의 장점:
// - 사용자가 기본 기능에 익숙해진 후 고급 기능 안내
// - 반복 사용자에게만 효율성 팁 제공
// - 불필요한 팁으로 초보자 압도하지 않음
