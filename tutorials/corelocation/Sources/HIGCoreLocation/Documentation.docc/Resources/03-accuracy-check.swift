import Foundation
import CoreLocation

/// 위치 정확도 검증
extension CLLocation {
    /// 러닝 기록에 적합한 정확도인지 확인
    var isAccurateEnoughForRunning: Bool {
        // 1. 정확도가 양수여야 함 (음수는 유효하지 않음)
        guard horizontalAccuracy >= 0 else { return false }
        
        // 2. 러닝 추적에는 50m 이내 정확도 권장
        // - 도심에서는 10m 이내도 가능
        // - 건물 밀집 지역에서는 30-50m도 허용
        return horizontalAccuracy <= 50
    }
    
    /// 정확도 수준 문자열
    var accuracyLevel: String {
        guard horizontalAccuracy >= 0 else { return "측정 불가" }
        
        switch horizontalAccuracy {
        case 0..<5:
            return "매우 정확 (GPS)"
        case 5..<15:
            return "정확 (GPS)"
        case 15..<30:
            return "양호 (GPS/Wi-Fi)"
        case 30..<100:
            return "보통 (Wi-Fi)"
        default:
            return "낮음 (셀룰러)"
        }
    }
}

/// 위치 필터링
extension LocationManager {
    /// 정확도가 낮은 위치 필터링
    func shouldUseLocation(_ location: CLLocation) -> Bool {
        // 정확도가 음수면 무시
        guard location.horizontalAccuracy >= 0 else {
            print("⚠️ 유효하지 않은 위치 (accuracy: \(location.horizontalAccuracy))")
            return false
        }
        
        // 100m 이상이면 무시 (러닝 추적에 부적합)
        guard location.horizontalAccuracy <= 100 else {
            print("⚠️ 정확도 낮음 (accuracy: \(location.horizontalAccuracy)m)")
            return false
        }
        
        return true
    }
}
