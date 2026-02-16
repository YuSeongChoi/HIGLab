import CoreLocation

/// iOS 위치 권한 상태
enum LocationAuthorizationStatus {
    /// 아직 권한을 요청하지 않음
    /// - 첫 실행 시 상태
    /// - 권한 요청 다이얼로그를 표시할 수 있음
    case notDetermined
    
    /// 사용자가 권한을 거부함
    /// - 설정 앱에서 변경 가능
    /// - 앱에서 설정으로 이동하도록 안내
    case denied
    
    /// 앱 사용 중에만 위치 접근 허용
    /// - 앱이 포그라운드에 있을 때만 위치 접근 가능
    /// - 백그라운드 추적 불가
    case whenInUse
    
    /// 항상 위치 접근 허용
    /// - 백그라운드에서도 위치 접근 가능
    /// - 러닝 트래커에 필요한 권한
    case always
}

/// CLAuthorizationStatus를 LocationAuthorizationStatus로 변환
extension LocationAuthorizationStatus {
    init(from status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            self = .notDetermined
        case .restricted, .denied:
            self = .denied
        case .authorizedWhenInUse:
            self = .whenInUse
        case .authorizedAlways:
            self = .always
        @unknown default:
            self = .denied
        }
    }
}
