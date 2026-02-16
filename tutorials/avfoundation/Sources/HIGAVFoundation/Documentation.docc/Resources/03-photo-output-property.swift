import AVFoundation
import SwiftUI

@MainActor
class CameraManager: ObservableObject {
    // MARK: - Capture Components
    
    let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    /// 사진 촬영을 위한 출력
    let photoOutput = AVCapturePhotoOutput()
    
    private var currentVideoDevice: AVCaptureDevice?
    private var videoDeviceInput: AVCaptureDeviceInput?
    
    // MARK: - State
    
    @Published var isSessionRunning = false
    @Published var capturedImage: UIImage?
}
