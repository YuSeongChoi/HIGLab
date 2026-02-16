import SwiftUI
import TipKit

// MARK: - 스마트한 표시 로직
// TipKit이 자동으로 처리하는 것들:
// 1. 한 번에 하나의 팁만 표시
// 2. 이미 본 팁은 다시 표시 안 함
// 3. 기기 간 상태 동기화 (iCloud)

struct FeatureTipA: Tip {
    var title: Text { Text("기능 A") }
}

struct FeatureTipB: Tip {
    var title: Text { Text("기능 B") }
}

struct FeatureTipC: Tip {
    var title: Text { Text("기능 C") }
}

struct SmartTipDemo: View {
    // 세 개의 팁이 있지만, TipKit은 한 번에 하나만 표시합니다.
    let tipA = FeatureTipA()
    let tipB = FeatureTipB()
    let tipC = FeatureTipC()
    
    var body: some View {
        VStack(spacing: 20) {
            Button("기능 A") { }
                .popoverTip(tipA)
            
            Button("기능 B") { }
                .popoverTip(tipB)
            
            Button("기능 C") { }
                .popoverTip(tipC)
        }
        // tipA를 닫으면 tipB가 표시됨
        // tipB를 닫으면 tipC가 표시됨
        // 한 번 닫은 팁은 다시 표시되지 않음
    }
}
