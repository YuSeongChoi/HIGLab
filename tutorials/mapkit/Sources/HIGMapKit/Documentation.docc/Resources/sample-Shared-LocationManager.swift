import Foundation
import CoreLocation
import Observation

// MARK: - 위치 관리자

/// CLLocationManager를 감싸는 Observable 래퍼
/// iOS 17+ Observation 프레임워크 사용
@Observable
final class LocationManager: NSObject {
    
    // MARK: - Properties
    
    /// 현재 사용자 위치
    var location: CLLocation?
    
    /// 위치 권한 상태
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    /// 에러 메시지
    var errorMessage: String?
    
    /// 위치 로딩 중 여부
    var isLoading = false
    
    private let locationManager = CLLocationManager()
    
    // MARK: - Computed Properties
    
    /// 현재 좌표 (없으면 서울 시청 기본값)
    var coordinate: CLLocationCoordinate2D {
        location?.coordinate ?? CLLocationCoordinate2D(
            latitude: 37.5665,  // 서울 시청
            longitude: 126.9780
        )
    }
    
    /// 위치 권한이 허용되었는지 여부
    var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse ||
        authorizationStatus == .authorizedAlways
    }
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }
    
    // MARK: - Public Methods
    
    /// 위치 권한 요청
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// 현재 위치 업데이트 시작
    func startUpdatingLocation() {
        guard isAuthorized else {
            requestAuthorization()
            return
        }
        
        isLoading = true
        errorMessage = nil
        locationManager.startUpdatingLocation()
    }
    
    /// 위치 업데이트 중지
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        isLoading = false
    }
    
    /// 한 번만 위치 요청 (iOS 17+)
    func requestLocation() {
        guard isAuthorized else {
            requestAuthorization()
            return
        }
        
        isLoading = true
        errorMessage = nil
        locationManager.requestLocation()
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        // 가장 최근 위치 사용
        guard let newLocation = locations.last else { return }
        
        location = newLocation
        isLoading = false
        
        // 한 번만 위치가 필요한 경우 업데이트 중지
        stopUpdatingLocation()
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        isLoading = false
        
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                errorMessage = "위치 권한이 거부되었습니다. 설정에서 허용해주세요."
            case .locationUnknown:
                errorMessage = "현재 위치를 확인할 수 없습니다."
            default:
                errorMessage = "위치 오류: \(clError.localizedDescription)"
            }
        } else {
            errorMessage = error.localizedDescription
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        // 권한이 허용되면 자동으로 위치 요청
        if isAuthorized && location == nil {
            requestLocation()
        }
    }
}
