import CoreLocation

extension LocationManager {
    /// 위치 업데이트 시작
    func startTracking() {
        // 정확도 설정
        manager.desiredAccuracy = kCLLocationAccuracyBest
        // 옵션:
        // kCLLocationAccuracyBestForNavigation - 최고 정확도 (배터리 소모 큼)
        // kCLLocationAccuracyBest - 높은 정확도
        // kCLLocationAccuracyNearestTenMeters - 10m 정확도
        // kCLLocationAccuracyHundredMeters - 100m 정확도
        // kCLLocationAccuracyKilometer - 1km 정확도
        
        // 거리 필터: 이 거리 이상 이동해야 업데이트
        manager.distanceFilter = 10  // 10m마다 업데이트
        // kCLDistanceFilterNone - 모든 변화에 업데이트
        
        // 업데이트 시작
        manager.startUpdatingLocation()
    }
    
    /// 위치 업데이트 중지
    func stopTracking() {
        manager.stopUpdatingLocation()
    }
}
