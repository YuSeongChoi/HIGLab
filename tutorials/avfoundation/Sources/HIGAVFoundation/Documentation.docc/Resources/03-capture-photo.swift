import AVFoundation
import SwiftUI

@MainActor
class CameraManager: ObservableObject {
    let captureSession = AVCaptureSession()
    let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    @Published var flashMode: AVCaptureDevice.FlashMode = .auto
    @Published var capturedImage: UIImage?
    @Published var isCapturing = false
    
    /// 델리게이트 참조 유지 (촬영 완료 전까지 유지 필요)
    private var photoCaptureDelegate: PhotoCaptureDelegate?
    
    // MARK: - Capture Photo
    
    func capturePhoto() {
        guard !isCapturing else { return }
        isCapturing = true
        
        sessionQueue.async { [self] in
            let settings = createPhotoSettings()
            
            // 델리게이트 생성 및 유지
            let delegate = PhotoCaptureDelegate { [weak self] image in
                Task { @MainActor in
                    self?.capturedImage = image
                    self?.isCapturing = false
                    self?.photoCaptureDelegate = nil
                }
            }
            
            Task { @MainActor in
                photoCaptureDelegate = delegate
            }
            
            // 사진 촬영 요청
            photoOutput.capturePhoto(with: settings, delegate: delegate)
        }
    }
    
    private func createPhotoSettings() -> AVCapturePhotoSettings {
        let settings = AVCapturePhotoSettings()
        if photoOutput.supportedFlashModes.contains(flashMode) {
            settings.flashMode = flashMode
        }
        return settings
    }
}
