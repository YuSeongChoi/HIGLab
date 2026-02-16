import AVFoundation
import SwiftUI

@MainActor
class CameraManager: ObservableObject {
    // MARK: - Capture Session
    
    /// 캡처 세션 - 입력과 출력을 연결하는 중앙 허브
    let captureSession = AVCaptureSession()
    
    /// 세션 작업을 위한 전용 큐
    /// UI를 블로킹하지 않기 위해 백그라운드에서 실행
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    // MARK: - Device
    
    /// 현재 사용 중인 카메라 장치
    private var currentVideoDevice: AVCaptureDevice?
    
    /// 현재 카메라 입력
    private var videoDeviceInput: AVCaptureDeviceInput?
    
    // MARK: - State
    
    @Published var isSessionRunning = false
    @Published var cameraPermissionGranted = false
}
