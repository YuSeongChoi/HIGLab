import SwiftUI
import MapKit

struct MapCircleView: View {
    let restaurant = Restaurant.samples[0]
    
    var body: some View {
        Map {
            Marker(restaurant.name, coordinate: restaurant.coordinate)
            
            // 도보 10분 반경 (약 800m) - 외곽
            MapCircle(
                center: restaurant.coordinate,
                radius: 800
            )
            .foregroundStyle(.green.opacity(0.1))
            .stroke(.green, lineWidth: 1)
            
            // 도보 5분 반경 (약 400m) - 내부
            MapCircle(
                center: restaurant.coordinate,
                radius: 400
            )
            .foregroundStyle(.blue.opacity(0.2))
            .stroke(.blue, lineWidth: 2)
        }
    }
}

// 범례:
// 🔵 파란 영역: 도보 5분 이내
// 🟢 초록 영역: 도보 10분 이내
