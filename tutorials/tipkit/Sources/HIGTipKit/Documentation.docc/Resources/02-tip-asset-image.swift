import SwiftUI
import TipKit

// MARK: - Asset 이미지 사용
// SF Symbol 대신 커스텀 에셋 이미지를 사용할 수 있습니다.

struct CustomImageTip: Tip {
    var title: Text {
        Text("새로운 기능")
    }
    
    var message: Text? {
        Text("이 기능으로 더 많은 것을 할 수 있어요")
    }
    
    // Assets에 추가한 커스텀 이미지 사용
    var image: Image? {
        Image("custom-tip-icon")  // Assets.xcassets의 이미지
    }
}

// 💡 이미지 가이드:
// - 권장 크기: 24x24 ~ 48x48 포인트
// - Template 렌더링 모드 권장 (시스템 tint 색상 적용)
// - 간결한 아이콘 스타일 사용
