import SwiftUI
import MapKit

struct MapConfigView: View {
    @State private var heading: Double = 0
    
    var position: MapCameraPosition {
        .camera(MapCamera(
            centerCoordinate: .gangnam,
            distance: 2000,
            heading: heading,  // 0° ~ 360°
            pitch: 45
        ))
    }
    
    var body: some View {
        VStack {
            Map(position: .constant(position)) {
                Marker("강남역", coordinate: .gangnam)
            }
            .mapStyle(.standard(elevation: .realistic))
            
            VStack {
                Text("카메라 헤딩: \(Int(heading))°")
                Slider(value: $heading, in: 0...360)
                
                HStack {
                    Button("북") { heading = 0 }
                    Button("동") { heading = 90 }
                    Button("남") { heading = 180 }
                    Button("서") { heading = 270 }
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
    }
}
