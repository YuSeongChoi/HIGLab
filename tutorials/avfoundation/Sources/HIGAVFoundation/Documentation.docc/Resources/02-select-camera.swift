import AVFoundation
import SwiftUI

@MainActor
class CameraManager: ObservableObject {
    let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    private var currentVideoDevice: AVCaptureDevice?
    private var videoDeviceInput: AVCaptureDeviceInput?
    
    @Published var isSessionRunning = false
    
    // MARK: - Camera Selection
    
    /// 기본 후면 카메라 선택
    /// 우선순위: 듀얼 카메라 > 와이드 앵글 카메라
    func selectDefaultBackCamera() -> AVCaptureDevice? {
        // 1순위: 듀얼 카메라 (인물 사진 모드 지원)
        if let dualCamera = AVCaptureDevice.default(
            .builtInDualCamera,
            for: .video,
            position: .back
        ) {
            return dualCamera
        }
        
        // 2순위: 듀얼 와이드 카메라
        if let dualWideCamera = AVCaptureDevice.default(
            .builtInDualWideCamera,
            for: .video,
            position: .back
        ) {
            return dualWideCamera
        }
        
        // 3순위: 와이드 앵글 카메라 (기본)
        return AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        )
    }
    
    /// 전면 카메라 선택
    func selectFrontCamera() -> AVCaptureDevice? {
        return AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .front
        )
    }
}
