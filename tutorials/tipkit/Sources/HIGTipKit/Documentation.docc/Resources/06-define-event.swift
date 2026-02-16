import SwiftUI
import TipKit

// MARK: - Event 정의
// 특정 행동을 추적하기 위한 이벤트를 정의합니다.

struct SearchFilterTip: Tip {
    // 검색 이벤트 정의
    // 고유 ID로 이벤트 식별
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
}
