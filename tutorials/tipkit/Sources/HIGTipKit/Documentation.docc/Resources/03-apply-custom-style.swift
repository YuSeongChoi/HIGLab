import SwiftUI
import TipKit

struct MyTip: Tip {
    var title: Text { Text("커스텀 스타일 팁") }
    var message: Text? { Text("완전히 다른 모양으로 표시됩니다") }
    var image: Image? { Image(systemName: "sparkles") }
}

struct ContentView: View {
    let myTip = MyTip()
    
    var body: some View {
        VStack {
            // 커스텀 스타일 적용
            TipView(myTip)
                .tipViewStyle(CustomTipStyle())
            
            Spacer()
        }
        .padding()
    }
}

// 💡 TipViewStyle 활용:
// - 브랜드 아이덴티티에 맞는 디자인
// - 앱의 다른 컴포넌트와 일관성
// - 접근성 향상 (큰 터치 영역 등)
