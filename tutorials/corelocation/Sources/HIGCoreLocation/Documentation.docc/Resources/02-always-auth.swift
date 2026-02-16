import Foundation
import CoreLocation

final class LocationManager: NSObject, ObservableObject {
    private let manager = CLLocationManager()
    
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var errorMessage: String?
    @Published var isTracking = false
    
    var isAuthorized: Bool {
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return true
        default:
            return false
        }
    }
    
    var canTrackInBackground: Bool {
        authorizationStatus == .authorizedAlways
    }
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.activityType = .fitness
        authorizationStatus = manager.authorizationStatus
    }
    
    // MARK: - 권한 요청
    
    func requestWhenInUseAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    /// "Always" 권한 요청 (업그레이드)
    /// ⚠️ 반드시 먼저 When In Use 권한이 있어야 합니다!
    func requestAlwaysAuthorization() {
        // When In Use 권한이 있을 때만 Always 요청 가능
        guard authorizationStatus == .authorizedWhenInUse else {
            // 먼저 When In Use를 요청
            requestWhenInUseAuthorization()
            return
        }
        
        // iOS 13+: 임시 Always 권한이 부여되고,
        // 시스템이 나중에 사용자에게 최종 확인을 요청합니다.
        manager.requestAlwaysAuthorization()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = error.localizedDescription
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async { [weak self] in
            self?.authorizationStatus = manager.authorizationStatus
        }
    }
}
