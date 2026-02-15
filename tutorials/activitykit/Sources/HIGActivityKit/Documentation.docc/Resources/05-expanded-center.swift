import SwiftUI

// MARK: - Expanded Center View
// 가게명과 상태 메시지

struct ExpandedCenterView: View {
    let context: ActivityViewContext<DeliveryAttributes>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // 가게명
            Text(context.attributes.storeName)
                .font(.headline)
                .lineLimit(1)
            
            // 상태 메시지
            Text(context.state.statusMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            
            // 배달원 이름 (있으면)
            if let driverName = context.state.driverName,
               context.state.status == .pickedUp || context.state.status == .nearby {
                Text("\(driverName)님이 배달 중")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
