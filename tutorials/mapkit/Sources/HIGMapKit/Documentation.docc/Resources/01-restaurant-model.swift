import Foundation
import MapKit

/// 맛집 정보를 담는 데이터 모델
struct Restaurant: Identifiable, Hashable {
    let id: UUID
    let name: String
    let coordinate: CLLocationCoordinate2D
    let category: Category
    let rating: Double
    let priceLevel: Int  // 1-4 ($ ~ $$$$)
    let imageURL: URL?
    
    /// 맛집 카테고리
    enum Category: String, CaseIterable {
        case korean = "한식"
        case japanese = "일식"
        case chinese = "중식"
        case western = "양식"
        case cafe = "카페"
        case bar = "술집"
    }
    
    // Hashable 구현 (CLLocationCoordinate2D는 Hashable이 아님)
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Restaurant, rhs: Restaurant) -> Bool {
        lhs.id == rhs.id
    }
}
