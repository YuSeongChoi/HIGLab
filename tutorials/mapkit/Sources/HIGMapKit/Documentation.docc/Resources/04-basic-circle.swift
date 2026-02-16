import SwiftUI
import MapKit

struct MapCircleView: View {
    let restaurant = Restaurant.samples[0]
    
    var body: some View {
        Map {
            // 맛집 마커
            Marker(restaurant.name, coordinate: restaurant.coordinate)
            
            // 도보 5분 반경 (약 400m)
            MapCircle(
                center: restaurant.coordinate,
                radius: 400  // 미터 단위
            )
        }
    }
}
