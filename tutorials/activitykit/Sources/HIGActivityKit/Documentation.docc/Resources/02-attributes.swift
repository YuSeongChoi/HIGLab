import ActivityKit
import Foundation

// MARK: - Delivery Activity Attributes
// Static 속성: Activity 생성 시 설정, 변경 불가

struct DeliveryAttributes: ActivityAttributes {
    // 주문 정보 (변경 불가)
    let orderNumber: String
    let storeName: String
    let storeImageURL: URL?
    let customerAddress: String
    
    // ContentState는 내부에 정의
    struct ContentState: Codable, Hashable {
        // 다음 파일에서 정의
    }
}
