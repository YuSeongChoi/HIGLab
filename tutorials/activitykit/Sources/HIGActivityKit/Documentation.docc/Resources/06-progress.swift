import SwiftUI

// MARK: - Delivery Progress Components

struct DeliveryProgressView: View {
    let currentStatus: DeliveryStatus
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(DeliveryStatus.allCases.enumerated()), id: \.element) { index, status in
                // 단계 원
                Circle()
                    .fill(isCompleted(status) ? status.color : Color.secondary.opacity(0.3))
                    .frame(width: 24, height: 24)
                    .overlay {
                        if isCompleted(status) {
                            Image(systemName: "checkmark")
                                .font(.caption2.bold())
                                .foregroundStyle(.white)
                        } else {
                            Text("\(index + 1)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                
                // 연결선 (마지막 제외)
                if status != .delivered {
                    Rectangle()
                        .fill(isCompleted(status) ? status.color : Color.secondary.opacity(0.3))
                        .frame(height: 2)
                }
            }
        }
    }
    
    func isCompleted(_ status: DeliveryStatus) -> Bool {
        let allCases = DeliveryStatus.allCases
        guard let currentIndex = allCases.firstIndex(of: currentStatus),
              let statusIndex = allCases.firstIndex(of: status) else {
            return false
        }
        return statusIndex <= currentIndex
    }
}
