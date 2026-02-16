import SwiftUI
import MapKit

struct MapPolylineView: View {
    // 현재 위치 → 맛집까지 경로 좌표
    let routeCoordinates: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 37.4979, longitude: 127.0276),  // 출발
        CLLocationCoordinate2D(latitude: 37.4990, longitude: 127.0280),
        CLLocationCoordinate2D(latitude: 37.5000, longitude: 127.0300),
        CLLocationCoordinate2D(latitude: 37.5010, longitude: 127.0320),  // 도착
    ]
    
    var body: some View {
        Map {
            // 출발 마커
            Marker("현재 위치", systemImage: "figure.walk", coordinate: routeCoordinates.first!)
                .tint(.blue)
            
            // 도착 마커
            Marker("맛집", systemImage: "fork.knife", coordinate: routeCoordinates.last!)
                .tint(.red)
            
            // 경로 선
            MapPolyline(coordinates: routeCoordinates)
                .stroke(.blue, lineWidth: 4)
        }
    }
}
