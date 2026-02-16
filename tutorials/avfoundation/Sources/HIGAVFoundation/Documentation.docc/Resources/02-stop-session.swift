import AVFoundation
import SwiftUI

@MainActor
class CameraManager: ObservableObject {
    let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    private var currentVideoDevice: AVCaptureDevice?
    private var videoDeviceInput: AVCaptureDeviceInput?
    
    @Published var isSessionRunning = false
    
    // MARK: - Start/Stop Session
    
    func startSession() {
        sessionQueue.async { [self] in
            if !captureSession.isRunning {
                captureSession.startRunning()
                Task { @MainActor in
                    isSessionRunning = true
                }
            }
        }
    }
    
    func stopSession() {
        sessionQueue.async { [self] in
            if captureSession.isRunning {
                captureSession.stopRunning()
                Task { @MainActor in
                    isSessionRunning = false
                }
            }
        }
    }
}
