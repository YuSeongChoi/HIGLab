import MapKit

extension DirectionsService {
    /// 경로 단계(턴바이턴) 추출
    func extractSteps(from route: MKRoute) -> [RouteStep] {
        route.steps.enumerated().compactMap { index, step in
            // 빈 안내문 제외 (출발/도착 지점)
            guard !step.instructions.isEmpty else { return nil }
            
            return RouteStep(
                index: index,
                instructions: step.instructions,  // "200m 앞에서 좌회전"
                distance: step.distance,          // 미터 단위
                coordinate: step.polyline.coordinate  // 시작 좌표
            )
        }
    }
}

/// 경로 단계 모델
struct RouteStep: Identifiable {
    let id = UUID()
    let index: Int
    let instructions: String
    let distance: CLLocationDistance
    let coordinate: CLLocationCoordinate2D
    
    var formattedDistance: String {
        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            return String(format: "%.1fkm", distance / 1000)
        }
    }
}

// MKRoute.Step 주요 프로퍼티:
// - instructions: String (안내 문구)
// - notice: String? (주의사항)
// - distance: CLLocationDistance (거리, 미터)
// - polyline: MKPolyline (해당 구간 경로)
