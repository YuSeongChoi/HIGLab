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
    
    func requestWhenInUseAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    func requestAlwaysAuthorization() {
        guard authorizationStatus == .authorizedWhenInUse else {
            requestWhenInUseAuthorization()
            return
        }
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
    
    /// 권한 상태 변경 처리 (iOS 14+)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let newStatus = manager.authorizationStatus
            let oldStatus = self.authorizationStatus
            self.authorizationStatus = newStatus
            
            // 권한 변경에 따른 동작
            switch newStatus {
            case .notDetermined:
                // 아직 요청 전
                break
                
            case .denied, .restricted:
                // 권한 거부됨 - 추적 중이었다면 중지
                if self.isTracking {
                    self.stopTracking()
                    self.errorMessage = "위치 권한이 거부되어 추적이 중지되었습니다."
                }
                
            case .authorizedWhenInUse:
                // When In Use 획득
                if oldStatus == .notDetermined {
                    // 처음 권한을 받음 - 현재 위치 요청
                    self.manager.requestLocation()
                }
                
            case .authorizedAlways:
                // Always 획득 - 백그라운드 추적 가능
                print("백그라운드 위치 추적이 가능합니다.")
                
            @unknown default:
                break
            }
        }
    }
    
    private func stopTracking() {
        manager.stopUpdatingLocation()
        isTracking = false
    }
}
