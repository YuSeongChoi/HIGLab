import SwiftUI
import MapKit

struct ContentView: View {
    @State private var position: MapCameraPosition = .automatic
    @State private var selectedRestaurant: Restaurant?
    @State private var showingSearch = false
    
    let restaurants = Restaurant.samples
    
    var body: some View {
        ZStack {
            Map(position: $position, selection: $selectedRestaurant) {
                ForEach(restaurants) { restaurant in
                    Marker(restaurant.name, coordinate: restaurant.coordinate)
                        .tint(restaurant.category.color)
                        .tag(restaurant)
                }
                
                // 검색에서 선택한 맛집 강조
                if let selected = selectedRestaurant,
                   !restaurants.contains(selected) {
                    Marker(selected.name, systemImage: "star.fill", coordinate: selected.coordinate)
                        .tint(.yellow)
                        .tag(selected)
                }
            }
            
            // 검색 버튼
            VStack {
                HStack {
                    Spacer()
                    Button {
                        showingSearch = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $showingSearch) {
            SearchView(selectedRestaurant: $selectedRestaurant)
        }
        .onChange(of: selectedRestaurant) { _, newValue in
            // 선택된 맛집으로 이동
            if let restaurant = newValue {
                withAnimation {
                    position = .camera(MapCamera(
                        centerCoordinate: restaurant.coordinate,
                        distance: 1000
                    ))
                }
            }
        }
    }
}
