import MapKit

extension SearchService {
    /// MKMapItem을 Restaurant 모델로 변환
    func convertToRestaurants(_ mapItems: [MKMapItem]) -> [Restaurant] {
        mapItems.compactMap { item -> Restaurant? in
            guard let name = item.name,
                  let location = item.placemark.location else {
                return nil
            }
            
            return Restaurant(
                id: UUID(),
                name: name,
                coordinate: location.coordinate,
                category: categorize(item),
                rating: 0.0,  // API에서 평점은 제공되지 않음
                priceLevel: 2,
                imageURL: item.url
            )
        }
    }
    
    /// POI 카테고리 추론
    private func categorize(_ item: MKMapItem) -> Restaurant.Category {
        guard let category = item.pointOfInterestCategory else {
            return .korean
        }
        
        switch category {
        case .cafe:
            return .cafe
        case .bakery:
            return .cafe
        case .brewery, .winery, .nightlife:
            return .bar
        case .restaurant:
            return .korean  // 기본값
        default:
            return .korean
        }
    }
}

// MKMapItem 주요 프로퍼티:
// - name: String? (장소명)
// - placemark.location: CLLocation? (위치)
// - phoneNumber: String? (전화번호)
// - url: URL? (웹사이트)
// - pointOfInterestCategory: MKPointOfInterestCategory? (카테고리)
