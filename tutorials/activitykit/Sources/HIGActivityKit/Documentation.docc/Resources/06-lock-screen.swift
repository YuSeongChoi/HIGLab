import SwiftUI
import WidgetKit

// MARK: - Lock Screen Live Activity View

struct LockScreenView: View {
    let context: ActivityViewContext<DeliveryAttributes>
    
    var body: some View {
        VStack(spacing: 12) {
            // 상단: 가게 정보 + 도착 시간
            HStack {
                // 가게 아이콘
                Image(systemName: "storefront.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(context.attributes.storeName)
                        .font(.headline)
                    Text(context.state.statusMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // 도착 예정 시간
                VStack(alignment: .trailing) {
                    Text(context.state.estimatedArrival, style: .time)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("도착 예정")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // 진행 바
            DeliveryProgressBar(progress: context.state.progress)
            
            // 하단: 단계 표시
            HStack {
                ForEach(DeliveryStatus.allCases, id: \.self) { status in
                    StepIndicator(
                        status: status,
                        isActive: context.state.status == status,
                        isCompleted: context.state.progress >= stepProgress(for: status)
                    )
                    if status != .delivered {
                        Spacer()
                    }
                }
            }
        }
        .padding()
    }
    
    func stepProgress(for status: DeliveryStatus) -> Double {
        switch status {
        case .preparing: 0.2
        case .pickedUp:  0.5
        case .nearby:    0.8
        case .delivered: 1.0
        }
    }
}

struct StepIndicator: View {
    let status: DeliveryStatus
    let isActive: Bool
    let isCompleted: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: status.symbolName)
                .font(.caption)
                .foregroundStyle(isCompleted ? status.color : .secondary)
                .symbolEffect(.bounce, value: isActive)
            
            Text(status.displayName)
                .font(.caption2)
                .foregroundStyle(isActive ? .primary : .secondary)
        }
    }
}
