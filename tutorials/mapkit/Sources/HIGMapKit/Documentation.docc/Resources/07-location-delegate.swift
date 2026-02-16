import CoreLocation
import SwiftUI

extension LocationManager {
    // 위치 업데이트 델리게이트 (이미 CLLocationManagerDelegate에 구현)
    
    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        // 가장 최신 위치 사용
        guard let newLocation = locations.last else { return }
        
        // 정확도 필터링 (필요시)
        guard newLocation.horizontalAccuracy < 100 else {
            return  // 100m 이상 오차는 무시
        }
        
        Task { @MainActor in
            self.location = newLocation
        }
    }
    
    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("위치 오류: \(error.localizedDescription)")
        
        // CLError 타입별 처리
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                print("위치 권한이 거부됨")
            case .locationUnknown:
                print("위치를 알 수 없음")
            default:
                print("기타 오류")
            }
        }
    }
}
