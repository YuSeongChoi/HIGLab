import SwiftUI
import MapKit

struct MapConfigView: View {
    // MKCoordinateRegion으로 영역 지정
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 37.4979,  // 강남역
                longitude: 127.0276
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 0.02,   // 위도 범위 (약 2km)
                longitudeDelta: 0.02   // 경도 범위
            )
        )
    )
    
    var body: some View {
        Map(position: $position) {
            // 콘텐츠
        }
    }
}

// span 값 가이드:
// 0.001 → 약 100m (매우 확대)
// 0.01  → 약 1km (동네 수준)
// 0.1   → 약 10km (구/군 수준)
// 1.0   → 약 100km (도시 수준)
