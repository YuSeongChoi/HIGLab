import SwiftUI
import TipKit

// MARK: - 테스트용 팁 표시
// 개발 중 팁을 반복 테스트할 때 사용합니다.

struct TestingTipsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Button("모든 팁 강제 표시") {
                // 조건/상태와 상관없이 모든 팁 표시
                Tips.showAllTipsForTesting()
            }
            
            Button("특정 팁만 표시") {
                // 특정 팁 타입만 강제 표시
                Tips.showTipsForTesting([MySpecificTip.self])
            }
            
            Button("모든 팁 숨기기") {
                // 테스트용으로 모든 팁 숨기기
                Tips.hideAllTipsForTesting()
            }
        }
        .buttonStyle(.bordered)
    }
}

struct MySpecificTip: Tip {
    var title: Text { Text("테스트 팁") }
}

// 💡 디버그 빌드에서만 사용:
// #if DEBUG
//     Tips.showAllTipsForTesting()
// #endif
