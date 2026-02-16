import SwiftUI
import MapKit

struct MapConfigView: View {
    @State private var pitch: Double = 0
    
    var position: MapCameraPosition {
        .camera(MapCamera(
            centerCoordinate: .gangnam,
            distance: 1000,
            heading: 0,
            pitch: pitch  // 0° ~ 85°
        ))
    }
    
    var body: some View {
        VStack {
            Map(position: .constant(position)) {
                Marker("강남역", coordinate: .gangnam)
            }
            .mapStyle(.standard(elevation: .realistic))  // 3D 건물 표시
            
            VStack {
                Text("카메라 피치: \(Int(pitch))°")
                Slider(value: $pitch, in: 0...85)
            }
            .padding()
        }
    }
}

// pitch 가이드:
// 0°  → 수직 탑다운 뷰
// 45° → 적당한 3D 효과
// 85° → 거의 수평 (지평선 보임)
