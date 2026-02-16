import SwiftUI
import TipKit

// MARK: - 존중 (Respect)
// 사용자가 팁을 닫으면, 그 결정을 존중합니다.
// TipKit은 기본적으로 닫힌 팁을 다시 표시하지 않습니다.

struct RespectfulTip: Tip {
    var title: Text {
        Text("새로운 기능")
    }
    
    var message: Text? {
        Text("이 기능을 사용해보세요")
    }
}

struct RespectfulView: View {
    let tip = RespectfulTip()
    
    var body: some View {
        VStack {
            // 사용자가 X 버튼을 누르면 팁이 사라짐
            TipView(tip)
            
            // 이후 앱을 다시 실행해도 이 팁은 표시되지 않음
            // TipKit이 자동으로 "닫힌 팁" 상태를 기억함
            
            Text("팁을 닫으면 다시 표시되지 않습니다")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// 만약 정말 중요한 팁이라면 MaxDisplayCount를 사용할 수 있지만,
// 이는 신중하게 사용해야 합니다.

struct ImportantTip: Tip {
    var title: Text {
        Text("중요한 안내")
    }
    
    // 최대 3번까지만 표시 (그래도 3번이면 충분히 많음!)
    var options: [TipOption] {
        MaxDisplayCount(3)
    }
}
