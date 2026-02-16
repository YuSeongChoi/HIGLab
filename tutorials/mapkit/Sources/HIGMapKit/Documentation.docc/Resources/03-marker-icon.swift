import SwiftUI
import MapKit

struct MarkerView: View {
    var body: some View {
        Map {
            // SF Symbol 아이콘 사용
            Marker(
                "한식당",
                systemImage: "fork.knife",  // 음식 아이콘
                coordinate: CLLocationCoordinate2D(
                    latitude: 37.5665,
                    longitude: 126.9910
                )
            )
            
            Marker(
                "카페",
                systemImage: "cup.and.saucer.fill",  // 카페 아이콘
                coordinate: CLLocationCoordinate2D(
                    latitude: 37.5545,
                    longitude: 126.9706
                )
            )
            
            Marker(
                "술집",
                systemImage: "wineglass.fill",  // 와인잔 아이콘
                coordinate: CLLocationCoordinate2D(
                    latitude: 37.5345,
                    longitude: 126.9945
                )
            )
        }
    }
}
