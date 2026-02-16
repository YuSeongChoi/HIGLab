import SwiftUI
import TipKit

struct FavoriteTip: Tip {
    // 팁의 제목 - 핵심 내용을 한 줄로
    var title: Text {
        Text("즐겨찾기에 추가")
    }
    
    // 팁의 설명 - 추가 정보 제공 (선택)
    var message: Text? {
        Text("하트 버튼을 탭하면 이 항목을 즐겨찾기에 추가할 수 있어요")
    }
}

// 💡 좋은 팁 작성 가이드:
// - title: 7단어 이내로 간결하게
// - message: 구체적인 행동 방법 설명
// - 사용자 관점에서 작성 ("~할 수 있어요")
