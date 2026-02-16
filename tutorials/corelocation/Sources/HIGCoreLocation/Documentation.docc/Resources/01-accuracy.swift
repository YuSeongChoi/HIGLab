import CoreLocation

/// 위치 정확도 옵션 비교
struct AccuracyOptions {
    /// 내비게이션용 최고 정확도
    /// - GPS + 가속도계 + 자이로스코프 융합
    /// - 배터리 소모: 매우 높음
    static let navigation = kCLLocationAccuracyBestForNavigation
    
    /// 최고 정확도 (러닝 앱 권장)
    /// - GPS 최대 활용
    /// - 배터리 소모: 높음
    static let best = kCLLocationAccuracyBest
    
    /// 10미터 정확도
    /// - GPS + Wi-Fi
    /// - 배터리 소모: 중간
    static let tenMeters = kCLLocationAccuracyNearestTenMeters
    
    /// 100미터 정확도
    /// - Wi-Fi + 셀룰러 중심
    /// - 배터리 소모: 낮음
    static let hundredMeters = kCLLocationAccuracyHundredMeters
    
    /// 킬로미터 정확도
    /// - 셀룰러 기반
    /// - 배터리 소모: 매우 낮음
    static let kilometer = kCLLocationAccuracyKilometer
    
    /// 러닝 트래커 추천 설정
    static func recommendedForRunning() -> CLLocationAccuracy {
        return kCLLocationAccuracyBest
    }
}
