import SwiftUI

// MARK: - Expanded Trailing View
// 배달 상태 아이콘 + 시간

struct ExpandedTrailingView: View {
    let context: ActivityViewContext<DeliveryAttributes>
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            // 상태 아이콘
            Image(systemName: context.state.status.symbolName)
                .font(.title2)
                .foregroundStyle(context.state.status.color)
                .symbolEffect(.pulse, isActive: context.state.status == .nearby)
            
            // 예상 도착 시간
            Text(context.state.estimatedArrival, style: .time)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
