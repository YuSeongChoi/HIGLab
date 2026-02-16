import SwiftUI
import MapKit

struct MapPolylineView: View {
    let routeCoordinates: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 37.4979, longitude: 127.0276),
        CLLocationCoordinate2D(latitude: 37.4990, longitude: 127.0290),
        CLLocationCoordinate2D(latitude: 37.5010, longitude: 127.0320),
    ]
    
    var body: some View {
        Map {
            // 도보 경로: 점선
            MapPolyline(coordinates: routeCoordinates)
                .stroke(.blue, style: StrokeStyle(
                    lineWidth: 5,
                    lineCap: .round,
                    lineJoin: .round,
                    dash: [8, 8]  // 점선 패턴
                ))
        }
    }
}

// 이동 수단별 스타일 가이드:
// 도보: 점선 (dash), 파란색
// 차량: 실선, 굵은 선, 초록색
// 대중교통: 색상 다양 (버스 노선별)
