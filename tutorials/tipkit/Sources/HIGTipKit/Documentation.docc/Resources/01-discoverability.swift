import SwiftUI
import TipKit

// MARK: - 발견 가능성 (Discoverability)
// 숨겨진 기능이나 제스처를 사용자가 발견하도록 돕습니다.

struct PinchToZoomTip: Tip {
    var title: Text {
        Text("핀치로 확대/축소")
    }
    
    var message: Text? {
        Text("두 손가락으로 핀치하면 지도를 확대하거나 축소할 수 있어요")
    }
    
    var image: Image? {
        Image(systemName: "hand.pinch")
    }
}

struct LongPressTip: Tip {
    var title: Text {
        Text("길게 눌러서 옵션 보기")
    }
    
    var message: Text? {
        Text("항목을 길게 누르면 더 많은 옵션을 볼 수 있어요")
    }
    
    var image: Image? {
        Image(systemName: "hand.tap")
    }
}

struct SwipeActionTip: Tip {
    var title: Text {
        Text("스와이프로 빠른 작업")
    }
    
    var message: Text? {
        Text("항목을 왼쪽으로 스와이프하면 삭제, 오른쪽으로 스와이프하면 즐겨찾기에 추가할 수 있어요")
    }
    
    var image: Image? {
        Image(systemName: "hand.draw")
    }
}
