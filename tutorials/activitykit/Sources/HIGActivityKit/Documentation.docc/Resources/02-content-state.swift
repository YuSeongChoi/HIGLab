import ActivityKit
import Foundation

struct DeliveryAttributes: ActivityAttributes {
    let orderNumber: String
    let storeName: String
    let storeImageURL: URL?
    let customerAddress: String
    
    // MARK: - Content State
    // 실시간으로 업데이트되는 상태
    
    struct ContentState: Codable, Hashable {
        // 현재 배달 상태
        let status: DeliveryStatus
        
        // 예상 도착 시간
        let estimatedArrival: Date
        
        // 배달원 정보
        let driverName: String?
        let driverImageURL: URL?
        
        // 진행률 (0.0 ~ 1.0)
        var progress: Double {
            switch status {
            case .preparing: 0.2
            case .pickedUp:  0.5
            case .nearby:    0.8
            case .delivered: 1.0
            }
        }
        
        // 상태 메시지
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
