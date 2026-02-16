import SwiftUI
import TipKit

struct LayoutTip: Tip {
    var title: Text { Text("레이아웃 팁") }
    var message: Text? { Text("팁이 사라지면 공간도 자연스럽게 조정됩니다") }
}

struct LayoutExample: View {
    let layoutTip = LayoutTip()
    
    var body: some View {
        VStack(spacing: 16) {
            Text("상단 콘텐츠")
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue.opacity(0.2))
            
            // TipView가 숨겨지면 이 공간이 사라짐
            // 자연스러운 애니메이션과 함께
            TipView(layoutTip)
                .transition(.opacity.combined(with: .move(edge: .top)))
            
            Text("하단 콘텐츠")
                .frame(maxWidth: .infinity)
                .padding()
                .background(.green.opacity(0.2))
            
            Spacer()
        }
        .padding()
        .animation(.spring(), value: layoutTip.status)
    }
}
