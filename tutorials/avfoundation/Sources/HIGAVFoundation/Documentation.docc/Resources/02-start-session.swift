import AVFoundation
import SwiftUI

@MainActor
class CameraManager: ObservableObject {
    let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    private var currentVideoDevice: AVCaptureDevice?
    private var videoDeviceInput: AVCaptureDeviceInput?
    
    @Published var isSessionRunning = false
    
    // MARK: - Start Session
    
    func startSession() {
        // 세션 시작은 반드시 백그라운드 큐에서 실행
        // startRunning()은 동기 메서드로, 메인 스레드에서 호출하면 UI가 멈출 수 있음
        sessionQueue.async { [self] in
            if !captureSession.isRunning {
                captureSession.startRunning()
                
                // UI 업데이트는 메인 스레드에서
                Task { @MainActor in
                    isSessionRunning = captureSession.isRunning
                }
            }
        }
    }
}
