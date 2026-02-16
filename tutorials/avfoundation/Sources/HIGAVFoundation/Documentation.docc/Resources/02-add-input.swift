import AVFoundation
import SwiftUI

@MainActor
class CameraManager: ObservableObject {
    let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    private var currentVideoDevice: AVCaptureDevice?
    private var videoDeviceInput: AVCaptureDeviceInput?
    
    @Published var isSessionRunning = false
    
    // MARK: - Add Video Input
    
    func configureSession() {
        sessionQueue.async { [self] in
            captureSession.beginConfiguration()
            defer { captureSession.commitConfiguration() }
            
            captureSession.sessionPreset = .photo
            
            // 카메라 장치 선택
            guard let videoDevice = selectDefaultBackCamera() else {
                print("카메라를 찾을 수 없습니다.")
                return
            }
            
            do {
                // 카메라 입력 생성
                let videoInput = try AVCaptureDeviceInput(device: videoDevice)
                
                // 세션에 입력 추가 가능 여부 확인
                if captureSession.canAddInput(videoInput) {
                    captureSession.addInput(videoInput)
                    videoDeviceInput = videoInput
                    currentVideoDevice = videoDevice
                } else {
                    print("카메라 입력을 추가할 수 없습니다.")
                }
            } catch {
                print("카메라 입력 생성 실패: \(error)")
            }
        }
    }
    
    private func selectDefaultBackCamera() -> AVCaptureDevice? {
        AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
    }
}
