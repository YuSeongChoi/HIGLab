import SwiftUI
import MapKit

struct MapPolygonView: View {
    // 배달 가능 구역 좌표 (강남 일부)
    let deliveryZone: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 37.5050, longitude: 127.0200),
        CLLocationCoordinate2D(latitude: 37.5050, longitude: 127.0400),
        CLLocationCoordinate2D(latitude: 37.4900, longitude: 127.0400),
        CLLocationCoordinate2D(latitude: 37.4900, longitude: 127.0200)
    ]
    
    var body: some View {
        Map {
            // 배달 가능 구역 다각형
            MapPolygon(coordinates: deliveryZone)
                .foregroundStyle(.green.opacity(0.3))
                .stroke(.green, lineWidth: 2)
        }
    }
}
