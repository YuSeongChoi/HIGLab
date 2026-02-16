import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var nearbyRestaurants: [Restaurant] = []
    @State private var position: MapCameraPosition = .automatic
    
    private let searchService = SearchService()
    
    var body: some View {
        Map(position: $position) {
            UserAnnotation()
            
            ForEach(nearbyRestaurants) { restaurant in
                Marker(restaurant.name, coordinate: restaurant.coordinate)
                    .tint(restaurant.category.color)
            }
        }
        .onChange(of: locationManager.location) { _, newLocation in
            // 위치 변경 시 주변 맛집 검색
            if let location = newLocation {
                searchNearbyRestaurants(around: location.coordinate)
            }
        }
        .onAppear {
            locationManager.requestAuthorization()
        }
    }
    
    /// 현재 위치 주변 500m 내 맛집 검색
    private func searchNearbyRestaurants(around coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 1000,   // 500m 반경
            longitudinalMeters: 1000
        )
        
        Task {
            do {
                let items = try await searchService.searchFoodPlaces(region: region)
                nearbyRestaurants = searchService.convertToRestaurants(items)
                print("주변 맛집 \(nearbyRestaurants.count)개 발견")
            } catch {
                print("검색 오류: \(error)")
            }
        }
    }
}
