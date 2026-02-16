import SwiftUI
import MapKit

struct RouteMapView: View {
    let route: MKRoute?
    let transportType: MKDirectionsTransportType
    
    var body: some View {
        Map {
            if let route {
                MapPolyline(route.polyline)
                    .stroke(
                        strokeColor,
                        style: strokeStyle
                    )
            }
        }
    }
    
    /// 이동 수단별 색상
    private var strokeColor: Color {
        switch transportType {
        case .walking:
            return .blue
        case .automobile:
            return .green
        case .transit:
            return .orange
        default:
            return .gray
        }
    }
    
    /// 이동 수단별 선 스타일
    private var strokeStyle: StrokeStyle {
        switch transportType {
        case .walking:
            // 도보: 점선
            return StrokeStyle(
                lineWidth: 4,
                lineCap: .round,
                dash: [6, 6]
            )
        case .automobile:
            // 차량: 실선
            return StrokeStyle(
                lineWidth: 6,
                lineCap: .round
            )
        case .transit:
            // 대중교통: 중간 굵기 실선
            return StrokeStyle(
                lineWidth: 5,
                lineCap: .round
            )
        default:
            return StrokeStyle(lineWidth: 4)
        }
    }
}
