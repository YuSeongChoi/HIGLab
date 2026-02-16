import AVFoundation
import SwiftUI

@MainActor
class CameraManager: ObservableObject {
    // 캡처 세션
    let captureSession = AVCaptureSession()
    
    // 현재 카메라 장치
    private var videoDevice: AVCaptureDevice?
    
    // 백그라운드 처리를 위한 전용 큐
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    // 세션 상태
    @Published var isSessionRunning = false
    
    // 권한 상태
    @Published var cameraPermissionGranted = false
    @Published var microphonePermissionGranted = false
}
