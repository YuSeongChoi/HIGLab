import AVFoundation
import UIKit

extension CameraManager {
    
    // MARK: - Video Rotation
    
    /// 기기 방향에 따른 비디오 회전 각도 계산
    func videoRotationAngle(for orientation: UIDeviceOrientation) -> CGFloat {
        switch orientation {
        case .portrait:
            return 90
        case .portraitUpsideDown:
            return 270
        case .landscapeLeft:
            return 0
        case .landscapeRight:
            return 180
        default:
            return 90 // 기본값: 세로
        }
    }
    
    /// 현재 기기 방향에 맞는 회전 각도
    var currentVideoRotationAngle: CGFloat {
        videoRotationAngle(for: UIDevice.current.orientation)
    }
}
