import Foundation
import CoreLocation

extension LocationManager {
    /// 위치 업데이트 수신 처리
    func handleLocationUpdate(_ locations: [CLLocation]) {
        // 배열의 마지막 요소가 가장 최신 위치
        guard let newLocation = locations.last else { return }
        
        // 유효한 위치인지 확인
        // horizontalAccuracy가 음수면 위치가 유효하지 않음
        guard newLocation.horizontalAccuracy >= 0 else {
            print("유효하지 않은 위치 데이터")
            return
        }
        
        // 현재 위치 업데이트
        DispatchQueue.main.async { [weak self] in
            self?.currentLocation = newLocation
        }
        
        // 위치 정보 출력 (디버깅용)
        print("""
        📍 새 위치:
        - 좌표: \(newLocation.coordinate.latitude), \(newLocation.coordinate.longitude)
        - 정확도: \(newLocation.horizontalAccuracy)m
        - 고도: \(newLocation.altitude)m
        - 속도: \(newLocation.speed)m/s
        - 시간: \(newLocation.timestamp)
        """)
    }
}

// CLLocationManagerDelegate에서 호출:
// func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//     handleLocationUpdate(locations)
// }
