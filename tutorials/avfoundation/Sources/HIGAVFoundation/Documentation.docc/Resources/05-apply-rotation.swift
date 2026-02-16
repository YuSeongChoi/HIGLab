import AVFoundation
import UIKit

extension CameraManager {
    
    // MARK: - Apply Rotation
    
    func updatePreviewLayerRotation(for orientation: UIDeviceOrientation) {
        guard let connection = previewLayer?.connection else { return }
        
        let angle = videoRotationAngle(for: orientation)
        
        // iOS 17+: videoRotationAngle 사용
        if connection.isVideoRotationAngleSupported(angle) {
            connection.videoRotationAngle = angle
        }
    }
    
    /// 출력의 비디오 방향도 함께 업데이트 (사진/비디오 저장용)
    func updateOutputRotation(for orientation: UIDeviceOrientation) {
        let angle = videoRotationAngle(for: orientation)
        
        // Photo Output 연결
        if let photoConnection = photoOutput.connection(with: .video),
           photoConnection.isVideoRotationAngleSupported(angle) {
            photoConnection.videoRotationAngle = angle
        }
        
        // Movie Output 연결
        if let movieConnection = movieOutput.connection(with: .video),
           movieConnection.isVideoRotationAngleSupported(angle) {
            movieConnection.videoRotationAngle = angle
        }
    }
    
    private func videoRotationAngle(for orientation: UIDeviceOrientation) -> CGFloat {
        switch orientation {
        case .portrait: return 90
        case .portraitUpsideDown: return 270
        case .landscapeLeft: return 0
        case .landscapeRight: return 180
        default: return 90
        }
    }
}
