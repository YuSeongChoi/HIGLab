import Foundation
import MapKit

extension Restaurant {
    /// 테스트용 서울 맛집 샘플 데이터
    static let samples: [Restaurant] = [
        Restaurant(
            id: UUID(),
            name: "을지로 골뱅이",
            coordinate: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9910),
            category: .korean,
            rating: 4.5,
            priceLevel: 2,
            imageURL: nil
        ),
        Restaurant(
            id: UUID(),
            name: "스시 오마카세",
            coordinate: CLLocationCoordinate2D(latitude: 37.5172, longitude: 127.0473),
            category: .japanese,
            rating: 4.8,
            priceLevel: 4,
            imageURL: nil
        ),
        Restaurant(
            id: UUID(),
            name: "이태원 타코",
            coordinate: CLLocationCoordinate2D(latitude: 37.5345, longitude: 126.9945),
            category: .western,
            rating: 4.2,
            priceLevel: 2,
            imageURL: nil
        ),
        Restaurant(
            id: UUID(),
            name: "강남 딤섬",
            coordinate: CLLocationCoordinate2D(latitude: 37.4979, longitude: 127.0276),
            category: .chinese,
            rating: 4.4,
            priceLevel: 3,
            imageURL: nil
        ),
        Restaurant(
            id: UUID(),
            name: "성수 카페",
            coordinate: CLLocationCoordinate2D(latitude: 37.5447, longitude: 127.0557),
            category: .cafe,
            rating: 4.6,
            priceLevel: 2,
            imageURL: nil
        )
    ]
}
