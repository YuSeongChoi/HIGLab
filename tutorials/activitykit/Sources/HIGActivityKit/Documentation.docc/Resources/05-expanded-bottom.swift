import SwiftUI

// MARK: - Expanded Bottom View
// 배달 진행 상태 바

struct ExpandedBottomView: View {
    let context: ActivityViewContext<DeliveryAttributes>
    
    var body: some View {
        VStack(spacing: 8) {
            // 진행 바
            DeliveryProgressBar(progress: context.state.progress)
            
            // 단계 라벨
            HStack {
                ForEach(DeliveryStatus.allCases, id: \.self) { status in
                    if status != .delivered {
                        Text(status.displayName)
                            .font(.caption2)
                            .foregroundStyle(
                                context.state.status.rawValue >= status.rawValue 
                                    ? .primary : .secondary
                            )
                        if status != .nearby {
                            Spacer()
                        }
                    }
                }
                Text("완료")
                    .font(.caption2)
                    .foregroundStyle(
                        context.state.status == .delivered ? .primary : .secondary
                    )
            }
        }
    }
}

struct DeliveryProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 배경
                Capsule()
                    .fill(.quaternary)
                
                // 진행
                Capsule()
                    .fill(.green)
                    .frame(width: geometry.size.width * progress)
                    .animation(.spring, value: progress)
            }
        }
        .frame(height: 6)
    }
}
