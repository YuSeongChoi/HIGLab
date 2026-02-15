// Dynamic Island - Minimal 레이아웃
// 다른 Live Activity와 함께 표시될 때

struct MinimalView: View {
    let status: DeliveryStatus
    
    var body: some View {
        // 원형 영역 안에 핵심 아이콘만
        Image(systemName: status.symbolName)
            .font(.system(size: 12, weight: .semibold))
    }
}

extension DeliveryStatus {
    var symbolName: String {
        switch self {
        case .preparing: "bag"
        case .pickedUp:  "bicycle"
        case .nearby:    "location.fill"
        case .delivered: "checkmark.circle.fill"
        }
    }
}
