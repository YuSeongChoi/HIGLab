import Foundation
import MapKit

// MARK: - 장소 모델

/// 지도에 표시할 장소 정보
struct Place: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let category: PlaceCategory
    let rating: Double?
    let address: String?
    let phoneNumber: String?
    
    // MARK: - Hashable 구현
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Place, rhs: Place) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - 장소 카테고리

enum PlaceCategory: String, CaseIterable, Identifiable {
    case restaurant = "음식점"
    case cafe = "카페"
    case hospital = "병원"
    case pharmacy = "약국"
    case gasStation = "주유소"
    case parking = "주차장"
    case convenience = "편의점"
    case bank = "은행"
    
    var id: String { rawValue }
    
    /// SF Symbols 아이콘 이름
    var symbol: String {
        switch self {
        case .restaurant: "fork.knife"
        case .cafe: "cup.and.saucer.fill"
        case .hospital: "cross.fill"
        case .pharmacy: "pills.fill"
        case .gasStation: "fuelpump.fill"
        case .parking: "p.square.fill"
        case .convenience: "basket.fill"
        case .bank: "building.columns.fill"
        }
    }
    
    /// 카테고리 대표 색상
    var color: String {
        switch self {
        case .restaurant: "orange"
        case .cafe: "brown"
        case .hospital: "red"
        case .pharmacy: "green"
        case .gasStation: "blue"
        case .parking: "indigo"
        case .convenience: "teal"
        case .bank: "purple"
        }
    }
    
    /// MKLocalSearch 용 쿼리 키워드
    var searchQuery: String {
        switch self {
        case .restaurant: "restaurant"
        case .cafe: "cafe"
        case .hospital: "hospital"
        case .pharmacy: "pharmacy"
        case .gasStation: "gas station"
        case .parking: "parking"
        case .convenience: "convenience store"
        case .bank: "bank"
        }
    }
}

// MARK: - Preview / Mock Data

extension Place {
    /// 서울 시청 근처 샘플 장소들
    static let previews: [Place] = [
        Place(
            name: "광화문 맛집",
            coordinate: CLLocationCoordinate2D(latitude: 37.5759, longitude: 126.9769),
            category: .restaurant,
            rating: 4.5,
            address: "서울 종로구 세종대로 172",
            phoneNumber: "02-1234-5678"
        ),
        Place(
            name: "덕수궁 카페",
            coordinate: CLLocationCoordinate2D(latitude: 37.5658, longitude: 126.9750),
            category: .cafe,
            rating: 4.2,
            address: "서울 중구 세종대로 99",
            phoneNumber: "02-2345-6789"
        ),
        Place(
            name: "서울역 약국",
            coordinate: CLLocationCoordinate2D(latitude: 37.5547, longitude: 126.9707),
            category: .pharmacy,
            rating: 4.0,
            address: "서울 용산구 한강대로 405",
            phoneNumber: "02-3456-7890"
        ),
        Place(
            name: "명동 편의점",
            coordinate: CLLocationCoordinate2D(latitude: 37.5636, longitude: 126.9850),
            category: .convenience,
            rating: 3.8,
            address: "서울 중구 명동길 14",
            phoneNumber: nil
        ),
    ]
    
    static let preview = previews[0]
}
