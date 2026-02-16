import SwiftUI
import MapKit

struct MarkerView: View {
    var body: some View {
        Map {
            // 기본 Marker - 빨간색 핀
            Marker(
                "을지로 골뱅이",
                coordinate: CLLocationCoordinate2D(
                    latitude: 37.5665,
                    longitude: 126.9910
                )
            )
        }
    }
}

#Preview {
    MarkerView()
}
