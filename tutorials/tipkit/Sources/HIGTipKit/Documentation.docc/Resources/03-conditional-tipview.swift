import SwiftUI
import TipKit

struct ConditionalTip: Tip {
    // 파라미터로 조건 설정
    @Parameter
    static var hasSeenOnboarding: Bool = false
    
    var title: Text { Text("온보딩 완료") }
    var message: Text? { Text("이제 모든 기능을 사용할 수 있어요") }
    
    // 온보딩을 본 사용자에게만 표시
    var rules: [Rule] {
        #Rule(Self.$hasSeenOnboarding) { $0 == true }
    }
}

struct ConditionalTipView: View {
    let conditionalTip = ConditionalTip()
    @State private var onboardingComplete = false
    
    var body: some View {
        VStack {
            // rules 조건이 충족되면 자동으로 표시됨
            TipView(conditionalTip)
            
            Button("온보딩 완료하기") {
                // 파라미터 업데이트 → 팁 표시 조건 재평가
                ConditionalTip.hasSeenOnboarding = true
            }
        }
    }
}
