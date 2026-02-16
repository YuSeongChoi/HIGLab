import SwiftUI
import TipKit

struct WelcomeTip: Tip {
    var title: Text {
        Text("환영합니다!")
    }
    
    var message: Text? {
        Text("이 앱의 주요 기능을 알아보세요")
    }
    
    var image: Image? {
        Image(systemName: "hand.wave.fill")
    }
}

struct ContentView: View {
    // Tip 인스턴스 생성
    let welcomeTip = WelcomeTip()
    
    var body: some View {
        VStack(spacing: 20) {
            // TipView에 팁 전달
            // 팁이 표시 가능한 상태일 때만 렌더링됨
            TipView(welcomeTip)
            
            Text("메인 콘텐츠")
                .font(.title)
            
            Spacer()
        }
        .padding()
    }
}
