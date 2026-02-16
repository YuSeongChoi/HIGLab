import AVFoundation
import SwiftUI

@MainActor
class CameraManager: ObservableObject {
    let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    private var currentVideoDevice: AVCaptureDevice?
    private var videoDeviceInput: AVCaptureDeviceInput?
    
    @Published var isSessionRunning = false
    
    // MARK: - Session Configuration
    
    func configureSession() {
        sessionQueue.async { [self] in
            // 구성 시작 - 여러 변경사항을 원자적으로 적용
            captureSession.beginConfiguration()
            
            // 에러 발생 시에도 commitConfiguration이 호출되도록 defer 사용
            defer {
                captureSession.commitConfiguration()
            }
            
            // 세션 프리셋 설정
            captureSession.sessionPreset = .photo
            
            // 여기서 입력과 출력을 추가
            // ...
        }
    }
}
