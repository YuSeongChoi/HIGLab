import Foundation
import CoreLocation
import Combine

final class LocationManager: NSObject, ObservableObject {
    private let manager = CLLocationManager()
    
    @Published var currentLocation: CLLocation?
    
    /// 권한 상태를 @Published로 노출하여 SwiftUI에서 반응형으로 사용
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    @Published var errorMessage: String?
    @Published var isTracking = false
    
    /// 권한이 허용된 상태인지 확인
    var isAuthorized: Bool {
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return true
        default:
            return false
        }
    }
    
    /// 백그라운드 추적이 가능한 상태인지 확인
    var canTrackInBackground: Bool {
        authorizationStatus == .authorizedAlways
    }
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.activityType = .fitness
        
        // 초기 권한 상태 읽기
        authorizationStatus = manager.authorizationStatus
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = error.localizedDescription
    }
    
    /// 권한 상태가 변경되면 @Published 프로퍼티 업데이트
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async { [weak self] in
            self?.authorizationStatus = manager.authorizationStatus
        }
    }
}
