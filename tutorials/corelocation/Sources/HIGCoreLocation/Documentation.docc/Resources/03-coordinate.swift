import Foundation
import CoreLocation

/// 위치 좌표 정보 추출
struct LocationData {
    let latitude: Double      // 위도
    let longitude: Double     // 경도
    let timestamp: Date       // 측정 시간
    let accuracy: Double      // 정확도 (미터)
    
    /// CLLocation에서 LocationData 생성
    init(from location: CLLocation) {
        // coordinate 프로퍼티에서 위도/경도 추출
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        
        // 측정 시간
        self.timestamp = location.timestamp
        
        // 수평 정확도 (미터 단위)
        // 값이 작을수록 정확한 위치
        self.accuracy = location.horizontalAccuracy
    }
    
    /// 좌표를 문자열로 반환
    var coordinateString: String {
        String(format: "%.6f, %.6f", latitude, longitude)
    }
    
    /// 유효한 위치인지 확인
    var isValid: Bool {
        // 정확도가 음수면 유효하지 않음
        accuracy >= 0
    }
}

// 사용 예시:
// if let location = locationManager.currentLocation {
//     let data = LocationData(from: location)
//     print("현재 위치: \(data.coordinateString)")
//     print("정확도: \(data.accuracy)m")
// }
