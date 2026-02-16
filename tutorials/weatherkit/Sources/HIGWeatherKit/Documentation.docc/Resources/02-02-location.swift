import WeatherKit
import CoreLocation

// 위치 지정 방법

// 1. 직접 좌표 지정
let tokyo = CLLocation(latitude: 35.6762, longitude: 139.6503)
let newyork = CLLocation(latitude: 40.7128, longitude: -74.0060)

// 2. CoreLocation으로 현재 위치 가져오기
class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    var currentLocation: CLLocation?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, 
                        didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, 
                        didFailWithError error: Error) {
        print("위치 가져오기 실패: \(error)")
    }
}
