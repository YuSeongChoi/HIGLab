import SwiftUI
import TipKit

struct ShareTip: Tip {
    var title: Text { Text("공유하기") }
    var message: Text? { Text("친구에게 공유해보세요") }
}

struct ArrowDirectionDemo: View {
    let shareTip = ShareTip()
    
    var body: some View {
        VStack(spacing: 40) {
            // 화살표가 위를 가리킴 (팁이 아래에 표시)
            Button("위쪽 화살표") { }
                .popoverTip(shareTip, arrowEdge: .top)
            
            // 화살표가 아래를 가리킴 (팁이 위에 표시)
            Button("아래쪽 화살표") { }
                .popoverTip(shareTip, arrowEdge: .bottom)
            
            HStack(spacing: 100) {
                // 화살표가 왼쪽을 가리킴
                Button("←") { }
                    .popoverTip(shareTip, arrowEdge: .leading)
                
                // 화살표가 오른쪽을 가리킴
                Button("→") { }
                    .popoverTip(shareTip, arrowEdge: .trailing)
            }
        }
    }
}
