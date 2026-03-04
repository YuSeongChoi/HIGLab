import ActivityKit
import Foundation

// 이 파일은 앱/위젯이 함께 사용하는 Delivery Live Activity의 Attributes/ContentState 모델입니다.
struct DeliveryAttributes: ActivityAttributes {
    let orderNumber: String
    let storeName: String
    let storeImageURL: URL?
    let customerAddress: String

    struct ContentState: Codable, Hashable {
        let status: DeliveryStatus
        let orderTime: Date
        let estimatedArrival: Date
        let driverName: String?
        let driverImageURL: URL?

        var progress: Double {
            switch status {
            case .preparing: 0.2
            case .pickedUp:  0.5
            case .nearby:    0.8
            case .delivered: 1.0
            }
        }

        var statusMessage: String {
            switch status {
            case .preparing: "음식을 준비 중이에요"
            case .pickedUp:  "\(driverName ?? "배달원")님이 픽업했어요"
            case .nearby:    "거의 다 왔어요!"
            case .delivered: "배달 완료!"
            }
        }
    }
}
