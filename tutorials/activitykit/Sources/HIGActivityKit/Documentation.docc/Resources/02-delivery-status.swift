import Foundation

// MARK: - 배달 상태 Enum

enum DeliveryStatus: String, Codable, CaseIterable {
    case preparing  // 준비 중
    case pickedUp   // 픽업 완료
    case nearby     // 근처 도착
    case delivered  // 배달 완료
    
    var displayName: String {
        switch self {
        case .preparing: "준비 중"
        case .pickedUp:  "배달 중"
        case .nearby:    "거의 도착"
        case .delivered: "완료"
        }
    }
    
    var symbolName: String {
        switch self {
        case .preparing: "bag.fill"
        case .pickedUp:  "bicycle"
        case .nearby:    "location.fill"
        case .delivered: "checkmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .preparing: .orange
        case .pickedUp:  .blue
        case .nearby:    .green
        case .delivered: .green
        }
    }
}
