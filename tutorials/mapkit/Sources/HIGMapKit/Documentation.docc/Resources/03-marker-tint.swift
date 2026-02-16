import SwiftUI
import MapKit

struct MarkerView: View {
    var body: some View {
        Map {
            // .tint로 마커 색상 변경
            Marker(
                "한식당",
                systemImage: "fork.knife",
                coordinate: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9910)
            )
            .tint(.red)  // 한식 - 빨강
            
            Marker(
                "일식당",
                systemImage: "fish.fill",
                coordinate: CLLocationCoordinate2D(latitude: 37.5172, longitude: 127.0473)
            )
            .tint(.orange)  // 일식 - 주황
            
            Marker(
                "카페",
                systemImage: "cup.and.saucer.fill",
                coordinate: CLLocationCoordinate2D(latitude: 37.5447, longitude: 127.0557)
            )
            .tint(.brown)  // 카페 - 갈색
        }
    }
}
