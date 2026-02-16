import Foundation
import CoreLocation

/// 러닝 세션 데이터 모델
struct RunSession: Identifiable {
    let id = UUID()
    
    /// 시작 시간
    var startTime: Date
    
    /// 종료 시간 (nil이면 진행 중)
    var endTime: Date?
    
    /// 시작 위치
    var startLocation: CLLocation?
    
    /// 종료 위치 (nil이면 진행 중)
    var endLocation: CLLocation?
    
    /// 경로 좌표들
    var routeLocations: [CLLocation] = []
    
    // MARK: - 계산 프로퍼티
    
    /// 총 거리 (미터)
    var totalDistance: Double {
        DistanceCalculator.totalDistance(of: routeLocations)
    }
    
    /// 총 시간 (초)
    var duration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime)
    }
    
    /// 평균 페이스 (분/km)
    var averagePace: Double? {
        let kilometers = totalDistance / 1000.0
        guard kilometers > 0 else { return nil }
        return (duration / 60.0) / kilometers
    }
    
    /// 진행 중인지 확인
    var isRunning: Bool {
        endTime == nil
    }
    
    // MARK: - 초기화
    
    init() {
        self.startTime = Date()
    }
    
    // MARK: - 메서드
    
    /// 새 위치 추가
    mutating func addLocation(_ location: CLLocation) {
        if startLocation == nil {
            startLocation = location
        }
        routeLocations.append(location)
    }
    
    /// 러닝 종료
    mutating func finish() {
        endTime = Date()
        endLocation = routeLocations.last
    }
}
