#if canImport(PermissionKit)
import PermissionKit
import AVFoundation

// 카메라 권한 상태 확인
struct CameraPermissionChecker {
    
    /// 현재 카메라 권한 상태를 확인합니다
    static func checkStatus() -> AVAuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    /// 권한 상태에 따른 UI 메시지
    static func statusMessage(_ status: AVAuthorizationStatus) -> String {
        switch status {
        case .notDetermined:
            return "카메라 권한을 요청해주세요"
        case .restricted:
            return "카메라 사용이 제한되어 있습니다"
        case .denied:
            return "설정에서 카메라 권한을 허용해주세요"
        case .authorized:
            return "카메라를 사용할 수 있습니다"
        @unknown default:
            return "알 수 없는 상태입니다"
        }
    }
}

// iOS 26 PermissionKit - HIG Lab
#endif
