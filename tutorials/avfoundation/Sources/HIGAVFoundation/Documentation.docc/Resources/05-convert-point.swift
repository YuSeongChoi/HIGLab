import AVFoundation
import UIKit

extension CameraManager {
    
    // MARK: - Point Conversion
    
    /// 화면 좌표를 카메라 좌표로 변환
    /// - Parameter viewPoint: 화면상의 좌표 (0~뷰크기)
    /// - Returns: 카메라 좌표 (0~1)
    func convertToDevicePoint(_ viewPoint: CGPoint, in previewLayer: AVCaptureVideoPreviewLayer) -> CGPoint {
        // PreviewLayer의 메서드 사용
        // 화면 좌표 → 정규화된 카메라 좌표 (0.0 ~ 1.0)
        return previewLayer.captureDevicePointConverted(fromLayerPoint: viewPoint)
    }
    
    /// 카메라 좌표를 화면 좌표로 변환
    /// - Parameter devicePoint: 카메라 좌표 (0~1)
    /// - Returns: 화면상의 좌표
    func convertToViewPoint(_ devicePoint: CGPoint, in previewLayer: AVCaptureVideoPreviewLayer) -> CGPoint {
        // 정규화된 카메라 좌표 → 화면 좌표
        return previewLayer.layerPointConverted(fromCaptureDevicePoint: devicePoint)
    }
}
