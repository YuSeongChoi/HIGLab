import SwiftUI

enum DeliveryStatus: String, Codable, CaseIterable {
    case preparing
    case pickedUp
    case nearby
    case delivered

    var displayName: String {
        switch self {
        case .preparing: "준비 중"
        case .pickedUp: "픽업 완료"
        case .nearby: "거의 도착"
        case .delivered: "배달 완료"
        }
    }
}
