import AVFoundation
import SwiftUI

@MainActor
class CameraManager: ObservableObject {
    let captureSession = AVCaptureSession()
    let photoOutput = AVCapturePhotoOutput()
    
    // MARK: - Photo Output Capabilities
    
    /// 지원되는 기능 확인
    func checkPhotoCapabilities() {
        // 플래시 지원 여부
        let isFlashSupported = photoOutput.supportedFlashModes.contains(.on)
        print("플래시 지원: \(isFlashSupported)")
        
        // Live Photo 지원 여부
        let isLivePhotoSupported = photoOutput.isLivePhotoCaptureSupported
        print("Live Photo 지원: \(isLivePhotoSupported)")
        
        // Portrait Effect 지원 여부
        let isPortraitSupported = photoOutput.isDepthDataDeliverySupported
        print("인물 사진 모드 지원: \(isPortraitSupported)")
        
        // 지원되는 코덱 확인
        let availableCodecs = photoOutput.availablePhotoCodecTypes
        print("지원 코덱: \(availableCodecs)")
        
        // HEIF 지원 여부
        let isHEIFSupported = availableCodecs.contains(.hevc)
        print("HEIF 지원: \(isHEIFSupported)")
    }
}
