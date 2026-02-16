import SwiftUI
import MapKit

struct ContentView: View {
    let restaurants = Restaurant.samples
    @State private var selectedRestaurant: Restaurant?
    @State private var position: MapCameraPosition = .automatic
    
    var body: some View {
        Map(position: $position, selection: $selectedRestaurant) {
            ForEach(restaurants) { restaurant in
                Marker(
                    restaurant.name,
                    systemImage: restaurant.category.icon,
                    coordinate: restaurant.coordinate
                )
                .tint(restaurant.category.color)
                .tag(restaurant)
            }
        }
        // 선택 시 상세 시트 표시
        .sheet(item: $selectedRestaurant) { restaurant in
            RestaurantDetailSheet(restaurant: restaurant)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onChange(of: selectedRestaurant) { _, newValue in
            // 선택된 맛집으로 카메라 이동
            if let restaurant = newValue {
                withAnimation(.easeInOut) {
                    position = .camera(MapCamera(
                        centerCoordinate: restaurant.coordinate,
                        distance: 1000
                    ))
                }
            }
        }
    }
}

struct RestaurantDetailSheet: View {
    let restaurant: Restaurant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(restaurant.name)
                .font(.title)
                .fontWeight(.bold)
            
            HStack {
                Label(restaurant.category.rawValue, systemImage: restaurant.category.icon)
                Spacer()
                Label(String(format: "%.1f", restaurant.rating), systemImage: "star.fill")
                    .foregroundStyle(.yellow)
            }
            
            Divider()
            
            Text("상세 정보가 여기에 표시됩니다.")
                .foregroundStyle(.secondary)
            
            Spacer()
        }
        .padding()
    }
}
