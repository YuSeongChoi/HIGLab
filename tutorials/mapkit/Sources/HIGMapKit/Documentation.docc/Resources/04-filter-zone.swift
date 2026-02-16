import SwiftUI
import MapKit

struct ContentView: View {
    let restaurants = Restaurant.samples
    @State private var showWalkingRadius = false
    @State private var userLocation = CLLocationCoordinate2D(latitude: 37.4979, longitude: 127.0276)
    
    var body: some View {
        VStack {
            Map {
                // 사용자 위치
                Marker("내 위치", systemImage: "location.fill", coordinate: userLocation)
                    .tint(.blue)
                
                // 도보 10분 반경 필터 ON일 때만 표시
                if showWalkingRadius {
                    MapCircle(center: userLocation, radius: 800)
                        .foregroundStyle(.blue.opacity(0.1))
                        .stroke(.blue.opacity(0.5), lineWidth: 1)
                }
                
                // 맛집 마커
                ForEach(restaurants) { restaurant in
                    Marker(restaurant.name, coordinate: restaurant.coordinate)
                        .tint(restaurant.category.color)
                }
            }
            
            // 필터 토글
            Toggle("도보 10분 이내만 보기", isOn: $showWalkingRadius)
                .padding()
        }
    }
}
