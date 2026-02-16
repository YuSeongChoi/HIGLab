import Foundation
import CoreLocation

/// 거리 계산 유틸리티
extension CLLocation {
    /// 다른 위치까지의 거리 (미터)
    func distanceInMeters(to other: CLLocation) -> Double {
        // distance(from:)은 지구 곡률을 고려한 정확한 거리 반환
        return distance(from: other)
    }
    
    /// 다른 위치까지의 거리 (킬로미터)
    func distanceInKilometers(to other: CLLocation) -> Double {
        return distance(from: other) / 1000.0
    }
}

/// 러닝 경로 거리 계산기
struct DistanceCalculator {
    /// 경로의 총 거리 계산 (미터)
    static func totalDistance(of route: [CLLocation]) -> Double {
        guard route.count >= 2 else { return 0 }
        
        var totalDistance: Double = 0
        
        for i in 1..<route.count {
            let previous = route[i - 1]
            let current = route[i]
            
            // 연속된 두 지점 사이의 거리를 누적
            totalDistance += current.distance(from: previous)
        }
        
        return totalDistance
    }
    
    /// 거리를 포맷팅된 문자열로 변환
    static func formatDistance(_ meters: Double) -> String {
        if meters < 1000 {
            return String(format: "%.0f m", meters)
        } else {
            return String(format: "%.2f km", meters / 1000)
        }
    }
}

// 사용 예시:
// let start = CLLocation(latitude: 37.5665, longitude: 126.9780)  // 서울시청
// let end = CLLocation(latitude: 37.5512, longitude: 126.9882)    // 남산타워
// let distance = start.distanceInMeters(to: end)
// print("거리: \(DistanceCalculator.formatDistance(distance))")  // 약 2km
