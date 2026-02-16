import SwiftUI
import TipKit

// MARK: - 기본 Tip 구조체
// Tip 프로토콜을 채택하는 구조체를 만듭니다.
// title은 필수, message와 image는 선택입니다.

struct FavoriteTip: Tip {
    // 필수: 팁의 제목
    var title: Text {
        Text("즐겨찾기에 추가")
    }
}
