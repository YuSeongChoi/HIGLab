import Foundation
import CoreLocation

extension LocationManager {
    /// 위치 에러 처리
    func handleLocationError(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            if let clError = error as? CLError {
                switch clError.code {
                case .denied:
                    self?.errorMessage = "위치 권한이 거부되었습니다. 설정에서 권한을 허용해주세요."
                    
                case .locationUnknown:
                    self?.errorMessage = "현재 위치를 확인할 수 없습니다. 잠시 후 다시 시도해주세요."
                    
                case .network:
                    self?.errorMessage = "네트워크 오류입니다. 인터넷 연결을 확인해주세요."
                    
                case .headingFailure:
                    self?.errorMessage = "방향 정보를 가져올 수 없습니다."
                    
                case .rangingUnavailable, .rangingFailure:
                    self?.errorMessage = "비콘 감지에 실패했습니다."
                    
                default:
                    self?.errorMessage = "위치 오류: \(clError.localizedDescription)"
                }
            } else {
                self?.errorMessage = error.localizedDescription
            }
            
            print("❌ 위치 에러: \(error.localizedDescription)")
        }
    }
}

// CLLocationManagerDelegate에서 호출:
// func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//     handleLocationError(error)
// }
