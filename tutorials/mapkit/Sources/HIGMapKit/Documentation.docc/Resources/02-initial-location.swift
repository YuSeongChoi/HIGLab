import SwiftUI
import MapKit

struct ContentView: View {
    // 강남역 중심, 약 2km 반경
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 37.4979,
                longitude: 127.0276
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 0.02,
                longitudeDelta: 0.02
            )
        )
    )
    
    let restaurants = Restaurant.samples
    
    var body: some View {
        Map(position: $position) {
            ForEach(restaurants) { restaurant in
                Marker(restaurant.name, coordinate: restaurant.coordinate)
                    .tint(restaurant.category.color)
            }
        }
    }
}

extension Restaurant.Category {
    var color: Color {
        switch self {
        case .korean: return .red
        case .japanese: return .orange
        case .chinese: return .yellow
        case .western: return .green
        case .cafe: return .brown
        case .bar: return .purple
        }
    }
}
