import SwiftUI
import MapKit

struct MapConfigView: View {
    // 서울 시청을 중심으로 고정
    @State private var position: MapCameraPosition = .camera(
        MapCamera(
            centerCoordinate: CLLocationCoordinate2D(
                latitude: 37.5666,   // 서울 시청 위도
                longitude: 126.9784  // 서울 시청 경도
            ),
            distance: 5000  // 카메라 거리 (미터)
        )
    )
    
    var body: some View {
        Map(position: $position) {
            Marker("서울시청", coordinate: CLLocationCoordinate2D(
                latitude: 37.5666,
                longitude: 126.9784
            ))
        }
    }
}
