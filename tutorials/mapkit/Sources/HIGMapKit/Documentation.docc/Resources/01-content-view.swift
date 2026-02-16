import SwiftUI
import MapKit

struct ContentView: View {
    @State private var selectedRestaurant: Restaurant?
    @State private var showingDetail = false
    
    let restaurants = Restaurant.samples
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 지도
            Map {
                ForEach(restaurants) { restaurant in
                    Marker(
                        restaurant.name,
                        coordinate: restaurant.coordinate
                    )
                }
            }
            
            // 하단 맛집 목록 시트
            RestaurantListSheet(
                restaurants: restaurants,
                selectedRestaurant: $selectedRestaurant
            )
        }
        .sheet(item: $selectedRestaurant) { restaurant in
            RestaurantDetailView(restaurant: restaurant)
        }
    }
}

// 하단 시트 컴포넌트 (별도 파일로 분리 가능)
struct RestaurantListSheet: View {
    let restaurants: [Restaurant]
    @Binding var selectedRestaurant: Restaurant?
    
    var body: some View {
        VStack {
            Text("주변 맛집 \(restaurants.count)곳")
                .font(.headline)
            // ... 목록 구현
        }
        .frame(height: 200)
        .background(.ultraThinMaterial)
    }
}

struct RestaurantDetailView: View {
    let restaurant: Restaurant
    
    var body: some View {
        Text(restaurant.name)
    }
}
