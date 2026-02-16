import SwiftUI
import TipKit

struct FeatureTip: Tip {
    var title: Text { Text("새 기능") }
    var message: Text? { Text("이 기능을 사용해보세요") }
}

struct DynamicPopoverView: View {
    let featureTip = FeatureTip()
    @State private var featureUsed = false
    
    var body: some View {
        VStack(spacing: 20) {
            Button("기능 사용") {
                featureUsed = true
                
                // 사용자가 기능을 사용했으므로 팁 무효화
                featureTip.invalidate(reason: .actionPerformed)
            }
            .popoverTip(featureTip)
            
            // 팁 상태 표시
            Text("팁 상태: \(tipStatusText)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    var tipStatusText: String {
        switch featureTip.status {
        case .available:
            return "표시 가능"
        case .invalidated(let reason):
            return "무효화됨 (\(reason))"
        case .pending:
            return "대기 중"
        }
    }
}
