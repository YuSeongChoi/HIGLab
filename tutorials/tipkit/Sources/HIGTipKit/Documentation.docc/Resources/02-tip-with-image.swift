import SwiftUI
import TipKit

struct FavoriteTip: Tip {
    var title: Text {
        Text("즐겨찾기에 추가")
    }
    
    var message: Text? {
        Text("하트 버튼을 탭하면 이 항목을 즐겨찾기에 추가할 수 있어요")
    }
    
    // SF Symbol 아이콘 추가 (선택)
    var image: Image? {
        Image(systemName: "heart.fill")
    }
}

// 다양한 SF Symbol 예시:
// - "star.fill" : 별표/즐겨찾기
// - "hand.tap" : 탭 제스처
// - "hand.draw" : 스와이프 제스처
// - "keyboard" : 키보드 단축키
// - "lightbulb.fill" : 팁/아이디어
