import MapKit

extension DirectionsService {
    /// 경로 정보 추출
    func routeInfo(from route: MKRoute) -> RouteInfo {
        RouteInfo(
            // 예상 소요 시간 (초 → 분)
            travelTime: Int(route.expectedTravelTime / 60),
            
            // 총 거리 (미터 → 킬로미터)
            distance: route.distance / 1000,
            
            // 경로 이름 (선택적)
            name: route.name,
            
            // 안내 단계 수
            stepsCount: route.steps.count
        )
    }
}

/// 경로 정보 모델
struct RouteInfo {
    let travelTime: Int      // 분 단위
    let distance: Double     // km 단위
    let name: String
    let stepsCount: Int
    
    var formattedTime: String {
        if travelTime < 60 {
            return "\(travelTime)분"
        } else {
            let hours = travelTime / 60
            let minutes = travelTime % 60
            return "\(hours)시간 \(minutes)분"
        }
    }
    
    var formattedDistance: String {
        if distance < 1 {
            return "\(Int(distance * 1000))m"
        } else {
            return String(format: "%.1fkm", distance)
        }
    }
}
