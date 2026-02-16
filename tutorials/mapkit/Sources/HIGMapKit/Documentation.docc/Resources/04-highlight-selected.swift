import SwiftUI
import MapKit

struct ContentView: View {
    let restaurants = Restaurant.samples
    @State private var selectedRestaurant: Restaurant?
    
    var body: some View {
        Map(selection: $selectedRestaurant) {
            ForEach(restaurants) { restaurant in
                let isSelected = selectedRestaurant == restaurant
                
                // 선택된 맛집 주변 반경 표시
                if isSelected {
                    MapCircle(
                        center: restaurant.coordinate,
                        radius: 300
                    )
                    .foregroundStyle(.blue.opacity(0.15))
                    .stroke(.blue, lineWidth: 2)
                }
                
                // 마커 (선택 안 된 것은 투명도 낮춤)
                Marker(
                    restaurant.name,
                    coordinate: restaurant.coordinate
                )
                .tint(isSelected ? .blue : restaurant.category.color.opacity(0.5))
                .tag(restaurant)
            }
        }
    }
}
