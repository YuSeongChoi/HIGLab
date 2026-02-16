import AVFoundation
import SwiftUI

@MainActor
class CameraManager: ObservableObject {
    let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    let photoOutput = AVCapturePhotoOutput()
    
    private var currentVideoDevice: AVCaptureDevice?
    private var videoDeviceInput: AVCaptureDeviceInput?
    
    @Published var isSessionRunning = false
    @Published var capturedImage: UIImage?
    
    func configureSession() {
        sessionQueue.async { [self] in
            captureSession.beginConfiguration()
            defer { captureSession.commitConfiguration() }
            
            captureSession.sessionPreset = .photo
            
            // 카메라 입력 추가 (이전 단계에서 구현)
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
                  captureSession.canAddInput(videoInput) else {
                return
            }
            captureSession.addInput(videoInput)
            videoDeviceInput = videoInput
            
            // Photo Output 추가
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
                
                // 최고 품질 설정
                photoOutput.maxPhotoQualityPrioritization = .quality
            } else {
                print("Photo Output을 추가할 수 없습니다.")
            }
        }
    }
}
