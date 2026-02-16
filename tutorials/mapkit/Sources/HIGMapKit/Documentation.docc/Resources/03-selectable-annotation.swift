import SwiftUI
import MapKit

struct AnnotationView: View {
    let restaurants = Restaurant.samples
    @State private var selectedRestaurant: Restaurant?
    
    var body: some View {
        Map(selection: $selectedRestaurant) {  // selection 바인딩
            ForEach(restaurants) { restaurant in
                Annotation(
                    restaurant.name,
                    coordinate: restaurant.coordinate
                ) {
                    // 선택 상태에 따른 스타일 변화
                    RestaurantPinView(
                        restaurant: restaurant,
                        isSelected: selectedRestaurant == restaurant
                    )
                }
                .tag(restaurant)  // selection과 매칭되는 tag
            }
        }
        .onChange(of: selectedRestaurant) { oldValue, newValue in
            if let restaurant = newValue {
                print("선택됨: \(restaurant.name)")
            }
        }
    }
}

struct RestaurantPinView: View {
    let restaurant: Restaurant
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? .blue : restaurant.category.color)
                .frame(width: isSelected ? 50 : 36, height: isSelected ? 50 : 36)
            
            Image(systemName: restaurant.category.icon)
                .foregroundStyle(.white)
                .font(isSelected ? .title3 : .body)
        }
        .animation(.spring(duration: 0.3), value: isSelected)
    }
}
