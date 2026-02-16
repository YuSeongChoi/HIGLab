import SwiftUI
import TipKit

struct StatusDemoTip: Tip {
    var title: Text { Text("상태 데모") }
}

struct TipStatusView: View {
    let tip = StatusDemoTip()
    
    var body: some View {
        VStack(spacing: 20) {
            TipView(tip)
            
            // 팁 상태 확인
            Text("현재 상태: \(statusDescription)")
                .font(.headline)
            
            Text(statusExplanation)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
    
    var statusDescription: String {
        switch tip.status {
        case .available:
            return "✅ available"
        case .invalidated(let reason):
            return "❌ invalidated (\(reason))"
        case .pending:
            return "⏳ pending"
        }
    }
    
    var statusExplanation: String {
        switch tip.status {
        case .available:
            return "팁이 표시될 준비가 됨"
        case .invalidated(let reason):
            switch reason {
            case .actionPerformed:
                return "사용자가 해당 기능을 사용함"
            case .tipClosed:
                return "사용자가 팁을 닫음"
            default:
                return "알 수 없는 이유로 무효화됨"
            }
        case .pending:
            return "규칙 조건이 충족되지 않아 대기 중"
        }
    }
}
