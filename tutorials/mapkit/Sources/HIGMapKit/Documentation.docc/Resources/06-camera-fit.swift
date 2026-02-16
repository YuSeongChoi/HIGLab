import SwiftUI
import MapKit

struct RouteMapView: View {
    let route: MKRoute?
    let source: CLLocationCoordinate2D
    let destination: CLLocationCoordinate2D
    
    @State private var position: MapCameraPosition = .automatic
    
    var body: some View {
        Map(position: $position) {
            Marker("출발", coordinate: source)
                .tint(.green)
            
            Marker("도착", coordinate: destination)
                .tint(.red)
            
            if let route {
                MapPolyline(route.polyline)
                    .stroke(.blue, lineWidth: 5)
            }
        }
        .onChange(of: route) { _, newRoute in
            fitToRoute(newRoute)
        }
    }
    
    /// 경로에 맞게 카메라 조정
    private func fitToRoute(_ route: MKRoute?) {
        guard let route else { return }
        
        // polyline의 boundingMapRect로 영역 계산
        let rect = route.polyline.boundingMapRect
        
        // 여백을 추가하여 region 생성
        let padding = 0.2  // 20% 여백
        let paddedRect = rect.insetBy(
            dx: -rect.width * padding,
            dy: -rect.height * padding
        )
        
        let region = MKCoordinateRegion(paddedRect)
        
        withAnimation(.easeInOut(duration: 0.5)) {
            position = .region(region)
        }
    }
}
