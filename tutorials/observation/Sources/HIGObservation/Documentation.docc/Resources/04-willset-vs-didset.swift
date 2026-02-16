import Foundation
import Observation

/// willSet vs didSet - 왜 willSet을 사용하나요?
///
/// SwiftUI는 "변경 전"에 알림을 받아야
/// 현재 값과 새 값을 비교하고 애니메이션을 계획할 수 있습니다.

@Observable
class AnimatedValue {
    var position: CGFloat = 0
    
    // 내부적으로 이렇게 동작합니다:
    //
    // var position: CGFloat {
    //     get { _position }
    //     set {
    //         // 🔹 willSet 시점: "position이 바뀔 것이다" 알림
    //         _$observationRegistrar.willSet(self, keyPath: \.position)
    //
    //         _position = newValue  // 실제 값 변경
    //
    //         // 🔹 didSet 시점: 값이 바뀐 후
    //         _$observationRegistrar.didSet(self, keyPath: \.position)
    //     }
    // }
}

// 💡 SwiftUI 렌더링 흐름:
//
// 1. willSet 알림 수신
// 2. 현재 뷰 스냅샷 저장
// 3. 다음 RunLoop에서:
//    - 새 값 읽기
//    - 새 뷰 스냅샷 생성
//    - 두 스냅샷 비교
//    - 애니메이션 적용

// 📝 만약 didSet이었다면?
// 값이 이미 바뀐 후라서 이전 값을 알 수 없고,
// 자연스러운 애니메이션 계산이 어려웠을 것입니다.
