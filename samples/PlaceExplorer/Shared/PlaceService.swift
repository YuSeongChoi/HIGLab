import Foundation
import MapKit

// MARK: - 장소 검색 서비스

/// MKLocalSearch를 사용한 주변 장소 검색 서비스
@MainActor
final class PlaceService {
    
    // MARK: - Singleton
    
    static let shared = PlaceService()
    private init() {}
    
    // MARK: - Public Methods
    
    /// 카테고리별 주변 장소 검색
    /// - Parameters:
    ///   - category: 검색할 장소 카테고리
    ///   - coordinate: 검색 중심 좌표
    ///   - radius: 검색 반경 (미터, 기본 1km)
    /// - Returns: 검색된 장소 배열
    func searchPlaces(
        category: PlaceCategory,
        near coordinate: CLLocationCoordinate2D,
        radius: CLLocationDistance = 1000
    ) async throws -> [Place] {
        
        // 검색 요청 생성
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = category.searchQuery
        
        // 검색 영역 설정
        request.region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: radius * 2,
            longitudinalMeters: radius * 2
        )
        
        // iOS 17+ 결과 타입 필터
        request.resultTypes = .pointOfInterest
        
        // 검색 실행
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        
        // MKMapItem -> Place 변환
        return response.mapItems.compactMap { item -> Place? in
            guard let name = item.name else { return nil }
            
            return Place(
                name: name,
                coordinate: item.placemark.coordinate,
                category: category,
                rating: generateMockRating(), // 실제 앱에서는 별도 API 필요
                address: formatAddress(from: item.placemark),
                phoneNumber: item.phoneNumber
            )
        }
    }
    
    /// 키워드로 장소 검색
    /// - Parameters:
    ///   - query: 검색어
    ///   - coordinate: 검색 중심 좌표
    ///   - radius: 검색 반경 (미터)
    /// - Returns: 검색된 장소 배열
    func searchPlaces(
        query: String,
        near coordinate: CLLocationCoordinate2D,
        radius: CLLocationDistance = 2000
    ) async throws -> [Place] {
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: radius * 2,
            longitudinalMeters: radius * 2
        )
        
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        
        return response.mapItems.compactMap { item -> Place? in
            guard let name = item.name else { return nil }
            
            // 검색어 기반 카테고리 추론
            let category = inferCategory(from: item)
            
            return Place(
                name: name,
                coordinate: item.placemark.coordinate,
                category: category,
                rating: generateMockRating(),
                address: formatAddress(from: item.placemark),
                phoneNumber: item.phoneNumber
            )
        }
    }
    
    /// 장소에 대한 경로 계산
    /// - Parameters:
    ///   - destination: 목적지 좌표
    ///   - origin: 출발지 좌표
    ///   - transportType: 이동 수단
    /// - Returns: 계산된 경로 (MKRoute)
    func calculateRoute(
        to destination: CLLocationCoordinate2D,
        from origin: CLLocationCoordinate2D,
        transportType: MKDirectionsTransportType = .walking
    ) async throws -> MKRoute? {
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: origin))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = transportType
        
        let directions = MKDirections(request: request)
        let response = try await directions.calculate()
        
        return response.routes.first
    }
    
    // MARK: - Private Helpers
    
    /// 주소 포맷팅
    private func formatAddress(from placemark: MKPlacemark) -> String? {
        var components: [String] = []
        
        if let locality = placemark.locality {
            components.append(locality)
        }
        if let subLocality = placemark.subLocality {
            components.append(subLocality)
        }
        if let thoroughfare = placemark.thoroughfare {
            components.append(thoroughfare)
        }
        if let subThoroughfare = placemark.subThoroughfare {
            components.append(subThoroughfare)
        }
        
        return components.isEmpty ? nil : components.joined(separator: " ")
    }
    
    /// MKMapItem에서 카테고리 추론
    private func inferCategory(from item: MKMapItem) -> PlaceCategory {
        // MKPointOfInterestCategory 기반 매핑
        if let poiCategory = item.pointOfInterestCategory {
            switch poiCategory {
            case .restaurant, .foodMarket:
                return .restaurant
            case .cafe:
                return .cafe
            case .hospital, .clinic:
                return .hospital
            case .pharmacy:
                return .pharmacy
            case .gasStation, .evCharger:
                return .gasStation
            case .parking:
                return .parking
            case .store, .convenienceStore:
                return .convenience
            case .bank, .atm:
                return .bank
            default:
                break
            }
        }
        
        // 기본값
        return .restaurant
    }
    
    /// 목업 평점 생성 (실제 앱에서는 별도 API 사용)
    private func generateMockRating() -> Double {
        Double.random(in: 3.0...5.0).rounded(toPlaces: 1)
    }
}

// MARK: - Double Extension

private extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
