import SwiftUI
import MapKit

struct ContentView: View {
    @State private var position: MapCameraPosition = .automatic
    @State private var selectedRestaurant: Restaurant?
    
    let restaurants = Restaurant.samples
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(position: $position) {
                ForEach(restaurants) { restaurant in
                    Marker(restaurant.name, coordinate: restaurant.coordinate)
                }
            }
            
            // 특정 맛집으로 이동 버튼
            VStack {
                ForEach(restaurants.prefix(3)) { restaurant in
                    Button(restaurant.name) {
                        moveToRestaurant(restaurant)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
    }
    
    private func moveToRestaurant(_ restaurant: Restaurant) {
        // 애니메이션과 함께 부드럽게 이동
        withAnimation(.easeInOut(duration: 0.8)) {
            position = .camera(MapCamera(
                centerCoordinate: restaurant.coordinate,
                distance: 500,  // 가까이 확대
                pitch: 60       // 3D 효과
            ))
        }
    }
}
