import Foundation
import CoreLocation

/// NSObject를 상속해야 CLLocationManagerDelegate를 사용할 수 있습니다.
/// 이유: CLLocationManagerDelegate는 Objective-C 프로토콜이므로
///       Swift 클래스가 이를 채택하려면 NSObject 상속이 필요합니다.

final class LocationManager: NSObject, ObservableObject {
    //                        ^^^^^^^^
    //                        NSObject 상속 필수!
    
    private let manager = CLLocationManager()
    
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var errorMessage: String?
    @Published var isTracking = false
    
    override init() {
        super.init()  // NSObject의 init 호출
        
        manager.delegate = self  // self를 delegate로 설정
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.activityType = .fitness
        authorizationStatus = manager.authorizationStatus
    }
}

extension LocationManager: CLLocationManagerDelegate {
    //                      ^^^^^^^^^^^^^^^^^^^^^^^^
    //                      NSObject 없이는 컴파일 에러!
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = error.localizedDescription
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}
