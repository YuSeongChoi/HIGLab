import SwiftUI
import TipKit

// MARK: - 기본 동작
// 사용자가 팁을 닫으면 TipKit이 자동으로 기억합니다.
// 기본적으로 닫힌 팁은 다시 표시되지 않습니다.

struct DefaultTip: Tip {
    var title: Text {
        Text("기본 팁")
    }
    
    var message: Text? {
        Text("이 팁을 닫으면 다시 표시되지 않습니다")
    }
}

struct DefaultBehaviorView: View {
    let tip = DefaultTip()
    
    var body: some View {
        VStack {
            TipView(tip)
            // 사용자가 X 버튼을 누르면:
            // 1. 팁이 화면에서 사라짐
            // 2. TipKit이 "닫힘" 상태를 저장
            // 3. 앱 재시작 후에도 다시 표시 안 함
            
            Text("팁 상태: \(String(describing: tip.status))")
                .font(.caption)
        }
    }
}
