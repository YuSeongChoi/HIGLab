import Foundation
import CoreLocation

extension LocationManager {
    /// 현재 위치를 한 번만 요청
    /// - 버튼 클릭 시 현재 위치 표시
    /// - 러닝 시작 전 출발점 확인
    func requestCurrentLocation() {
        guard isAuthorized else {
            errorMessage = "위치 권한이 필요합니다."
            return
        }
        
        // requestLocation()은 위치를 한 번 받고 자동으로 중지
        // - didUpdateLocations에서 위치를 받음
        // - 에러 시 didFailWithError 호출
        manager.requestLocation()
    }
}

// 사용 예시:
// locationManager.requestCurrentLocation()
// 결과는 locationManager.currentLocation에서 확인
