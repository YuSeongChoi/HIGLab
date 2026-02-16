import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    let restaurants = Restaurant.samples
    
    var body: some View {
        Map {
            // 사용자 위치 표시 (파란 점)
            UserAnnotation()
            
            // 맛집 마커
            ForEach(restaurants) { restaurant in
                Marker(restaurant.name, coordinate: restaurant.coordinate)
                    .tint(restaurant.category.color)
            }
        }
        .mapControls {
            // 내 위치 버튼 (기본 제공)
            MapUserLocationButton()
            
            // 나침반
            MapCompass()
            
            // 축척
            MapScaleView()
        }
        .onAppear {
            locationManager.requestAuthorization()
        }
    }
}

// UserAnnotation 커스터마이징:
// - 기본 파란 점 + 정확도 원이 표시됨
// - 위치 권한이 없으면 표시되지 않음
