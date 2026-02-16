import SwiftUI
import MapKit

struct MapCircleView: View {
    let restaurant = Restaurant.samples[0]
    
    var body: some View {
        Map {
            Marker(restaurant.name, coordinate: restaurant.coordinate)
            
            // 스타일이 적용된 원
            MapCircle(
                center: restaurant.coordinate,
                radius: 500
            )
            .foregroundStyle(.blue.opacity(0.2))  // 반투명 채우기
            .stroke(.blue, lineWidth: 2)           // 테두리
        }
    }
}
