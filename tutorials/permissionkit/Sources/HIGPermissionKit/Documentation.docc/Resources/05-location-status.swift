import PermissionKit
import CoreLocation
import SwiftUI

// 위치 권한 상태 정의
enum LocationPermissionState {
    case notDetermined      // 아직 결정되지 않음
    case denied             // 거부됨
    case authorizedWhenInUse // 앱 사용 중에만 허용
    case authorizedAlways   // 항상 허용
    case restricted         // 제한됨 (보호자 통제 등)
    
    var description: String {
        switch self {
        case .notDetermined:
            return "위치 권한을 요청해주세요"
        case .denied:
            return "위치 권한이 거부되었습니다"
        case .authorizedWhenInUse:
            return "앱 사용 중 위치 접근 가능"
        case .authorizedAlways:
            return "백그라운드 위치 접근 가능"
        case .restricted:
            return "위치 사용이 제한되어 있습니다"
        }
    }
    
    var icon: String {
        switch self {
        case .notDetermined: return "location.slash"
        case .denied: return "location.slash.fill"
        case .authorizedWhenInUse: return "location.fill"
        case .authorizedAlways: return "location.circle.fill"
        case .restricted: return "lock.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .notDetermined: return .gray
        case .denied, .restricted: return .red
        case .authorizedWhenInUse: return .blue
        case .authorizedAlways: return .green
        }
    }
    
    static func from(_ status: CLAuthorizationStatus) -> LocationPermissionState {
        switch status {
        case .notDetermined: return .notDetermined
        case .denied: return .denied
        case .authorizedWhenInUse: return .authorizedWhenInUse
        case .authorizedAlways: return .authorizedAlways
        case .restricted: return .restricted
        @unknown default: return .notDetermined
        }
    }
}

// iOS 26 PermissionKit - HIG Lab
