import SwiftUI
import MapKit

struct RouteMapView: View {
    let route: MKRoute?
    let source: CLLocationCoordinate2D
    let destination: CLLocationCoordinate2D
    
    var body: some View {
        Map {
            // 출발지 마커
            Marker("출발", systemImage: "figure.walk", coordinate: source)
                .tint(.green)
            
            // 도착지 마커
            Marker("도착", systemImage: "mappin", coordinate: destination)
                .tint(.red)
            
            // 경로 표시
            if let route {
                // MKRoute의 polyline을 MapPolyline으로 변환
                MapPolyline(route.polyline)
                    .stroke(.blue, lineWidth: 5)
            }
        }
    }
}

// MKRoute.polyline은 MKPolyline 타입
// MapPolyline이 직접 MKPolyline을 받을 수 있음
