import SwiftUI
import MapKit

struct MapPolygonView: View {
    let zone1: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 37.5050, longitude: 127.0200),
        CLLocationCoordinate2D(latitude: 37.5050, longitude: 127.0350),
        CLLocationCoordinate2D(latitude: 37.4950, longitude: 127.0350),
        CLLocationCoordinate2D(latitude: 37.4950, longitude: 127.0200)
    ]
    
    let zone2: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 37.5050, longitude: 127.0350),
        CLLocationCoordinate2D(latitude: 37.5050, longitude: 127.0500),
        CLLocationCoordinate2D(latitude: 37.4950, longitude: 127.0500),
        CLLocationCoordinate2D(latitude: 37.4950, longitude: 127.0350)
    ]
    
    var body: some View {
        Map {
            // Zone 1: 무료 배달
            MapPolygon(coordinates: zone1)
                .foregroundStyle(.blue.opacity(0.2))
                .stroke(.blue, style: StrokeStyle(
                    lineWidth: 2,
                    dash: [5, 5]  // 점선
                ))
            
            // Zone 2: 유료 배달
            MapPolygon(coordinates: zone2)
                .foregroundStyle(.orange.opacity(0.2))
                .stroke(.orange, style: StrokeStyle(
                    lineWidth: 2,
                    dash: [10, 5]
                ))
        }
    }
}
