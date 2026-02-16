import CoreLocation

extension LocationManager {
    /// 배터리 최적화된 위치 추적
    func startOptimizedTracking() {
        // 활동 유형 설정 - 시스템이 이동 패턴을 예측
        manager.activityType = .fitness
        // 옵션:
        // .other            - 기본값
        // .automotiveNavigation - 차량 네비게이션
        // .fitness          - 걷기, 달리기
        // .otherNavigation  - 기타 네비게이션
        // .airborne         - 항공
        
        // 중요 위치 변경만 모니터링 (배터리 효율)
        manager.startMonitoringSignificantLocationChanges()
        // 대신 startUpdatingLocation() 사용하지 않음
        
        // 또는: 적당한 정확도 + 거리 필터
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 50  // 50m마다
        manager.startUpdatingLocation()
    }
    
    /// 백그라운드 위치 활성화
    func enableBackgroundLocation() {
        // Info.plist에 UIBackgroundModes > location 필요
        manager.allowsBackgroundLocationUpdates = true
        
        // 백그라운드에서 일시 정지 허용
        manager.pausesLocationUpdatesAutomatically = true
    }
}

// 배터리 효율 팁:
// 1. 필요할 때만 위치 업데이트 시작
// 2. 적절한 정확도 선택 (항상 Best가 아님)
// 3. 거리 필터 사용
// 4. 백그라운드에서는 significantLocationChanges 사용
