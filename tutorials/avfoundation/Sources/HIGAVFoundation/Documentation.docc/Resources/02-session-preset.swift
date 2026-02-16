import AVFoundation
import SwiftUI

@MainActor
class CameraManager: ObservableObject {
    let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    private var currentVideoDevice: AVCaptureDevice?
    private var videoDeviceInput: AVCaptureDeviceInput?
    
    @Published var isSessionRunning = false
    
    // MARK: - Session Preset 설정
    
    func configureSession() {
        sessionQueue.async { [self] in
            // 세션 프리셋 설정
            // .photo: 고화질 사진에 최적화
            // .high: 고화질 비디오
            // .medium: 중간 품질
            // .hd4K3840x2160: 4K 비디오
            
            if captureSession.canSetSessionPreset(.photo) {
                captureSession.sessionPreset = .photo
            }
        }
    }
}
