import SwiftUI
import MapKit

struct MapConfigView: View {
    @State private var distance: Double = 5000
    
    var position: MapCameraPosition {
        .camera(MapCamera(
            centerCoordinate: .gangnam,
            distance: distance  // 미터 단위
        ))
    }
    
    var body: some View {
        VStack {
            Map(position: .constant(position)) {
                Marker("강남역", coordinate: .gangnam)
            }
            
            VStack {
                Text("카메라 거리: \(Int(distance))m")
                Slider(value: $distance, in: 500...50000)
            }
            .padding()
        }
    }
}

// distance 가이드:
// 500m   → 건물 수준 확대
// 2000m  → 동네 수준
// 10000m → 구/군 수준
// 50000m → 도시 전체
