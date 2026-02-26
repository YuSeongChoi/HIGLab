import Foundation
import CoreLocation
import MapKit
import Observation

@Observable
final class LocationManager: NSObject {
    private let manager = CLLocationManager()
    
    private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    private(set) var currentLocation: CLLocation?
    private(set) var routeCoordinates: [CLLocationCoordinate2D] = []
    private(set) var isTracking = false
    private(set) var totalDistance: Double = 0 // meters
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 10 // 10미터마다 업데이트
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
    }
    
    // MARK: - Authorization
    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    func requestAlwaysAuthorization() {
        manager.requestAlwaysAuthorization()
    }
    
    // MARK: - Tracking
    func startTracking() {
        guard authorizationStatus == .authorizedWhenInUse || 
              authorizationStatus == .authorizedAlways else {
            requestAuthorization()
            return
        }
        
        routeCoordinates.removeAll()
        totalDistance = 0
        isTracking = true
        manager.startUpdatingLocation()
    }
    
    func stopTracking() {
        isTracking = false
        manager.stopUpdatingLocation()
    }
    
    // MARK: - Map Region
    var mapRegion: MKCoordinateRegion {
        if let location = currentLocation {
            return MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
        // 기본값: 서울
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    }
    
    // MARK: - Route Polyline
    var routePolyline: MKPolyline {
        MKPolyline(coordinates: routeCoordinates, count: routeCoordinates.count)
    }
    
    var formattedDistance: String {
        if totalDistance >= 1000 {
            return String(format: "%.2f km", totalDistance / 1000)
        } else {
            return String(format: "%.0f m", totalDistance)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        // 정확도가 낮은 위치 필터링
        guard newLocation.horizontalAccuracy < 50 else { return }
        
        // 거리 계산
        if let lastLocation = currentLocation {
            let distance = newLocation.distance(from: lastLocation)
            totalDistance += distance
        }
        
        currentLocation = newLocation
        
        if isTracking {
            routeCoordinates.append(newLocation.coordinate)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 오류: \(error.localizedDescription)")
    }
}
