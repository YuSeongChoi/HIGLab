import SwiftUI
import MapKit

struct ContentView: View {
    let restaurants = Restaurant.samples
    @State private var position: MapCameraPosition = .automatic
    @State private var isZoomedIn = false
    
    var body: some View {
        Map(position: $position) {
            ForEach(restaurants) { restaurant in
                if isZoomedIn {
                    // 확대 시: 상세 Annotation
                    Annotation(
                        restaurant.name,
                        coordinate: restaurant.coordinate,
                        anchor: .bottom
                    ) {
                        RestaurantAnnotationView(restaurant: restaurant)
                    }
                } else {
                    // 축소 시: 간단한 Marker
                    Marker(
                        restaurant.name,
                        systemImage: restaurant.category.icon,
                        coordinate: restaurant.coordinate
                    )
                    .tint(restaurant.category.color)
                }
            }
        }
        .onMapCameraChange { context in
            // 줌 레벨 감지
            let span = context.region.span.latitudeDelta
            withAnimation(.easeInOut(duration: 0.2)) {
                isZoomedIn = span < 0.01  // 약 1km 이하로 확대 시
            }
        }
    }
}
