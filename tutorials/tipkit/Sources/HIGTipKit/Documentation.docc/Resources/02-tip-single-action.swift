import SwiftUI
import TipKit

// MARK: - 단일 액션 버튼이 있는 팁

struct LearnMoreTip: Tip {
    var title: Text {
        Text("고급 편집 기능")
    }
    
    var message: Text? {
        Text("더 많은 편집 옵션을 사용해보세요")
    }
    
    var image: Image? {
        Image(systemName: "wand.and.stars")
    }
    
    // 액션 버튼 추가
    var actions: [Action] {
        Action(id: "learn-more", title: "자세히 알아보기")
    }
}
