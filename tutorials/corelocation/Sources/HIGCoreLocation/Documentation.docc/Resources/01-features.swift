import CoreLocation

/// CoreLocation 프레임워크의 핵심 기능들
enum CoreLocationFeatures {
    /// 1. 현재 위치 조회 (One-shot)
    /// - 버튼 클릭 시 현재 위치 표시
    /// - 배터리 효율적
    case currentLocation
    
    /// 2. 지속적 위치 업데이트
    /// - 러닝 경로 실시간 추적
    /// - GPS 기반 정밀 추적
    case continuousUpdates
    
    /// 3. 백그라운드 위치 추적
    /// - 앱이 백그라운드에 있어도 추적
    /// - "Always" 권한 필요
    case backgroundTracking
    
    /// 4. 지오펜싱
    /// - 특정 영역 진입/이탈 감지
    /// - 최대 20개 영역 모니터링
    case geofencing
    
    /// 5. iBeacon 감지
    /// - 실내 위치 인식
    /// - Bluetooth Low Energy 기반
    case beaconDetection
    
    /// 6. 방문 모니터링
    /// - 특정 장소 방문 자동 감지
    /// - 배터리 매우 효율적
    case visitMonitoring
}
