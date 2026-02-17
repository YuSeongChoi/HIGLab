import SwiftUI
import WidgetKit

struct AnimatedDeliveryStatus: View {
    let status: DeliveryStatus
    
    var body: some View {
        HStack(spacing: 8) {
            // 상태 아이콘 - 변경 시 애니메이션
            Image(systemName: status.icon)
                .font(.title3)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(status.color)
                // 아이콘 변경 시 부드러운 전환
                .contentTransition(.symbolEffect(.replace))
            
            // 상태 텍스트
            Text(status.title)
                .font(.headline)
                // 텍스트 변경 시 전환 효과
                .contentTransition(.interpolate)
        }
        // 전체 레이아웃 애니메이션
        .animation(.smooth, value: status)
    }
}

enum DeliveryStatus: String, Equatable {
    case preparing
    case picked
    case delivering
    case arrived
    
    var icon: String {
        switch self {
        case .preparing: return "takeoutbag.and.cup.and.straw"
        case .picked: return "bag.fill"
        case .delivering: return "bicycle"
        case .arrived: return "checkmark.circle.fill"
        }
    }
    
    var title: String {
        switch self {
        case .preparing: return "준비 중"
        case .picked: return "픽업 완료"
        case .delivering: return "배달 중"
        case .arrived: return "도착 완료"
        }
    }
    
    var color: Color {
        switch self {
        case .preparing: return .orange
        case .picked: return .blue
        case .delivering: return .green
        case .arrived: return .purple
        }
    }
}
