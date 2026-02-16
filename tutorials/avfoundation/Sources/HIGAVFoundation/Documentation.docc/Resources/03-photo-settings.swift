import AVFoundation
import SwiftUI

@MainActor
class CameraManager: ObservableObject {
    let captureSession = AVCaptureSession()
    let photoOutput = AVCapturePhotoOutput()
    
    @Published var flashMode: AVCaptureDevice.FlashMode = .auto
    
    // MARK: - Photo Settings
    
    /// 촬영 설정 생성
    func createPhotoSettings() -> AVCapturePhotoSettings {
        // HEIF 또는 JPEG 포맷 선택
        let settings: AVCapturePhotoSettings
        
        if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            // HEIF 포맷 (더 작은 파일, 높은 품질)
            settings = AVCapturePhotoSettings(
                format: [AVVideoCodecKey: AVVideoCodecType.hevc]
            )
        } else {
            // JPEG 포맷 (호환성)
            settings = AVCapturePhotoSettings(
                format: [AVVideoCodecKey: AVVideoCodecType.jpeg]
            )
        }
        
        // 플래시 모드 설정
        if photoOutput.supportedFlashModes.contains(flashMode) {
            settings.flashMode = flashMode
        }
        
        // 최고 품질 우선
        settings.photoQualityPrioritization = .quality
        
        return settings
    }
}
