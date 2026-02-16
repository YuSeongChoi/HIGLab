import SwiftUI
import TipKit

struct StyledTip: Tip {
    var title: Text {
        Text("스타일링된 팁")
    }
    
    var message: Text? {
        Text("팁의 외관을 커스터마이징할 수 있어요")
    }
    
    var image: Image? {
        Image(systemName: "paintbrush.fill")
    }
}

struct StyledTipView: View {
    let styledTip = StyledTip()
    
    var body: some View {
        VStack {
            // 기본 스타일
            TipView(styledTip)
            
            // tint 색상 변경
            TipView(styledTip)
                .tint(.purple)
            
            // 배경 스타일 변경
            TipView(styledTip)
                .tipBackground(.orange.opacity(0.1))
        }
        .padding()
    }
}
